//
//  GlassDropView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/15.
//

import SwiftUI

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
        
        ZStack{
            // ---1層目：ベースのすりガラス---
            Circle()
                .fill(.white.opacity(0.1))//透明度10%
                .background(.ultraThinMaterial)//すりガラス
                .mask(Circle())//丸く切り抜く
            //---2層目：光の反射レイヤー---
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.8), .clear] ,//白から透明へのグラデーション
                        
                        // スタート地点
                        //計算した太陽の位置を使う
                        startPoint: UnitPoint(x: lightPositionX, y: 0),
                        
                        //ゴール地点
                        //光が「入り口」から「中心」に向かって斜めに差し込むように
                        endPoint: UnitPoint(x: 0.5, y: 0.8)
                    )
                )
            
            // ---3層目：強力発光モード---
            Circle()
            // 線を少し太くして、完全に白くする
                .stroke(.white, lineWidth: 2)
            // 1段目：ビームのような強い光
                .shadow(color: .white, radius: 5)
            // 2段目：周りに広がるオーラのような光
                .shadow(color: .white.opacity(0.8), radius: 30)
            
            
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
