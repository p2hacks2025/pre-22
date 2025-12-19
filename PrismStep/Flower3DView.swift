//
//  Flower3DView.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import SwiftUI
import RealityKit//3Dモデルを使うのに必要

struct Flower3DView: View {
    var stepCount: Int//歩数を受け取る
    // 画面ごとに大きさを変えるための倍率（デフォルトは1.0倍）
        var scale: Float = 1.0
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
                    // 初期化時の処理（空のアンカーを作っておくなど）
                    let anchor = AnchorEntity()
                    anchor.name = "FlowerAnchor" // 名前をつけてあとで探せるようにする
                    content.add(anchor)
                    
                } update: { content in
                    // ★ここが更新ロジック
                    // 歩数が変わってViewが再描画されるたびに呼ばれます
                    
                    guard let anchor = content.entities.first(where: { $0.name == "FlowerAnchor" }) else { return }
                                
                                // すでに表示中のモデル名と、表示したい名前が同じなら何もしない
                                if let currentModel = anchor.children.first, currentModel.name == flowerModelName {
                                    return
                                }
                                
                                // 一旦クリア
                                anchor.children.removeAll()
                                
                                // ★ここから修正：読み込みテスト用のロジック
                                do {
                                    // 1. モデルの読み込みを試みる
                                    let newModel = try ModelEntity.load(named: flowerModelName)
                                    newModel.name = flowerModelName
                                    
                                    // 設定ファイルで調整
                                    FlowerModelConfigurator.configure(model: newModel, name: flowerModelName)
                                    
                                    // ★重要：倍率を適用
                                    newModel.scale *= scale
                                    
                                    // ★重要：位置を少し「奥」にずらす（Z軸をマイナスにする）
                                    // これをやらないと、カメラがモデルの中に埋まって何も見えないことがあります
                                    newModel.position.z = 0.5
                                    
                                    anchor.addChild(newModel)
                                    print("成功: \(flowerModelName) を表示")
                                    
                                } catch {
                                    // 2. もし読み込みに失敗したら「赤い箱」を出す
                                    // これが出たら、ファイル名かターゲット設定が間違っている証拠です
                                    print("失敗: \(flowerModelName) が見つかりません。代わりに赤い箱を出します。")
                                    
                                    let mesh = MeshResource.generateBox(size: 0.2) // 20cmの箱
                                    let material = SimpleMaterial(color: .red, isMetallic: false)
                                    let debugBox = ModelEntity(mesh: mesh, materials: [material])
                                    
                                    debugBox.name = flowerModelName
                                    debugBox.position = SIMD3<Float>(0, 0, -0.5) // 少し奥に置く
                                    
                                    anchor.addChild(debugBox)
                                }
                                
                                // 3. ライト（照明）を追加する
                                // モデルが真っ黒になるのを防ぎます
                                let light = DirectionalLight()
                                light.light.intensity = 1000
                                light.look(at: [0,0,0], from: [1, 1, 1], relativeTo: nil)
                                anchor.addChild(light)
                }
    }
}

#Preview {
    ZStack {
            // 1. 背景をグレーにして、白い花でも見えるようにする
            Color.gray.ignoresSafeArea()
            
            VStack(spacing: 50) {
                
                // 2. 直接数字を入れて、強制的にそれぞれのモデルを表示させる
                
                // 0〜3999歩のテスト（Flower1が出るはず）
                VStack {
                    Text("テスト: 100歩 (Flower1)")
                        .foregroundStyle(.white)
                    Flower3DView(stepCount: 100, scale: 1.0)
                        .frame(height: 150)
                        .background(Color.white.opacity(0.2)) // 枠がわかるように薄く色付け
                }
                
                // 4000〜7999歩のテスト（Flower2が出るはず）
                VStack {
                    Text("テスト: 5000歩 (Flower2)")
                        .foregroundStyle(.white)
                    Flower3DView(stepCount: 5000, scale: 1.0)
                        .frame(height: 150)
                        .background(Color.white.opacity(0.2))
                }
                
                // 8000歩以上のテスト（Flower3が出るはず）
                VStack {
                    Text("テスト: 10000歩 (Flower3)")
                        .foregroundStyle(.white)
                    Flower3DView(stepCount: 10000, scale: 1.0)
                        .frame(height: 150)
                        .background(Color.white.opacity(0.2))
                }
            }
        }
}
