//
//  Flower3DView.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import SwiftUI
import RealityKit

struct Flower3DView: View {
    var stepCount: Int
    var scale: Float = 1.0
    var isRotating: Bool = false
    
    // ★ここがポイント！
    // モデルを読み込んだら、この変数に入れます。
    // 最初は空っぽ(nil)にしておくことで、画面をすぐに表示できます。
    @State private var loadedModel: ModelEntity? = nil
    
    // 今どのモデルを表示しているか覚えておく変数
    @State private var currentModelName: String = ""
    
    var flowerModelName: String {
        switch stepCount {
        case 0..<4000: return "Flower1"
        case 4000..<8000: return "Flower2"
        default: return "Flower3"
        }
    }
    
    var body: some View {
        RealityView { content in
            // ---------------------------------------------------------
            // 1. 初期設定 (make)
            // ---------------------------------------------------------
            let anchor = AnchorEntity()
            anchor.name = "FlowerAnchor"
            content.add(anchor)
            
            // 回転台を作る
            let turntable = Entity()
            turntable.name = "Turntable"
            anchor.addChild(turntable)
            
            // ライト
            let light = DirectionalLight()
            light.light.intensity = 1000
            light.look(at: [0,0,0], from: [1, 1, 1], relativeTo: nil)
            anchor.addChild(light)
            
            // ★回転ロジック（シンプル版）
            // 難しい System クラスを使わず、ここで直接回します。
            // "turntable" という変数をこの中で使うことで、確実に動きます。
            _ = content.subscribe(to: SceneEvents.Update.self) { event in
                // 1秒間に進む時間
                let deltaTime = Float(event.deltaTime)
                
                // 回転台を回す (1秒間に1.5ラジアン進む)
                // isRotatingフラグを見る代わりに、回転台にモデルが乗っているか等で判断もできますが
                // ここではシンプルに「Turntableがあれば回す」動きにします
                // （※外部からの isRotating 制御は update で行います）
                
                // 「RotatingFlag」という名前の部品がついている時だけ回す
                if turntable.components.has(RotatingFlag.self) {
                    let speed: Float = 1.5
                    let angle = speed * deltaTime
                    let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                    turntable.orientation *= rotation
                }
            }
            
        } update: { content in
            // ---------------------------------------------------------
            // 2. 更新処理 (update)
            // ---------------------------------------------------------
            guard let anchor = content.entities.first(where: { $0.name == "FlowerAnchor" }),
                  let turntable = anchor.findEntity(named: "Turntable") else { return }
            
            // ★モデルの表示
            // 裏側で読み込みが完了して `loadedModel` に中身が入ったら、ここに表示します
            if let model = loadedModel, model.name == flowerModelName {
                
                // すでに回転台に同じモデルが乗っていなければ乗せる
                if turntable.children.isEmpty || turntable.children.first?.name != model.name {
                    turntable.children.removeAll()
                    
                    // サイズや設定を適用
                    FlowerModelConfigurator.configure(model: model, name: flowerModelName)
                    model.scale *= scale
                    
                    turntable.addChild(model)
                }
            }
            
            // ★回転スイッチの制御
            // スイッチONなら「RotatingFlag」という目印をつける -> makeの中の処理が反応して回る
            if isRotating {
                if !turntable.components.has(RotatingFlag.self) {
                    turntable.components.set(RotatingFlag())
                }
            } else {
                turntable.components.remove(RotatingFlag.self)
                turntable.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
            }
            
        }
        // ---------------------------------------------------------
        // ★3. 裏側で読み込む処理 (task)
        // ---------------------------------------------------------
        // これがあるおかげで、画面が固まりません！
        .task(id: flowerModelName) {
            // モデル名が変わるたびに実行されます
            
            // もしすでに正しいモデルを持っていたら何もしない
            if loadedModel?.name == flowerModelName { return }
            
            // 読み込み開始（時間がかかる処理）
            if let model = try? await ModelEntity(named: flowerModelName) {
                model.name = flowerModelName
                
                // 読み終わったら、メインの変数に入れる（→ updateが呼ばれて表示される）
                self.loadedModel = model
            } else {
                print("失敗: \(flowerModelName) の読み込みに失敗しました")
            }
        }
    }
}

// 回転制御のための簡単な目印（これだけでOK）
struct RotatingFlag: Component {}

// プレビュー
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        Flower3DView(stepCount: 10000, scale: 2.0, isRotating: true)
            .frame(height: 300)
    }
}
