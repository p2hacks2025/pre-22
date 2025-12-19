//
//  FlowerModelConfigurator.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import RealityKit

// モデルごとの「個体差」を吸収して、扱いやすい標準サイズに整える係
struct FlowerModelConfigurator {
    
    // 1. 設定を行うメインの関数
    static func configure(model: Entity, name: String) {
        
        // 影の設定
        model.components.set(GroundingShadowComponent(castsShadow: true))
        
        switch name {
        case "Flower1":
            // --- Flower1 (蕾) の調整 ---
            model.scale = SIMD3<Float>(0.093, 0.093, 0.093) // 標準サイズ
            model.position = SIMD3<Float>(0, -0.1, 0)      // 中心位置
            
        case "Flower2":
            // --- Flower2 (小花) の調整 ---
            model.scale = SIMD3<Float>(0.002, 0.002, 0.002)
            model.position = SIMD3<Float>(0, -0.5, 0)
            
        case "Flower3":
            // --- Flower3 (大花) の調整 ---
            model.scale = SIMD3<Float>(0.005, 0.005, 0.005)
            model.position = SIMD3<Float>(0, -0.005, 0)
            
        default:
            // 想定外のモデルが来た時用
            model.scale = SIMD3<Float>(0.1, 0.1, 0.1)
        }
    }
}
