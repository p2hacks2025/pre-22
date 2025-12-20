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
        
        // ★以前の「一括でピンクにする処理」は削除しました
        // applyPinkGemMaterial(to: model)
        
        switch name {
        case "Flower1":
            // ---------------------------------------------------
            // Flower1 (芽): #C0E8F0 (ペールシアン)
            // R:192, G:232, B:240 -> 0.75, 0.91, 0.94
            // ---------------------------------------------------
            let color1 = UIColor(red: 0.75, green: 0.91, blue: 0.94, alpha: 1.0)
            applyGemMaterial(to: model, color: color1)
            
            // --- Flower1 (蕾) の調整 ---
            // (いただいたコードの設定を維持)
            model.orientation = simd_quatf(angle: .pi, axis: [0, 0, 1])
            model.scale = SIMD3<Float>(0.003, 0.003, 0.003)
            model.position = SIMD3<Float>(0, 0.5, 0)
            
        case "Flower2":
            // ---------------------------------------------------
            // Flower2 (蕾): #F8C8DC (ペールピンク)
            // R:248, G:200, B:220 -> 0.97, 0.78, 0.86
            // ---------------------------------------------------
            let color2 = UIColor(red: 0.97, green: 0.78, blue: 0.86, alpha: 1.0)
            applyGemMaterial(to: model, color: color2)
            
            // --- Flower2 (小花) の調整 ---
            // (いただいたコードの傾き補正・位置調整を維持)
            
            // Z軸回転（左右の補正）: 0.3ラジアン
            let rotationZ = simd_quatf(angle: 0.3, axis: [0, 0, 1])
            
            // X軸回転（手前へのお辞儀）: 0.5ラジアン
            let rotationX = simd_quatf(angle: 0.5, axis: [1, 0, 0])
            
            // 回転を合成
            model.orientation = rotationX * rotationZ
            
            model.scale = SIMD3<Float>(0.002, 0.002, 0.002)
            // 位置調整 (x: 0.05)
            model.position = SIMD3<Float>(0.05, -0.3, 0)
            
        case "Flower3":
                    // ---------------------------------------------------
                    // Flower3 (花): 色を微調整しました！
                    // 変更前: #DCD0FF (白っぽいラベンダー)
                    // 変更後: #D1B2F2 (上品なライラック)
                    // 緑(Green)を少し減らすことで、白さを抑えて紫色を少し主張させました
                    // ---------------------------------------------------
                    let color3 = UIColor(red: 0.82, green: 0.70, blue: 0.95, alpha: 1.0)
                    applyGemMaterial(to: model, color: color3)
                    
                    // サイズ・位置調整 (そのまま)
                    model.scale = SIMD3<Float>(0.005, 0.005, 0.005)
                    model.position = SIMD3<Float>(0, 0.15, 0)
            
        default:
            // 想定外のモデルが来た時用
            model.scale = SIMD3<Float>(0.1, 0.1, 0.1)
        }
    }
    
    // 2. 汎用的な宝石素材にする関数
    // ★引数で「color」を受け取れるように変更しました
    static func applyGemMaterial(to entity: Entity, color: UIColor) {
        
        if let modelEntity = entity as? ModelEntity, modelEntity.model != nil {
            
            // 受け取った色を使って素材を作る
            let material = SimpleMaterial(
                color: color,      // 個別の色
                roughness: 0.0,    // ツルツル
                isMetallic: false  // 宝石感
            )
            
            // 素材を適用
            let count = modelEntity.model?.materials.count ?? 1
            modelEntity.model?.materials = Array(repeating: material, count: count)
        }
        
        // 子供の部品にも同じ処理をする
        for child in entity.children {
            applyGemMaterial(to: child, color: color)
        }
    }
}
