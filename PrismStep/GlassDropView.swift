//
//  GlassDropView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/15.
//

import SwiftUI
import RealityKit

struct GlassDropView: View {
    
    var stepCount: Int//歩数を受け取る
    
    // 太陽の角度を受け取る変数
    // デフォルト値を0にしておくと、プレビューなどが壊れにくいらしい
    var sunAngle: Double = 0
    
    // ぷるん！のアニメーション用スイッチ
    @State private var isBouncing = false
    
    // どっちに傾くか？の変数
    @State private var tiltAngle: Double = 0
    
    // 歩数に応じて、3段階のサイズを決める
    var dropSize: CGFloat {//CGFloat:座標やサイズを表す時に使う専用の実数型
        switch stepCount {
        case 0..<4000:
            // 0歩 〜 3999歩（小）
            return 120
            
        case 4000..<8000:
            // 4000歩 〜 7999歩（中）
            return 220
            
        default:
            // 8000歩以上（大）
            return 320
        }
    }
    
    var body: some View {
        
        // ▼▼▼ 1. ここで光の位置を計算 ▼▼▼
        // 太陽の角度(-45〜45)を、画面上の比率(0.0〜1.0)に変換
        // -45度なら0.0(左端)、0度なら0.5(真ん中)、45度なら1.0(右端)
        //スライダーの数字を画面上の位置に翻訳している。
        let lightPositionX = 0.5 + (sunAngle / 90)
        
        ZStack {
                    
                    // ▼▼▼ 【追加】0層目：カメラ映像（ここが新入り！） ▼▼▼
                    RealityView { content in
                        // カメラに映る3Dオブジェクトの設定（今回は箱を置く設定のままにします）
                        let model = Entity()
                        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
                        model.components.set(ModelComponent(mesh: mesh, materials: [material]))
                        model.position = [0, 0.05, 0]
                        
                        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
                        anchor.addChild(model)
                        content.add(anchor)
                        
                        // カメラを現実に連動させる設定
                        content.camera = .spatialTracking
                    }
                    .clipShape(Circle()) // ★超重要：カメラ映像を「丸」に切り抜く
                    .opacity(0.9)//カメラ映像自体を少し暗くする（上の反射を目立たせるため）
                    
                    
                    // ▼▼▼ 【変更】1層目：ベース（透明度を上げて中を見えやすくする） ▼▼▼
                    Circle()
                        // 白だと見えにくいので、薄い青にして透明度を下げる
                        .fill(Color.blue.opacity(0.4))
                        // .background(.ultraThinMaterial) ← すりガラスだとカメラがぼやけるので、今回は削除しました
                        
                        // 元のコードにあったマスクは不要（Circleそのものなので）
            
            // ★ポイント3：さらに「すりガラス」効果をうっすら足すと、液体感がアップ.ボヤけすぎたら3行消す。
            Circle()
                .fill(.ultraThinMaterial) // すりガラス素材
                .opacity(0.3)             // 30%くらいだけかける
                    
                    
                    // ---2層目：光の反射レイヤー（そのまま）---
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .clear], // カメラが見えるように少し薄くしました(0.8→0.5)
                                startPoint: UnitPoint(x: lightPositionX, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.8)
                            )
                        )
                    
            // ▼▼▼ 3層目：輪郭と影（立体感） ▼▼▼
                        Circle()
                            // ★ポイント5：枠線を少し太く、半透明の白にして「ガラスの厚み」を出す
                            .stroke(Color.white.opacity(0.5), lineWidth: 4)
                            
                            // 外側の影（ドロップシャドウ）
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 5)
                            // 内側の発光（ブルーム効果）
                            .shadow(color: .white.opacity(0.6), radius: 10)
                    
                }
        .frame(width:dropSize,height:dropSize)
        
        //ぷるんの魔法
        // ① 傾ける（タップ位置に合わせて回転）
        .rotationEffect(.degrees(tiltAngle))
        
        // ② 潰す（スイッチONなら変形）
        .scaleEffect(x: isBouncing ? 1.2 : 1.0, y: isBouncing ? 0.8 : 1.0)
        
        // ③ アニメーション設定（ボヨンボヨンさせるバネの設定）
        .animation(.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0), value: isBouncing)
        .animation(.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0), value: tiltAngle)
        
        // ④ タップ位置を検知するセンサー
        .gesture(
            DragGesture(minimumDistance: 0) // 0にすると「触った瞬間」に反応する
                .onEnded { value in
                    // 1. どこを触ったか取得（中心からの距離）
                    let touchX = value.location.x
                    let centerX = dropSize / 2
                    let diff = touchX - centerX // マイナスなら左側、プラスなら右側
                    
                    // 2. 位置によって傾きを変える
                    if diff < -30 {
                        // 左側を叩いた → 右へ傾く（プラスの角度）
                        tiltAngle = 100
                    } else if diff > 30 {
                        // 右側を叩いた → 左へ傾く（マイナスの角度）
                        tiltAngle = -100
                    } else {
                        // 真ん中あたり → 傾かない
                        tiltAngle = 100
                    }
                    
                    // 3. 潰れるスイッチON
                    isBouncing = true
                    
                    // 4. 0.1秒後にすべて元に戻す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isBouncing = false
                        tiltAngle = 0 // 傾きも戻す
                    }
                }
        )
    }
}

#Preview {
    VStack(spacing:40){
        // 例：左から光が当たっている状態
        GlassDropView(stepCount: 500, sunAngle: -30)
        // 例：正面から光
        GlassDropView(stepCount: 4500, sunAngle: 0)
        // 例：右から光
        GlassDropView(stepCount: 9000, sunAngle: 30)
    }
    .padding()
    
    //横幅と高さを画面いっぱいに広げる
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    //背景色を指定
    .background(
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.8)], // 薄い青〜水色
            startPoint: .topLeading,    // 左上から
            endPoint: .bottomTrailing   // 右下へ
        )
    )
}
