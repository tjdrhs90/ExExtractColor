//
//  String+.swift
//  ExExtractColor
//
//  Created by ssg on 11/29/24.
//

import Foundation

extension String {
    
    /*
     가시광선의 색상 분류에 따라 구분
     HSL (Hue, Saturation, Lightness) 색상 모델로 변환하여 Hue 값을 기준으로 대략적인 범위 구분
     빨간색: 0° ~ 30° 또는 330° ~ 360°
     주황색: 30° ~ 60°
     노란색: 60° ~ 90°
     초록색: 90° ~ 150°
     하늘색/청록색: 150° ~ 210°
     파란색: 210° ~ 270°
     보라색: 270° ~ 330°
     */
    /// 헥사 코드 색상을 그룹으로 분류
    func hexToColorCategory() -> String {
        // 1. Hex 코드를 UIColor로 변환
        var hexFormatted = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexFormatted.hasPrefix("#") {
            hexFormatted.removeFirst()
        }
        
        guard let hexNumber = UInt64(hexFormatted, radix: 16) else {
            return "Invalid Hex Code"
        }
        
        let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hexNumber & 0x0000FF) / 255.0
        
        // 2. RGB를 HSL로 변환
        let max = Swift.max(r, Swift.max(g, b))
        let min = Swift.min(r, Swift.min(g, b))
        let delta = max - min
        
        var hue: CGFloat = 0
        if delta != 0 {
            if max == r {
                hue = (g - b) / delta + (g < b ? 6 : 0)
            } else if max == g {
                hue = (b - r) / delta + 2
            } else if max == b {
                hue = (r - g) / delta + 4
            }
            hue /= 6
        }
        
        hue *= 360 // 0~1 범위를 0~360도로 변환
        
        // 3. Hue 값으로 색상 분류
        switch hue {
        case 0..<30, 330...360:
            return "빨간색 계열"
        case 30..<60:
            return "주황색 계열"
        case 60..<90:
            return "노란색 계열"
        case 90..<150:
            return "초록색 계열"
        case 150..<210:
            return "하늘색/청록색 계열"
        case 210..<270:
            return "파란색 계열"
        case 270..<330:
            return "보라색 계열"
        default:
            return "분류 불가"
        }
    }
}
