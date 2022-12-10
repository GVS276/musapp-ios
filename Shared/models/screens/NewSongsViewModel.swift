//
//  NewSongsViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import Foundation

class NewSongsViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    init(id: String)
    {
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveAudio(id: id)
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveAudio(id: String)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKButtonTracks.shared.request(buttonSectionId: id, count: 100) { list, result in
            
            DispatchQueue.main.async {
                
                guard result == .Success else {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                    return
                }
                
                guard let list = list else {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                    return
                }
                
                self.list.removeAll()
                self.list.append(contentsOf: list)
                
                self.isAllowLoading = false
                self.isRequestStatus = .Received
            }
            
        }
    }
}
