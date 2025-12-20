//
//  ContentView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/14.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    @StateObject var stepManager = StepCountManager()
    @State var isShowingResult = false
    @State var sunAngle: Double = -45.0
    @State var isARMode = true
    
    var body: some View {
        
        ZStack {
            // 背景のカメラ映像
            RealityView { content in
                let model = Entity()
                let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
                model.components.set(ModelComponent(mesh: mesh, materials: [material]))
                model.position = [0, 0.05, 0]
                
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .zero))
                anchor.addChild(model)
                content.add(anchor)
                
                content.camera = .spatialTracking
            }
            .edgesIgnoringSafeArea(.all)
            
            TabView {
                // --- 1枚目の画面（雫） ---
                ZStack {
                    // 背景グラデーション
                    LinearGradient(colors: [
                        Color(red: 0.9, green: 0.9, blue: 0.9),
                        Color(red: 0.27, green: 0.55, blue: 0.7)
                    ], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    
                    // まとめて配置するVStack
                    VStack {
                        
                        // ★1. ヘッダーエリア（スライダーのみにする）
                        // ※ボタンはここから削除しました
                        SunSliderView(sunAngle: $sunAngle)
                            .padding(.top, 10)
                        
                        Spacer()
                    }
                    
                    // ★2. 雫とボタンを表示
                    VStack {
                        // 上の余白
                        Spacer().frame(height: 100)
                        
                        // 変更点①：alignmentを削除（または .center にする）
                        // これで「中心合わせ」になるので、雫が大きくなっても基準点がズレません
                        ZStack {
                            
                            // ① 雫（メイン）
                            GlassDropView(stepCount: stepManager.todaySteps,
                                          isARMode: isARMode,
                                          sunAngle: sunAngle)
                            // 歩数が増えて雫が大きくなったら、その分上に引き上げる
                            .offset(y: stepManager.todaySteps >= 8000 ? 0 : (stepManager.todaySteps >= 4000 ? 50 : 100))
                            
                            // ② 切り替えボタン
                           /* Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation(.easeInOut) {
                                    isARMode.toggle()
                                }
                            }) {
                                Image(systemName: isARMode ? "camera.fill" : "sparkles")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }:*/
                            // 変更点②：中心からの位置指定に変更
                            // x:プラスで右へ、y:プラスで下へ移動します
                            // この数字なら、雫が大きくなってもボタンの位置は固定のままです
                            //.offset(x: 80, y: 80)
                        }
                        // 雫全体の位置調整（画面中央より少し下へ）
                        .offset(y: 20)
                        
                        Spacer()
                    }
                    
                    //new切り替えボタン
                    VStack{
                        Spacer()
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            withAnimation(.easeInOut) {
                                isARMode.toggle()
                            }
                        }) {
                            Image(systemName: isARMode ? "camera.fill" : "sparkles")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                        .offset(x: 100, y: -240)
                    }
                    
                    // 3. 歩数テキスト
                    VStack {
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text("\(stepManager.todaySteps)")
                                .font(.system(size: 80, weight: .thin, design: .rounded))
                                .foregroundColor(.white)
                            Text("歩")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 170)
                    }
                    
                    // 4. 樹録ボタン
                    VStack {
                        Spacer()
                        Button(action: {
                            isShowingResult = true
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
                        .padding(.bottom, 110)
                    }
                    
                }
                .tabItem {
                    Label("雫", systemImage: "drop")
                }
                
                // --- 2枚目の画面（木） ---
                CollectionTreeView()
                    .tabItem {
                        Label("樹", systemImage: "tree")
                    }
            }
            .tint(Color(red: 0.87, green: 0.67, blue: 0.3))
            
            if isShowingResult {
                ResultDialogView(closeAction: {
                    isShowingResult = false
                })
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
