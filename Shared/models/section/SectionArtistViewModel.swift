//
//  SectionArtistViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 12.12.2022.
//

import Foundation

class SectionArtistViewModel: ObservableObject
{
    @Published var list = [SectionBlock]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    init(artistDomain: String)
    {
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveBlocks(artistDomain: artistDomain)
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveBlocks(artistDomain: String)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKArtist.shared.request(artistDomain: artistDomain) { section, result in
            
            DispatchQueue.main.async {
                
                guard result == .Success, let section = section else {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                    return
                }
                
                self.list.removeAll()
                self.list.append(contentsOf: section.blocks)
                
                self.isAllowLoading = false
                self.isRequestStatus = .Received
            }
            
        }
    }
}
