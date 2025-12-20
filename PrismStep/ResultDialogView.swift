//
//  ResultDialogView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/18.
//

import SwiftUI

struct ResultDialogView: View {
    
    // ★追加1：親から「今の歩数」を受け取る変数
    // これがないと、どの段階の花（芽・蕾・花）を出せばいいかわからないためです
    var stepCount: Int
    // 閉じるボタンが押されたことを、親（ContentView）に伝えるための「スイッチ」
    var closeAction: () -> Void
    
    // 樹を見に行くボタンが押された時のアクション（後で使う）
    // 今はとりあえず closeAction と同じ動きをさせておく
    var navigateToTreeViewAction: () -> Void = {}
    
    // 歩数に応じた花の名前とメッセージを決める（）
    var flowerName: String {
        if stepCount < 4000 { return "芽" } // 芽
        else if stepCount < 8000 { return "蕾" } // 蕾
        else { return "花" } // 花
    }
    
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
                
                // --------------------------------------------------------
                // ★ここを書き換えました！
                // 仮の円(Circle)を消して、回転するFlower3DViewを入れました
                // --------------------------------------------------------
                ZStack {
                    // 背景に少し光を置いておくと、宝石っぽさが際立ちます
                    Circle()
                        .fill(Color.yellow.opacity(0.1)) // 薄い黄色い光
                        .blur(radius: 20)                // ぼかす
                        .frame(width: 200, height: 200)
                    
                    // ★回転する花を表示
                    Flower3DView(
                        stepCount: stepCount, // 歩数を渡す
                        scale: 1.5,           // ダイアログ用に大きくする（6〜8倍くらいが目安）
                        isRotating: true      // ★回転させる！
                    )
                    .frame(height: 250)       // 表示エリアの高さ確保
                    // ※もしモデルが見切れる場合は、scaleを小さくするか、heightを大きくしてください
                }
                
                // 花の名前とメッセージ
                VStack(spacing: 5) {
                    Text(flowerName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2)) // 金色
                    
                    Text("\(stepCount)歩の努力が\n結晶となりました")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                
                // 「樹を見に行く」ボタン
                Button(action: {
                    // ここで画面遷移（後で実装）と閉じる処理を行う
                    navigateToTreeViewAction()
                    closeAction()
                }) {
                    Text("樹を見に行く")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(Color(red: 0.85, green: 0.65, blue: 0.3)) // 黄土色
                        .cornerRadius(30)
                        .shadow(radius: 3)
                }
                
                // 「閉じる」ボタン（テキストのみ）
                Button(action: {
                    closeAction()
                }) {
                    Text("閉じる")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
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
    ResultDialogView(stepCount: 10000, closeAction: {})
}
