//
//  FlowerModelConfigurator.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import RealityKit
import UIKit

// モデルごとの「個体差」を吸収して、扱いやすい標準サイズに整える係
struct FlowerModelConfigurator {
    
    // 1. 設定を行うメインの関数
    static func configure(model: Entity, name: String) {
        
        // 影の設定
        model.components.set(GroundingShadowComponent(castsShadow: true))
        
        // ★色を「サクラピンク」の宝石カラーに統一
        applyPinkGemMaterial(to: model)
        
        switch name {
        case "Flower1":
            // --- Flower1 (蕾) の調整 ---
            // 上下逆さまにする（180度回転）
            model.orientation = simd_quatf(angle: .pi, axis: [0, 0, 1])
            model.scale = SIMD3<Float>(0.003, 0.003, 0.003) // 標準サイズ
            model.position = SIMD3<Float>(0, 0.5, 0)       // 中心位置
            
        case "Flower2":
            // --- Flower2 (小花) の調整 ---
            model.scale = SIMD3<Float>(0.002, 0.002, 0.002)
            model.position = SIMD3<Float>(0, -0.3, 0)
            
        case "Flower3":
            // --- Flower3 (大花) の調整 ---
            model.scale = SIMD3<Float>(0.005, 0.005, 0.005)
            model.position = SIMD3<Float>(0, 0.3, 0)
            
        default:
            // 想定外のモデルが来た時用
            model.scale = SIMD3<Float>(0.1, 0.1, 0.1)
        }
    } // ★ここで configure 関数を一度閉じます！
    
    
    // 2. ピンクの宝石素材にする関数
    static func applyPinkGemMaterial(to entity: Entity) {
        
        if let modelEntity = entity as? ModelEntity, modelEntity.model != nil {
            
            // -----------------------------------------------------------
            // ★指定された色：#FFD9E6 (サクラピンク)
            // -----------------------------------------------------------
            let sakuraPink = UIColor(red: 1.0, green: 0.68, blue: 0.80, alpha: 1.0)
            
            // 木の時と同じく、金属(Metaillic)をOFFにすることで
            // 黒ずみを防ぎ、綺麗な透き通った宝石に見せます
            let material = SimpleMaterial(
                color: sakuraPink,
                roughness: 0.0,    // 0にしてツルツルにする
                isMetallic: false  // ガラス/宝石感を出す
            )
            
            // 素材を適用
            let count = modelEntity.model?.materials.count ?? 1
            modelEntity.model?.materials = Array(repeating: material, count: count)
        }
        
        // 子供の部品にも同じ処理をする
        for child in entity.children {
            applyPinkGemMaterial(to: child)
        }
    }
}
