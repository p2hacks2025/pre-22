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
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: trackWidth, height: trackWidth)
                    .rotationEffect(.degrees(180)) // 山なりにするために回転
                
                // 2. 太陽（動かせるつまみ）
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 40, height: 40)
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 0)
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
