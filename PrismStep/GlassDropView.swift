//
//  GlassDropView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/15.
//

import SwiftUI

struct GlassDropView: View {
    
    var stepCount: Int//歩数を受け取る
    
    // 太陽の角度を受け取る変数
    // デフォルト値を0にしておくと、プレビューなどが壊れにくいらしい
    var sunAngle: Double = 0
    
    // 歩数に応じて、3段階のサイズを決める
    var dropSize: CGFloat {//CGFloat:座標やサイズを表す時に使う専用の実数型
        switch stepCount {
        case 0..<4000:
            // 0歩 〜 3999歩（小）
            return 120
            
        case 4000..<8000:
            // 4000歩 〜 7999歩（中）
            return 220
            
        default:
            // 8000歩以上（大）
            return 320
        }
    }
    
    var body: some View {
        
        // ▼▼▼ 1. ここで光の位置を計算 ▼▼▼
        // 太陽の角度(-45〜45)を、画面上の比率(0.0〜1.0)に変換
        // -45度なら0.0(左端)、0度なら0.5(真ん中)、45度なら1.0(右端)
        let lightPositionX = 0.5 + (sunAngle / 90)
        
        ZStack{
            // ---1層目：ベースのすりガラス---
            Circle()
                .fill(.white.opacity(0.1))//透明度10%
                .background(.ultraThinMaterial)//すりガラス
                .mask(Circle())//丸く切り抜く
            
            Circle()
                .fill(
                    LinearGradient(
                        // 上（太陽側）は白く強く光り、下に向かって消えていく色
                        colors: [.white.opacity(0.6), .clear],
                        // ★ここが動く！ スタート地点を太陽の向きに合わせる
                        startPoint: UnitPoint(x: lightPositionX, y: 0),
                        endPoint: .bottom
                    )
                )
            
            //---3層目：縁の光と全体の発光---
            Circle()
                .stroke(.white.opacity(0.5), lineWidth: 1)
            // 全体の発光（shadowは外側につくので一番外の層につけるのが良い）
                .shadow(color: .white.opacity(0.8), radius: 10)
            
            
        }
        .frame(width:dropSize,height:dropSize)
        
    }
}

#Preview {
    VStack(spacing:40){
        // 例：左から光が当たっている状態
        GlassDropView(stepCount: 500, sunAngle: -30)
        // 例：正面から光
        GlassDropView(stepCount: 4500, sunAngle: 0)
        // 例：右から光
        GlassDropView(stepCount: 9000, sunAngle: 30)
    }
    .padding()
    
    //横幅と高さを画面いっぱいに広げる
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    //背景色を指定
    .background(
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.8)], // 薄い青〜水色
            startPoint: .topLeading,    // 左上から
            endPoint: .bottomTrailing   // 右下へ
        )
    )
}
