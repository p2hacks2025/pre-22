//
//  ContentView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/14.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    //歩数の箱
    @State var currentSteps: Int = 4000
    
    var body: some View {
        
        /*VStack {
         Spacer()//レイアウト調整
         GlassDropView(stepCount: currentSteps)//雫を呼び出して表示
         Spacer()
         Text("現在の歩数: \(currentSteps) 歩")
         }*/
        ZStack{
            
            RealityView { content in//カメラ画面
                let model = Entity()
                let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
                model.components.set(ModelComponent(mesh: mesh, materials: [material]))
                model.position = [0, 0.05, 0]
                
                // Create horizontal plane anchor for the content
                //            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
                //            anchor.addChild(model)
                // 床を探さず、カメラの位置を基準にする（0, 0, -1 は「目の前1メートル」）
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
                anchor.addChild(model)
                content.add(anchor)
                
                // Add the horizontal plane anchor to the scene
                content.add(anchor)
                
                content.camera = .spatialTracking
                
            }
            .edgesIgnoringSafeArea(.all)
            
            TabView {//勝手に画面の切り替えを行ってくれる便利な機能
                // --- 1枚目の画面（雫） ---
                ZStack {
                    // 背景（水色）
                    LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    
                    // 雫を表示
                    GlassDropView(stepCount: currentSteps)
                    
                    // 歩数テキスト
                    VStack {
                        Spacer()
                        Text("\(currentSteps) 歩")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(.bottom, 50) // タブバーに被らないように少し上げる
                    }
                }
                .tabItem {
                    // 下に表示されるアイコンと文字の設定
                    Label("雫", systemImage: "drop.fill")
                }
                
                // --- 2枚目の画面（木） ---
                CollectionTreeView()
                    .tabItem {
                        // 下に表示されるアイコンと文字の設定
                        Label("木録", systemImage: "leaf.fill")
                    }
            }
            // タブバーの文字色などを変えたい場合はここに追加設定する
            .tint(.blue) // 選択されているアイコンの色
        }
    }
}

#Preview {
    ContentView()
}
