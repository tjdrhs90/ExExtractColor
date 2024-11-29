//
//  ColorPaletteView.swift
//  ExExtractColor
//
//  Created by ssg on 11/29/24.
//

import SwiftUI

/// 색상 팔레트 뷰
struct ColorPaletteView: View {
    let colors: [UIColor]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<colors.count, id: \.self) { index in
                    let uiColor = colors[index]
                    
                    VStack {
                        Rectangle()
                            .fill(Color(uiColor))
                            .frame(height: 60)
                            .cornerRadius(12)
                        
                        Text(uiColor.toHexString())
                        
                        Text(uiColor.toRGBString())
                    }
                    .font(.caption)
                    .foregroundColor(.primary)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ColorPaletteView(colors: [.red, .green, .blue])
}
