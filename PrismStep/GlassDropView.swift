//
//  GlassDropView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/15.
//

import SwiftUI

struct GlassDropView: View {
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
        .frame(width:250,height:250)
    }
}

#Preview {
    ZStack{
        Color.black//背景黒
        GlassDropView()
    }
}
