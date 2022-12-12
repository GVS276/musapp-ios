//
//  SectionViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import Foundation

class SectionViewModel: ObservableObject
{
    @Published var list = [SectionBlock]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    init(id: String)
    {
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveBlocks(id: id)
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    private func receiveBlocks(id: String)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKSection.shared.request(sectionId: id, count: 100) { section, result in
            
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
