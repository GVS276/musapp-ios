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
    func createToastView() -> some View
    {
        self.overlay(ToastView(), alignment: .bottom)
    }
    
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
    
    func viewTitle<Content, Content2>(_ title: String,
                                      leading: Content,
                                      trailing: Content2) -> some View where Content: View, Content2: View
    {
        self.navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(leading: leading.frame(maxWidth: 100),
                                trailing: trailing.frame(maxWidth: 100))
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

extension AVPlayer
{
    func addProgressObserver(action:@escaping ((Float, Float) -> Void)) -> Any {
        return self.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { time in
            if let duration = self.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                action(Float(time), Float(duration))
            }
        })
    }
    
    func getDurationSeconds() -> Float
    {
        if let duration = self.currentItem?.asset.duration {
            let duration = CMTimeGetSeconds(duration)
            return Float(duration)
        }
        return .zero
    }
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        return Insecure.MD5.hash(data: data).map {String(format: "%02x", $0)}.joined()
    }
    
    var encoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
}
