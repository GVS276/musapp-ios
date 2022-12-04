//
//  ToastView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

class Toast: ObservableObject
{
    static let shared = Toast()
    @Published var showToast = false
    @Published var textToast = ""
    
    func show(text: String)
    {
        self.textToast = text
        withAnimation {
            self.showToast = true
        }
    }
}

struct ToastView: View
{
    @StateObject private var model = Toast.shared
    @State private var timer: Timer? = nil
    
    var body: some View {
        HStack
        {
            Text(self.model.textToast)
                .lineLimit(6)
                .multilineTextAlignment(.center)
                .padding(15)
                .foregroundColor(Color.white)
                .font(.system(size: 16))
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
        }
        .padding(.bottom, 25)
        .padding(.horizontal, 15)
        .transition(.opacity.animation(.linear(duration: 0.5)))
        .onAppear(perform: {
            if timer != nil
            {
                return
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                withAnimation {
                    self.model.showToast = false
                }
            }
        })
        .onDisappear(perform: {
            timer?.invalidate()
            timer = nil
        })
        .removed(!self.model.showToast)
    }
}
