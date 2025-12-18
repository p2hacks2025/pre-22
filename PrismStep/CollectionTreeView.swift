//
//  CollectionTreeView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/16.
//

import SwiftUI
import RealityKit

struct CollectionTreeView: View {
    var body: some View {
        ZStack {
            // 背景色（とりあえず緑）
            Color.green.opacity(0.2)
                .ignoresSafeArea()
            
            //            VStack {
            //                Text("🌲")
            //                    .font(.system(size: 100))
            //                Text("集めたアイテムを表示する木の画面")
            //                    .font(.title)
            //            }
            //3Dを表示するエリア
            RealityView{ content in
                //try?にすると失敗した時にクラッシュしないで、空っぽを返してくれる。Treeというなのファイルを探してくれる
                if let treeEntity = try? Entity.load(named:"Tree"){
                    // 画面に追加する
                    content.add(treeEntity)
                    // 位置と大きさの調整
                    // [左右(x), 上下(y), 奥行き(z)]
                    treeEntity.position = [0, -2.0, -3.0] // 足元、2メートル奥
                    // 大きさ（最初は小さくしてみる）
                    treeEntity.scale = [0.01, 0.01, 0.01]
                    // 5. ライト（照明）を追加（これがないと真っ暗になることがある）
                    let light = DirectionalLight()
                    light.light.intensity = 1000 // 明るさ
                    light.look(at: [0,0,0], from: [2, 5, 2], relativeTo: nil)
                    content.add(light)
                }else {
                    print("エラー：木のモデルが見つかりません。ファイル名を確認してください！")
                }
            }
        }
    }
}

#Preview {
    CollectionTreeView()
}
