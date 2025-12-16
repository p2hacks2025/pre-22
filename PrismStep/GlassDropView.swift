//
//  GlassDropView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/15.
//

import SwiftUI

struct GlassDropView: View {
    
    var stepCount: Int//歩数を受け取る
    
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
        ZStack{
            Circle()
                .fill(.white.opacity(0.1))//透明度10%
                .background(.ultraThinMaterial)//すりガラス
                .mask(Circle())//丸く切り抜く
                .overlay(//縁の光
                    Circle()
                        .stroke(.white.opacity(0.5),lineWidth:1)
                )
                .shadow(color:.white.opacity(0.8),radius:10)//全体の発光
            
        }
        .frame(width:dropSize,height:dropSize)

    }
}

#Preview {
    VStack(spacing:40){
        GlassDropView(stepCount: 500)   // 小
        GlassDropView(stepCount: 4500)  // 中
        GlassDropView(stepCount: 9000)  // 大
    }
    .padding()
    .background(Color.black)
}
