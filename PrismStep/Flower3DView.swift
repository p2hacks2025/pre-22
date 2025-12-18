//
//  Flower3DView.swift
//  PrismStep
//
//  Created by 田中琳菜 on 2025/12/18.
//

import SwiftUI

struct Flower3DView: View {
    var stepCount: Int//歩数を受け取る
    
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
       

    }
}

#Preview {
}
