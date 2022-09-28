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
    func placeholder(shouldShow: Bool, title: String,
                     bg: Color = .clear,
                     alignment: Alignment = .center,
                     padding: CGFloat = 10,
                     paddingVertical: CGFloat = 0) -> some View
    {
        self.background(ZStack(alignment: alignment)
        {
            bg
            Text(title)
                .foregroundColor(.secondary)
                .font(.system(size: 16))
                .padding(.horizontal, padding)
                .padding(.vertical, paddingVertical)
                .onlyLeading()
                .hidden(shouldShow ? false : true)
        })
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
}
