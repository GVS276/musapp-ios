//
//  AudioSliderView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 09.08.2022.
//

import SwiftUI

struct AudioSliderView: UIViewRepresentable
{
    private var value: Float
    private var maxValue: Float
    private var touchedHandler: ((_ touched: Bool, _ currentValue: Float) -> Void)!
    
    init(value: Float, maxValue: Float,
         touchedHandler: @escaping ((_ touched: Bool, _ currentValue: Float) -> Void))
    {
        self.value = value
        self.maxValue = maxValue
        self.touchedHandler = touchedHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(touchedHandler: self.touchedHandler)
    }
    
    func makeUIView(context: Context) -> UISlider
    {
        let slider = UISlider()
        slider.value = self.value
        slider.thumbTintColor = .white
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor(named: "color_max_track") ?? .gray
        slider.minimumValue = 0
        slider.maximumValue = self.maxValue

        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(sender:event:)),
            for: .valueChanged
        )

        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context)
    {
        uiView.value = self.value
        uiView.maximumValue = self.maxValue
    }
    
    class Coordinator: NSObject
    {
        private var touchedHandler: ((_ touched: Bool, _ currentValue: Float) -> Void)!

        init(touchedHandler: @escaping ((_ touched: Bool, _ currentValue: Float) -> Void)) {
            self.touchedHandler = touchedHandler
        }

        @objc
        func valueChanged(sender: UISlider, event: UIEvent) {
            if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    self.setTouched(touched: true, currentValue: sender.value)
                case .moved:
                    self.setTouched(touched: true, currentValue: sender.value)
                case .ended:
                    self.setTouched(touched: false, currentValue: sender.value)
                default:
                    break
                }
            }
        }
        
        private func setTouched(touched: Bool, currentValue: Float)
        {
            if let callback = self.touchedHandler
            {
                callback(touched, currentValue)
            }
        }
    }
}
