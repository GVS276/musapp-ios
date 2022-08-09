//
//  LoginView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct LoginView: View
{
    @EnvironmentObject var mainModel: MainViewModel
    
    @State private var login = ""
    @State private var password = ""
    
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
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            self.hideKeyBoard()
        }
    }
    
    private func startExport()
    {
        let model = VKViewModel.shared
        model.doAuth(login: self.login, password: self.password) { info in
            model.refreshToken(token: info.access_token, secret: info.secret) { refresh in
                model.getAudioList(token: refresh.response.token,
                                   secret: refresh.response.secret,
                                   userId: info.user_id) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.showMain()
                        } else {
                            Toast.shared.show(text: "Error Auth")
                        }
                    }
                }
            }
        }
    }
    
    private func showMain()
    {
        // for test
        UserDefaults.standard.set(self.login, forKey: "login")
        UserDefaults.standard.set(self.password, forKey: "password")
        UserDefaults.standard.synchronize()
        // --------
        self.mainModel.showScene(scene: .main)
    }
}
