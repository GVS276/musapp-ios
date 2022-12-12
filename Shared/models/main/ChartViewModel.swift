//
//  ChartViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import Foundation

class ChartViewModel: ObservableObject
{
    @Published var list = [SectionBlock]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    @Published var idNewSongs = ""
    
    init()
    {
        // задержка на 200 мс
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.receiveExploreCatalog()
        }
    }
    
    deinit
    {
        self.list.removeAll()
    }
    
    func refresh()
    {
        self.list.removeAll()
        
        self.isAllowLoading = true
        
        self.receiveExploreCatalog()
    }
    
    private func receiveExploreCatalog()
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        VKCatalog.shared.request { catalog, result in
            
            guard result == .Success else {
                
                DispatchQueue.main.async {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                }
                
                return
            }
            
            guard let section = catalog?.sections.first(where: { item in
                
                guard let url = item.url else {
                    return false
                }
                
                return url.contains("section=explore")
            }) else {
                
                return
            }
            
            DispatchQueue.main.async {
                self.receiveSection(id: section.id!)
            }
        }
    }
    
    private func receiveSection(id: String)
    {
        VKSection.shared.request(sectionId: id, count: 5) { section, result in
            
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
