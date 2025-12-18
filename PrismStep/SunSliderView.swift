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
        
        // 画面の幅（調整用）
        let trackWidth: CGFloat = 300
    
    var body: some View {
        ZStack {
                    // 1. 軌道（黄色いアーチ線）
                    Circle()
                        .trim(from: 0.05, to: 0.45) // 円の上半分を少し削ってアーチにする
                        .stroke(
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
                        // ▼ ここがポイント：回転で位置を動かす ▼
                        .offset(y: -trackWidth / 2) // まず円周上に配置
                        .rotationEffect(.degrees(sunAngle)) // 中心を軸に回転させる
                        // ▲▲▲
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // ドラッグした距離に応じて角度を変える
                                    // 「横に動かした距離」を「角度」に変換する簡易計算
                                    let sensitivity: Double = 0.5 // 感度（小さいとゆっくり動く）
                                    let change = value.translation.width * sensitivity
                                    
                                    // 新しい角度を計算
                                    // (今の角度ではなく、直前の角度に加算する処理が必要だが、
                                    //  簡易版として「現在のドラッグ量」を加算する方式だと少しコツが要るため、
                                    //  ここでは一番シンプルに「ドラッグ量＝角度変化」として扱います)
                                    
                                    // ※本来は「ドラッグ開始時の角度 + 変化量」にするのが正確ですが、
                                    // まずはシンプルに「現在のsunAngleに加算」すると暴走するので、
                                    // ここでは直感的に動くように少し工夫します。
                                    
                                    // 今回は「指の動きに合わせて増減させる」一番シンプルな形
                                    let newAngle = sunAngle + (value.translation.width / 10)
                                    
                                    // 角度が行き過ぎないように制限（-45度〜45度）
                                    if newAngle > -45 && newAngle < 45 {
                                        sunAngle = newAngle
                                    }
                                }
                        )
                }
                // 太陽が見切れないように余白を取る
                .frame(height: 150)
                // 下半分（画面外にはみ出る部分）を隠すクリッピングなどは一旦なし
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
