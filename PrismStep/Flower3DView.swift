//
//  Flower3DView.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import SwiftUI
import RealityKit//3Dモデルを使うのに必要

struct Flower3DView: View {
    var stepCount: Int//歩数を受け取る
    
    // 歩数に応じて、3段階のサイズを決める
        var flowerModelName: String {//CGFloat:座標やサイズを表す時に使う専用の実数型
            switch stepCount {
            case 0..<4000:
                // 0歩 〜 3999歩（花レベル１）
                return "Flower1"
                
            case 4000..<8000:
                // 4000歩 〜 7999歩（花レベル２）
                return "Flower2"
                
            default:
                // 8000歩以上（花レベル３）
                return "Flower3"
            }
        }
    
    var body: some View {
        RealityView { content in
                    // 初期化時の処理（空のアンカーを作っておくなど）
                    let anchor = AnchorEntity()
                    anchor.name = "FlowerAnchor" // 名前をつけてあとで探せるようにする
                    content.add(anchor)
                    
                } update: { content in
                    // ★ここが更新ロジック
                    // 歩数が変わってViewが再描画されるたびに呼ばれます
                    
                    // 1. 土台となるアンカーを取得
                    guard let anchor = content.entities.first(where: { $0.name == "FlowerAnchor" }) else { return }
                    
                    // 2. すでに表示されているモデルが「今の歩数で表示すべきモデル」と同じか確認
                    // (同じなら何もしない＝無駄な再読み込みを防ぐ)
                    if let currentModel = anchor.children.first, currentModel.name == flowerModelName {
                        return
                    }
                    
                    // 3. 違うモデルを表示する必要がある場合、古いものを消す
                    anchor.children.removeAll()
                    
                    // 4. 新しいモデルを読み込んで配置する
                    if let newModel = try? ModelEntity.load(named: flowerModelName) {
                        newModel.name = flowerModelName // 次のチェック用に名前をつけておく
                        
                        // 大きさや位置の調整（必要に応じて変更してください）
                        newModel.scale = SIMD3<Float>(0.5, 0.5, 0.5) // 0.5倍の大きさ
                        newModel.position = SIMD3<Float>(0, -0.1, 0) // 少し下に下げる
                        
                        anchor.addChild(newModel)
                        
                        print("モデルを切り替えました: \(flowerModelName)")
                    } else {
                        print("モデルの読み込みに失敗しました: \(flowerModelName)")
                    }
                }
    }
}

#Preview {
    Text("3000歩 (芽)")
    Flower3DView(stepCount: 3000)
                .frame(height: 200)
            
            Divider()
            
            Text("9000歩 (花)")
    Flower3DView(stepCount: 9000)
                .frame(height: 200)
}
