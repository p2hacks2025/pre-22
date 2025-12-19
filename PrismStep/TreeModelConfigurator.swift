//
//  TreeModelConfigurator.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/19.
//

import RealityKit
import UIKit

struct TreeModelConfigurator {
    
    // 設定を行うメインの関数
    static func configure(model: Entity) {
        
        // 影の設定
        model.components.set(GroundingShadowComponent(castsShadow: true))
    
        // ★アイス・プラチナムの質感を適用
        applyPlatinumMaterial(to: model)
        
        // サイズと位置の調整
        // （ここは変更なし）
        model.scale = SIMD3<Float>(0.01, 0.01, 0.01)
        model.position = SIMD3<Float>(0, -2.0, -3.0)
    }
    
    // アイス・プラチナムの素材にする関数
    static func applyPlatinumMaterial(to entity: Entity) {
        
        if let modelEntity = entity as? ModelEntity, modelEntity.model != nil {

            // カラーコード #E8F1F5 をRGBに変換
            // R:232, G:241, B:245 -> 0.91, 0.95, 0.96
            let icePlatinum = UIColor(red: 0.91, green: 0.95, blue: 0.96, alpha: 1.0)
            
            // 軽量な SimpleMaterial を使います
            // これなら環境データなしでも綺麗に光ります
            let material = SimpleMaterial(
                color: icePlatinum,
                roughness: 0.05,  // 指定通り：ほぼゼロ（氷のようにツルツル）
                isMetallic: false  // 金属をやめる
            )
            
            // 素材を適用
            let count = modelEntity.model?.materials.count ?? 1
            modelEntity.model?.materials = Array(repeating: material, count: count)
        }
        
        // 子供の部品にも同じ処理をする
        for child in entity.children {
            applyPlatinumMaterial(to: child)
        }
    }
}
