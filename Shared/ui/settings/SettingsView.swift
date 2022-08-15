//
//  SettingsView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct SettingsView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            NavigationToolbar(navTitle: "Settings", navBackVisible: true, navLeading: HStack {
                
            }, navTrailing: HStack {
                
            })
            
            Spacer()
        }
        .background(Color("color_background"))
    }
}
