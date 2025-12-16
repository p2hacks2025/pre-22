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
        @State var crrentSteps: Int = 8
    
    var body: some View {
        
        VStack {
                Spacer()//レイアウト調整
                GlassDropView(stepCount: crrentSteps)//雫を呼び出して表示
                Spacer()
                Text("現在の歩数: \(crrentSteps) 歩")
        }
        
        RealityView { content in

            // Create a cube model
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
    }

}

#Preview {
    ContentView()
}
