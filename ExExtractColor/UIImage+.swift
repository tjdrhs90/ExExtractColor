//
//  UIImage+.swift
//  ExExtractColor
//
//  Created by ssg on 11/29/24.
//

import UIKit

extension UIImage {
    // https://www.rudrank.com/exploring-core-graphics-extract-prominent-unique-colors-uiimage/
    /// 이미지에서 대표 색상 추출 Extracts the most prominent and unique colors from the image.
    ///
    /// - Parameter numberOfColors: The number of prominent colors to extract (default is 1).
    /// - Returns: An array of UIColors representing the prominent colors.
    func extractColors(numberOfColors: Int = 1) throws -> [UIColor] {
        // Ensure the image has a CGImage
        guard let _ = self.cgImage else {
            throw NSError(domain: "Invalid image", code: 0, userInfo: nil)
        }
        
        let size = CGSize(width: 100, height: 100 * self.size.height / self.size.width)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            throw NSError(domain: "Failed to resize image", code: 0, userInfo: nil)
        }
        UIGraphicsEndImageContext()
        
        guard let inputCGImage = resizedImage.cgImage else {
            throw NSError(domain: "Invalid resized image", code: 0, userInfo: nil)
        }
        
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let data = calloc(height * width, MemoryLayout<UInt32>.size) else {
            throw NSError(domain: "Failed to allocate memory", code: 0, userInfo: nil)
        }
        
        defer { free(data) }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: data, width: width, height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            throw NSError(domain: "Failed to create CGContext", code: 0, userInfo: nil)
        }
        
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        var pixelData = [PixelData]()
        for y in 0..<height {
            for x in 0..<width {
                let offset = ((width * y) + x) * bytesPerPixel
                let r = pixelBuffer[offset]
                let g = pixelBuffer[offset + 1]
                let b = pixelBuffer[offset + 2]
                pixelData.append(PixelData(red: Double(r), green: Double(g), blue: Double(b)))
            }
        }
        
        let clusters = kMeansCluster(pixels: pixelData, k: numberOfColors)
        
        let colors = clusters.map { cluster -> UIColor in
            UIColor(red: CGFloat(cluster.center.red / 255.0),
                    green: CGFloat(cluster.center.green / 255.0),
                    blue: CGFloat(cluster.center.blue / 255.0),
                    alpha: 1.0)
        }
        
        return colors
    }
    
    private struct PixelData {
        let red: Double
        let green: Double
        let blue: Double
    }
    
    private struct Cluster {
        var center: PixelData
        var points: [PixelData]
    }
    
    private func kMeansCluster(pixels: [PixelData], k: Int, maxIterations: Int = 10) -> [Cluster] {
        var clusters = [Cluster]()
        for _ in 0..<k {
            if let randomPixel = pixels.randomElement() {
                clusters.append(Cluster(center: randomPixel, points: []))
            }
        }
        
        for _ in 0..<maxIterations {
            for clusterIndex in 0..<clusters.count {
                clusters[clusterIndex].points.removeAll()
            }
            
            for pixel in pixels {
                var minDistance = Double.greatestFiniteMagnitude
                var closestClusterIndex = 0
                for (index, cluster) in clusters.enumerated() {
                    let distance = euclideanDistance(pixel1: pixel, pixel2: cluster.center)
                    if distance < minDistance {
                        minDistance = distance
                        closestClusterIndex = index
                    }
                }
                clusters[closestClusterIndex].points.append(pixel)
            }
            
            for clusterIndex in 0..<clusters.count {
                let cluster = clusters[clusterIndex]
                if cluster.points.isEmpty { continue }
                let sum = cluster.points.reduce(PixelData(red: 0, green: 0, blue: 0)) { (result, pixel) -> PixelData in
                    return PixelData(red: result.red + pixel.red, green: result.green + pixel.green, blue: result.blue + pixel.blue)
                }
                let count = Double(cluster.points.count)
                clusters[clusterIndex].center = PixelData(red: sum.red / count, green: sum.green / count, blue: sum.blue / count)
            }
        }
        
        return clusters
    }
    
    private func euclideanDistance(pixel1: PixelData, pixel2: PixelData) -> Double {
        let dr = pixel1.red - pixel2.red
        let dg = pixel1.green - pixel2.green
        let db = pixel1.blue - pixel2.blue
        return sqrt(dr * dr + dg * dg + db * db)
    }
}
