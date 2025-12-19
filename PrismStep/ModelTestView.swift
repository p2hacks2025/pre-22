//
//  ModelTestView.swift
//  PrismStep
//
//  Created by 実験用.
//

import SwiftUI
import RealityKit

struct ModelTestView: View {
    
    // ★ここを Flower2, Flower3 に書き換えて試してください
    let targetFileName = "Flower3"
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            VStack {
                Text("強制表示テスト: \(targetFileName)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding()
                
                RealityView { content in
                    // 1. ライト（前後左右から照らす）
                    let light = DirectionalLight()
                    light.light.intensity = 2000 // 明るめ
                    light.look(at: [0,0,0], from: [1, 1, 1], relativeTo: nil)
                    content.add(light)
                    
                    let light2 = DirectionalLight()
                    light2.light.intensity = 1000
                    light2.look(at: [0,0,0], from: [-1, 0.5, -1], relativeTo: nil)
                    content.add(light2)
                    
                    // 2. モデル読み込み
                    do {
                        let model = try ModelEntity.load(named: targetFileName)
                        
                        // ★★★ ここが魔法のロジックです ★★★
                        // モデルの境界線（BoundingBox）を取得してサイズを測る
                        let bounds = model.visualBounds(relativeTo: nil)
                        let size = bounds.extents // 幅・高さ・奥行き
                        let maxDimension = max(size.x, max(size.y, size.z)) // 一番長い辺
                        
                        print("--------------------------------------------------")
                        print("🔍 解析結果: \(targetFileName)")
                        print("元の大きさ(m): 幅\(size.x) 高さ\(size.y) 奥行\(size.z)")
                        
                        if maxDimension == 0 {
                            print("⚠️ サイズが0です。モデルデータが空っぽの可能性があります。")
                        } else {
                            // 画面に収まるサイズ（20cm = 0.2m）にするための倍率を計算
                            let targetSize: Float = 0.2
                            let scaleFactor = targetSize / maxDimension
                            
                            print("修正する倍率: \(scaleFactor)倍 にします")
                            
                            // 計算した倍率を適用
                            model.scale = SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor)
                            
                            // 中心位置のズレを修正（ど真ん中に持ってくる）
                            model.position = -bounds.center * scaleFactor
                        }
                        
                        // 念の為、少しだけ手前に回転させて見やすくする
                        // model.orientation = simd_quatf(angle: .pi / 8, axis: [0, 1, 0])
                        
                        content.add(model)
                        print("✅ 表示成功！")
                        print("--------------------------------------------------")
                        
                    } catch {
                        print("❌ 読み込み失敗")
                        // エラー時は赤い箱
                        let mesh = MeshResource.generateBox(size: 0.2)
                        let debugBox = ModelEntity(mesh: mesh, materials: [SimpleMaterial(color: .red, isMetallic: false)])
                        content.add(debugBox)
                    }
                }
                .frame(width: 300, height: 300)
                .background(Color.black.opacity(0.5)) // 背景を少し暗く
            }
        }
    }
}

#Preview {
    ModelTestView()
}
