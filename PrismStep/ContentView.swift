//
//  ContentView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/14.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    // インスタンス化（ここで自動的に許可リクエストとデータ取得が走ります）
       @StateObject var stepManager = StepCountManager()
    
    // 表示管理用の変数を追加
        @State var isShowingResult = false
    
    @State var sunAngle: Double = -45.0
    
    // ★追加：ARモードの切り替えスイッチ（最初はON）
        @State var isARMode = true
    
    
    //歩数の箱
   // @State var currentSteps: Int = 4000
    
    var body: some View {
        
        /*VStack {
         Spacer()//レイアウト調整
         GlassDropView(stepCount: currentSteps)//雫を呼び出して表示
         Spacer()
         Text("現在の歩数: \(currentSteps) 歩")
         }*/
        // 歩数の表示
            //Text("\(stepManager.todaySteps) 歩")

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
                    LinearGradient(colors: [
                        // 上：薄い方 (#F4F7F6)
                        Color(red: 0.9, green: 0.9, blue: 0.9),
                        // 下：濃い方 (#5C8694だと色が暗すぎたから調節したよ)
                        Color(red: 0.27, green: 0.55, blue: 0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                    )
                        .ignoresSafeArea()
                    
                    
                    // ▼▼▼ レイアウトの変更ここから ▼▼▼
                                        VStack {
                                            
                                            // ★1. ヘッダーエリア（ボタンとスライダー）
                                            ZStack(alignment: .topTrailing) {
                                                
                                                // 真ん中にスライダー
                                                SunSliderView(sunAngle: $sunAngle)
                                                    .padding(.top, 10)
                                                
                                                // 右上に切り替えボタン
                                                Button(action: {
                                                    // ボタンを押した時の動作
                                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                                    generator.impactOccurred() // ブルッとさせる
                                                    withAnimation(.easeInOut) {
                                                        isARMode.toggle() // ON/OFF切り替え
                                                    }
                                                }) {
                                                    // アイコンの切り替え
                                                    Image(systemName: isARMode ? "camera.fill" : "sparkles")
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(12)
                                                        .background(.ultraThinMaterial) // すりガラス背景
                                                        .clipShape(Circle())
                                                        .shadow(radius: 5)
                                                        // シャボン玉のような枠線
                                                        .overlay(
                                                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                        )
                                                }
                                                .padding(.trailing, 20) // 右端からの隙間
                                                .padding(.top, 20)      // 上からの隙間
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        // ★2. 雫を表示（引数を追加！）
                                        VStack {
                                            // 少し余白を入れて位置調整
                                             Spacer().frame(height: 100)
                                            
                                            // ★ここがエラーの原因だった場所です！
                                            // isARMode: isARMode を追加したことでエラーが消えます
                                            GlassDropView(stepCount: stepManager.todaySteps,
                                                          isARMode: isARMode,
                                                          sunAngle: sunAngle)
                                            .offset(y: -90)
                                            
                                            Spacer()
                                        }
                    
                    // 歩数テキスト
                    VStack{
                        Spacer()
                        
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            
                            // 1. 数字（大きく、細く）
                            Text("\(stepManager.todaySteps)")
                                .font(.system(size: 80, weight: .thin, design: .rounded))
                                .foregroundColor(.white)
                            
                            // 2. 単位（小さく、少し太く）
                            Text("歩")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom,170)//数字を大きくすると上に上がる
                    }
                    
                    VStack {//ボタンの配置
                                    Spacer()
                                    
                                    Button(action: {//「今日を樹録する」ボタン
                                        isShowingResult = true//ボタンを押したらスイッチON
                                    }) {
                                        Text("今日を樹録する")
                                            .font(.system(.title3, design: .rounded))
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(.vertical, 15)
                                            .padding(.horizontal, 40)
                                            .background(Color(red: 0.85, green: 0.65, blue: 0.3)) // 黄土色
                                            .cornerRadius(30)
                                            .shadow(radius: 5)
                                    }
                                    .padding(.bottom, 110)//  タブバーに被らない位置
                                }
                    
                }
                .tabItem {
                    // 下に表示されるアイコンと文字の設定
                    Label("雫", systemImage: "drop")
                }
                
                // --- 2枚目の画面（木） ---
                CollectionTreeView()
                    .tabItem {
                        // 下に表示されるアイコンと文字の設定
                        Label("樹", systemImage: "tree")
                    }
            }
            // タブバーの文字色などを変えたい場合はここに追加設定する
            .tint(Color(red: 0.87, green: 0.67, blue: 0.3)) // 選択されているアイコンの色
            
            if isShowingResult {
                           ResultDialogView(closeAction: {
                               isShowingResult = false//閉じるアクションが呼ばれたらスイッチOFF
                           })
                           .transition(.opacity) // ふわっと表示
                           .zIndex(1)//最前面に表示
                       }
            
        }
    }
}

#Preview {
    ContentView()
}
