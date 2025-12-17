//
//  ResultDialogView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/18.
//

import SwiftUI

struct ResultDialogView: View {
    
    // 閉じるボタンが押されたことを、親（ContentView）に伝えるための「スイッチ」
        var closeAction: () -> Void
    
    var body: some View {
        ZStack {
                    // 1. 背景（画面全体を少し暗くする）
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        // 暗い部分をタップしても閉じれるようにする（お好みで）
                        .onTapGesture {
                            closeAction()
                        }
                    
                    // 2. メインの白いカード
                    VStack(spacing: 20) {
                        Text("樹録完了")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2)) // 金色っぽい色
                        
                        // 花の画像（今は仮の円）
                        ZStack {
                            Circle()
                                .fill(Color.pink.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Text("仮の花")
                                .font(.headline)
                        }
                        .padding(.vertical, 10)
                        
                        // 閉じるボタン（画面全体をタップでも閉じれるけど、明示的に置く）
                        /*Button(action: {
                            closeAction()
                        }) {
                            Text("閉じる")
                                .padding()
                        }*/
                    }
                    .frame(width: 300) // カードの幅
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
    }
}

#Preview {
    ResultDialogView(closeAction: {})
}
