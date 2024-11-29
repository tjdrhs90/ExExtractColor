//
//  UIColor+.swift
//  ExExtractColor
//
//  Created by ssg on 11/29/24.
//

import UIKit

extension UIColor {
    /// RGB 값 추출
    private var toRGB: (r: Int, g: Int, b: Int) {
        var rFloat: CGFloat = 0
        var gFloat: CGFloat = 0
        var bFloat: CGFloat = 0
        var aFloat: CGFloat = 0
        
        self.getRed(&rFloat, green: &gFloat, blue: &bFloat, alpha: &aFloat)
        
        let rInt = Int(rFloat * 255)
        let gInt = Int(gFloat * 255)
        let bInt = Int(bFloat * 255)
        
        return (rInt, gInt, bInt)
    }
    
    /// 헥사 코드 문자열로 변환
    func toHexString() -> String {
        let rgb = toRGB
        return String(format: "#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
    }
    
    /// RGB 문자열로 변환
    func toRGBString() -> String {
        let rgb = toRGB
        return "R: \(rgb.r) G: \(rgb.g) B: \(rgb.b)"
    }
}
