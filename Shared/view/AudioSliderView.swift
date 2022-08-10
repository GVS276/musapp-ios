//
//  AudioSliderView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.08.2022.
//

import SwiftUI

struct AudioSliderView: UIViewRepresentable
{
    private var value: Binding<Float>
    private var maxValue: Binding<Float>
    private var thumbColor: Color
    private var minTrackColor: Color
    private var maxTrackColor: Color
    private var touchedHandler: ((_ touched: Bool) -> Void)!
    
    init(value: Binding<Float>, maxValue: Binding<Float>,
         thumbColor: Color = .white, minTrackColor: Color = .blue, maxTrackColor: Color = .gray,
         touchedHandler: @escaping ((_ touched: Bool) -> Void))
    {
        self.value = value
        self.maxValue = maxValue
        self.thumbColor = thumbColor
        self.minTrackColor = minTrackColor
        self.maxTrackColor = maxTrackColor
        self.touchedHandler = touchedHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(value: self.value, touchedHandler: self.touchedHandler)
    }
    
    func makeUIView(context: Context) -> UISlider
    {
        let slider = UISlider()
        slider.value = self.value.wrappedValue
        slider.thumbTintColor = UIColor(self.thumbColor)
        slider.minimumTrackTintColor = UIColor(self.minTrackColor)
        slider.maximumTrackTintColor = UIColor(self.maxTrackColor)
        slider.minimumValue = 0
        slider.maximumValue = self.maxValue.wrappedValue == .zero ? 1000 : self.maxValue.wrappedValue

        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(sender:event:)),
            for: .valueChanged
        )

        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context)
    {
        uiView.value = self.value.wrappedValue
        uiView.maximumValue = self.maxValue.wrappedValue == .zero ? 1000 : self.maxValue.wrappedValue
    }
    
    class Coordinator: NSObject
    {
        var value: Binding<Float>
        var touchedHandler: ((_ touched: Bool) -> Void)!

        init(value: Binding<Float>, touchedHandler: @escaping ((_ touched: Bool) -> Void)) {
            self.value = value
            self.touchedHandler = touchedHandler
        }

        @objc
        func valueChanged(sender: UISlider, event: UIEvent) {
            if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    self.setTouched(value: true)
                case .moved:
                    self.value.wrappedValue = sender.value
                case .ended:
                    self.setTouched(value: false)
                default:
                    break
                }
            }
        }
        
        private func setTouched(value: Bool)
        {
            if let callback = self.touchedHandler
            {
                callback(value)
            }
        }
    }
}
