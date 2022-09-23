//
//  LoginView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct LoginView: View
{
    @EnvironmentObject private var rootStack: RootStack
    
    @State private var login = ""
    @State private var password = ""
    
    private let request = VKViewModel.shared
    
    var body: some View
    {
        VStack(spacing: 15)
        {
            Image("logo_vk")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(width: 200, height: 200)
                .padding(.top, 30)
                .padding(.horizontal, 30)
            
            TextField("", text: self.$login)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .placeholder(shouldShow: self.login.isEmpty, title: "Login", bg: Color("color_toolbar"))
                .cornerRadius(10)
                .padding(.horizontal, 30)
                .onTapGesture {}
            
            SecureField("", text: self.$password)
                .foregroundColor(Color("color_text"))
                .font(.system(size: 16))
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .placeholder(shouldShow: self.password.isEmpty, title: "Password", bg: Color("color_toolbar"))
                .cornerRadius(10)
                .padding(.horizontal, 30)
                .onTapGesture {}
            
            Button {
                self.startExport()
            } label: {
                Text("Start")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: 36)
            }
            .background(.blue)
            .cornerRadius(10)
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text("Version: 1.0 - MusApp")
                .foregroundColor(Color("color_text"))
                .font(.system(size: 12))
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .background(Color("color_background").edgesIgnoringSafeArea(.all))
        .onTapGesture {
            self.hideKeyBoard()
        }
    }
    
    private func startExport()
    {
        request.doAuth(login: self.login, password: self.password) { info, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "Invalid password or login")
                case .Success:
                    if let info = info {
                        self.refreshToken(token: info.access_token, secret: info.secret, userId: info.user_id)
                    }
                }
            }
        }
    }
    
    private func refreshToken(token: String, secret: String, userId: Int64)
    {
        request.refreshToken(token: token, secret: secret) { refresh, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "Invalid password or login")
                case .Success:
                    print("Info updated")
                    if let refresh = refresh {
                        self.showMain(token: refresh.response.token, secret: refresh.response.secret, userId: userId)
                    }
                }
            }
        }
    }
    
    private func showMain(token: String, secret: String, userId: Int64)
    {
        // Info
        UIUtils.updateInfo(token: token, secret: secret, userId: userId)
        
        // Main
        self.rootStack.root = .Main
    }
}
