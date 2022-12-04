//
//  SearchTextField.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 05.09.2022.
//

import SwiftUI

struct SearchTextField: UIViewRepresentable
{
    @Binding var text: String
    
    let onClickReturn: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onClickReturn: onClickReturn)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textView = UITextField()
        textView.delegate = context.coordinator
        textView.autocapitalizationType = .none
        textView.returnKeyType = .search
        
        textView.textColor = UIColor(Color("color_text"))
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        
        textView.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        return textView
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = self.text
    }
    
    class Coordinator: NSObject, UITextFieldDelegate
    {
        var text: Binding<String>
        var onClickReturn: () -> Void
        
        init(text: Binding<String>, onClickReturn: @escaping () -> Void) {
            self.text = text
            self.onClickReturn = onClickReturn
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.onClickReturn()
            return true
        }
        
        @objc
        func textViewDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
       }
    }
}
