//
//  ProminentColorsView.swift
//  ExExtractColor
//
//  Created by ssg on 11/29/24.
//

import SwiftUI

/// 색상 추출 뷰
struct ProminentColorsView: View {
    @State private var colors: [UIColor] = []
    @State private var errorMessage: String?
    private let image: UIImage = .example
    
    var body: some View {
        VStack {
            if let color = colors.first {
                Text(color.toHexString().hexToColorCategory())
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .padding(.horizontal)
            
            if !colors.isEmpty {
                ColorPaletteView(colors: colors)
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .task {
            do {
                colors = try image.extractColors(numberOfColors: 8)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ProminentColorsView()
}
