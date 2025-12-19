//
//  SunSliderView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/18.
//

import SwiftUI

struct SunSliderView: View {
    
    // 太陽の角度（親画面と共有する変数）
    // -45度(左) 〜 45度(右) の範囲で動かす想定
    @Binding var sunAngle: Double
    
    //ドラッグ開始時の角度を一時的に覚えておく変数
    //太陽を触った瞬間に、変な場所にワープしてしまうのを防ぐ
    @State private var initialDragAngle: Double? = nil
    
    // 画面の幅（調整用）
    //let trackWidth: CGFloat = 300
    
    var body: some View {
        
        // 1. 画面のサイズを知るための道具（GeometryReader）で囲む
        GeometryReader { geometry in//GeometryReaderで、スマホの機種によって太陽の大きさがバラバラになることを防ぐ
            // 画面の幅の130%を軌道の幅にする
            let trackWidth = geometry.size.width * 1.3
            // 半径を計算
            let radius = trackWidth / 2
            
            ZStack {
                // 1. 軌道（黄色いアーチ線）
                Circle()
                    .trim(from: 0.05, to: 0.45) // 円の上半分を少し削ってアーチにする
                    .stroke(//.strokeでCircleの色や太さを調整できる
                        Color.yellow.opacity(0.3),
                        style: StrokeStyle(lineWidth: 13, lineCap: .round)
                    )
                    .frame(width: trackWidth, height: trackWidth)
                    .rotationEffect(.degrees(180)) // 山なりにするために回転
                
                // 2. 太陽（動かせるつまみ）
                // 太陽の色（落ち着いた黄金色 #E0AC4F）を定義
                let sunColor = Color(red: 220/255, green: 165/255, blue: 32/255)

                //発光Ver.
               ZStack {
                    // --- 1層目：外側に広がるやわらかい光（オーラ） ---
                    Circle()
                        .fill(sunColor.opacity(0.5)) // 薄くする
                        .frame(width: 90, height: 90) // 本体より大きく
                        .blur(radius: 100) // 強くぼかす（これが光の表現になります）
                    
                    // --- 2層目：本体のすぐ周りの強い光 ---
                    Circle()
                        .fill(sunColor.opacity(0.6))
                        .frame(width: 50, height: 50) // 本体より少しだけ大きく
                        .blur(radius: 10) // ほどよくぼかす
                    
                    // --- 3層目：太陽本体 ---
                    Circle()
                        .fill(
                            // 中心から外側へのグラデーションで立体感を出す
                            RadialGradient(
                                // 中心は明るいクリーム色、外側は指定の黄金色
                                colors: [ sunColor],
                                center: .center,
                                startRadius: 5,  // 中心の明るい部分の範囲
                                endRadius: 30    // 本体の半径(60の半分)
                            )
                        )
                        .frame(width: 60, height: 60)
                }
                
                
                
                //回転で位置を動かす
                    .offset(y: -radius)
                    .rotationEffect(.degrees(sunAngle)) // 中心を軸に回転させる
                // 指でドラッグしたときの処理
                    .gesture(
                        DragGesture()//ドラッグの動きにだけ反応してねという指定
                            .onChanged { value in//指が動くたびにこれを実行
                                // ① ドラッグ開始時に、その時点の角度を記憶する
                                if initialDragAngle == nil {
                                    initialDragAngle = sunAngle
                                }
                                
                                // ② 指の移動量(ピクセル)を、角度(度)に変換する
                                // 「画面の幅ぶん動かしたら、約100度動く」くらいの感度に設定
                                // この 100.0 という数字を大きくすると感度が上がり、小さくすると下がる
                                let angleChange = Double(value.translation.width / geometry.size.width) * 100.0
                                
                                // ③ 「開始時の角度 + 変化した角度」で新しい角度を計算
                                if let startAngle = initialDragAngle {
                                    let newAngle = startAngle + angleChange
                                    
                                    // 角度が行き過ぎないように制限（-45度〜45度）
                                    if newAngle > -45 && newAngle < 45 {
                                        sunAngle = newAngle
                                    }
                                }
                            }
                            .onEnded { _ in
                                // ④ ドラッグが終わったら記憶していた角度をリセット
                                initialDragAngle = nil
                            }
                    )
            }
            //画面のど真ん中に、太陽セットの中心を合わせろという命令
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        // 太陽が見切れないように余白を取る（よくわからないけど、これがないとレイアウトが崩壊するらしい）
        .frame(height: 600)
    }
}

#Preview {
    // プレビュー用に仮の変数を用意
    struct PreviewWrapper: View {
        @State var angle: Double = 0
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea() // 背景を暗くして見やすく
                
                VStack {
                    Spacer()
                    // ここに作った部品を表示
                    SunSliderView(sunAngle: $angle)
                    
                    Text("現在の角度: \(Int(angle))°")
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
            }
        }
    }
    return PreviewWrapper()}
