//
//  ArtistTracksViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class ArtistTracksViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isLoading = true
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    
    private var isRequest = true
    
    init(artistId: String)
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveAudio(artistId: artistId, count: 50, offset: 0)
            }
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    func receiveAudio(artistId: String, count: Int, offset: Int)
    {
        if !self.isRequest {
            return
        }
        
        self.isRequest = false
        
        self.model.receiveAudioArtist(token: self.token,
                                      secret: self.secret,
                                      artistId: artistId,
                                      count: count,
                                      offset: offset) { list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        guard !list.isEmpty else {
                            self.isLoading = false
                            return
                        }
                        
                        self.isLoading = true
                        self.list.append(contentsOf: list)
                    }
                }
                self.isRequest = true
            }
        }
    }
}
