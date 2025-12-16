//
//  CollectionTreeView.swift
//  PrismStep
//
//  Created by 三上凪咲 on 2025/12/16.
//

import SwiftUI

struct CollectionTreeView: View {
    var body: some View {
        ZStack {
                    // 背景色（とりあえず緑）
                    Color.green.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("🌲")
                            .font(.system(size: 100))
                        Text("集めたアイテムを表示する木の画面")
                            .font(.title)
                    }
                }
    }
}

#Preview {
    CollectionTreeView()
}
