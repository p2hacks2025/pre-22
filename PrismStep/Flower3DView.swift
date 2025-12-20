//
//  Flower3DView.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import SwiftUI
import RealityKit//3Dモデルを使うのに必要

// -----------------------------------------------------------------------------
// 1. 回転機能の準備
// -----------------------------------------------------------------------------
struct RotationComponent: Component {
    var speed: Float = 0.02
}

class RotationSystem: System {
    required init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(EntityQuery(where: .has(RotationComponent.self)))
        for entity in entities {
            if let component = entity.components[RotationComponent.self] as? RotationComponent {
                // Y軸（縦）を中心に回転
                let rotation = simd_quatf(angle: component.speed, axis: [0, 1, 0])
                entity.orientation *= rotation
            }
        }
    }
}
// -----------------------------------------------------------------------------
// 回転機能の準備（ここまで）
// -----------------------------------------------------------------------------


struct Flower3DView: View {
    var stepCount: Int//歩数を受け取る
    // 画面ごとに大きさを変えるための倍率（デフォルトは1.0倍）
    var scale: Float = 1.0
    
    // 回転スイッチ
    var isRotating: Bool = false
    
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
            // 初期化
            RotationComponent.registerComponent()
            RotationSystem.registerSystem()
            
            let anchor = AnchorEntity()
            anchor.name = "FlowerAnchor"
            content.add(anchor)
            
            // 回転用の透明な台座
            let turntable = Entity()
            turntable.name = "Turntable"
            anchor.addChild(turntable)
            
        } update: { content in
            
            guard let anchor = content.entities.first(where: { $0.name == "FlowerAnchor" }),
                  let turntable = anchor.findEntity(named: "Turntable") else { return }
            
            // モデル切り替え処理
            if turntable.children.isEmpty || turntable.children.first?.name != flowerModelName {
                
                turntable.children.removeAll()
                
                do {
                    let newModel = try ModelEntity.load(named: flowerModelName)
                    newModel.name = flowerModelName
                    
                    // 設定ファイルで調整（ここで正しい位置にセットされます）
                    FlowerModelConfigurator.configure(model: newModel, name: flowerModelName)
                    
                    // 倍率
                    newModel.scale *= scale
                    
                    // ★修正ポイント1：
                    // 前回ここにあった `newModel.position = ...` を削除しました！
                    // これで Configurator が設定した「正しい位置（中心位置）」が維持されます。
                    
                    // ライト（照明）
                    let light = DirectionalLight()
                    light.light.intensity = 1000
                    light.look(at: [0,0,0], from: [1, 1, 1], relativeTo: nil)
                    anchor.addChild(light)
                    
                    turntable.addChild(newModel)
                    print("成功: \(flowerModelName) を表示")
                    
                } catch {
                    print("失敗: \(flowerModelName) が見つかりません。")
                    let mesh = MeshResource.generateBox(size: 0.2)
                    let material = SimpleMaterial(color: .red, isMetallic: false)
                    let debugBox = ModelEntity(mesh: mesh, materials: [material])
                    debugBox.name = flowerModelName
                    turntable.addChild(debugBox)
                }
            }
            
            // -----------------------------------------------------------------
            // 回転スイッチの制御
            // -----------------------------------------------------------------
            
            // ★修正ポイント2：
            // 「回転する時だけ位置を変える（-0.2など）」という処理も削除しました。
            // 常に同じ場所（Z=0.5）に固定することで、「元の位置で回る」ようになります。
            turntable.position = SIMD3<Float>(0, 0, 0.5)
            
            if isRotating {
                // スイッチON: 回転台に目印をつける
                if !turntable.components.has(RotationComponent.self) {
                    turntable.components.set(RotationComponent())
                }
            } else {
                // スイッチOFF: 目印を外す（止まる）
                turntable.components.remove(RotationComponent.self)
                
                // 向きを正面にリセット
                turntable.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            }
        }
    }
}

// プレビュー
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack(spacing: 50) {
            
            VStack {
                Text("通常モード: 100歩")
                    .foregroundStyle(.white)
                Flower3DView(stepCount: 100, scale: 1.0)
                    .frame(height: 150)
                    .background(Color.white.opacity(0.2))
            }
            
            VStack {
                Text("回転モード: 10000歩")
                    .foregroundStyle(.yellow)
                Flower3DView(stepCount: 10000, scale: 1.0, isRotating: true)
                    .frame(height: 150)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
    }
}
