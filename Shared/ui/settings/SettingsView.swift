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
            Spacer()
        }
        .viewTitle(title: "About", back: true, leading: HStack {}, trailing: HStack {})
        .background(Color("color_background"))
    }
}
