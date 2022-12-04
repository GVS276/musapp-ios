//
//  UIExtensions.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import AVKit
import SwiftUI
import CryptoKit

extension View
{
    func placeholder(shouldShow: Bool,
                     title: String,
                     backgroundColor: Color = .clear,
                     paddingHorizontal: CGFloat = 10,
                     paddingVertical: CGFloat = 0) -> some View
    {
        self.background(
            ZStack(alignment: .center)
            {
                backgroundColor
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                    .padding(.horizontal, paddingHorizontal)
                    .padding(.vertical, paddingVertical)
                    .hidden(shouldShow ? false : true)
            }
        )
    }
    
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
    
    @ViewBuilder func removed(_ value: Bool) -> some View {
        if !value { self }
    }
    
    func onlyLeading() -> some View
    {
        HStack
        {
            self
            Spacer()
        }
    }
    
    func onlyTrailing() -> some View
    {
        HStack
        {
            Spacer()
            self
        }
    }
    
    func hideKeyBoard()
    {
        UIApplication.shared.endEditing()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        return Insecure.MD5.hash(data: data).map {String(format: "%02x", $0)}.joined()
    }
    
    var encoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

extension Int {
    func addZero() -> String {
        return self < 10 ? "0\(self)" : "\(self)"
    }
}

extension Int32 {
    func toTime() -> String
    {
        if self <= 0
        {
            return "--"
        }
        
        let minutes = Int(self % 3600) / 60
        let seconds = Int(self % 60)
        return "\(minutes.addZero()):\(seconds.addZero())"
    }
}

extension Float {
    func toTime() -> String
    {
        guard !(self.isNaN || self.isInfinite) else {
            return "--"
        }
        
        let minutes = Int(floor(self / 60))
        let seconds = Int(self) % 60
        return "\(minutes.addZero()):\(seconds.addZero())"
    }
}

struct AudioButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        return image.withRenderingMode(self.renderingMode)
    }
    
    func getColorFromImage() -> UIColor?
    {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
        ) else {
            return nil
        }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 3)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        let r = Int(bitmap[0])
        let g = Int(bitmap[1])
        let b = Int(bitmap[2])
        
        var color = rgb(r, g, b)
        let luminance = calculateLuminance(r, g, b)
        
        // 0 - full light, 1 - full dark
        if luminance < 0.2 || luminance > 0.9 {
            color = rgb(100, 100, 100)
        }
        
        return color
    }
    
    private func rgb(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0,
                       green: CGFloat(g) / 255.0,
                       blue: CGFloat(b) / 255.0,
                       alpha: 1.0)
    }
    
    private func calculateLuminance(_ r: Int, _ g: Int, _ b: Int) -> Float
    {
        let rf = Float(r)
        let gf = Float(g)
        let bf = Float(b)
        return Float(1-(0.299*rf + 0.587*gf + 0.114*bf)/255)
    }
}
