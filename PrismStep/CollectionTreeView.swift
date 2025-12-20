//
//  CollectionTreeView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/16.
//

import SwiftUI
import RealityKit

struct CollectionTreeView: View {
    
    // 親から受け取るリスト
    var flowers: [CollectedFlower]
    
    // グリッドのレイアウト設定（小さめのアイコンを並べる）
    let columns = [
        GridItem(.adaptive(minimum: 150)) // 幅80くらいのアイテムを詰め込む
    ]
    
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
                    // ★調整係（Configurator）を呼び出す
                    //ここでクリスタル化・サイズ・位置調整が全部適用されます
                    TreeModelConfigurator.configure(model: treeEntity)
                    // 画面に追加する
                    content.add(treeEntity)
                    //ライト（照明）を追加（これがないと真っ暗になることがある）
                    let light = DirectionalLight()
                    light.light.intensity = 1000 // 明るさ
                    light.look(at: [0,0,0], from: [2, 5, 2], relativeTo: nil)
                    content.add(light)
                }else {
                    print("エラー：木のモデルが見つかりません。ファイル名を確認してください！")
                }
            }
            
            // ▼▼▼ 2. 手前：獲得したアイテムリスト（左上に表示） ▼▼▼
            //VStack(alignment: .leading) { // 左寄せ
            
            if !flowers.isEmpty {
                
                // スクロールできるエリア
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        
                        // リストの中身を一個ずつ取り出して表示
                        ForEach(flowers) { flower in
                            // 小さい3Dの花を表示
                            Flower3DView(stepCount: flower.stepCount, scale: 1.8, isRotating: true)
                                .frame(width: 100, height: 100)
                            // yをプラスにすると下へ、マイナスにすると上へ動きます
                                .offset(x:-20,y: -120)
                            //.background(Material.ultraThin) // すりガラス風の丸背景（個別に適用）
                            //.clipShape(Circle())
                            //.shadow(radius: 5)
                            
                        }
                    }
                    .padding()
                    // ★ここを追加！数字を大きくするほど下に下がります
                    .padding(.top, 300)
                }
                // .frame(maxHeight: 200) // リストの高さ（画面全体を埋めないように制限）
                
                // .padding()
            }
            
            Spacer() // 残りのスペースを空けて、リストを上に押しやる
        }
        // 画面の幅いっぱいに広げて、左上（topLeading）に寄せる
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}


#Preview {
    CollectionTreeView(flowers: [
        CollectedFlower(stepCount: 3000), // 芽
        CollectedFlower(stepCount: 8500), // 花
        CollectedFlower(stepCount: 5000)  // 蕾
    ])
}
