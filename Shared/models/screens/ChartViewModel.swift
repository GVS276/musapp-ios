//
//  ChartViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import Foundation

class ChartViewModel: ObservableObject
{
    @Published var listAudio = [AudioModel]()
    @Published var listBanner = [CatalogBanner]()
    
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
        self.listAudio.removeAll()
        self.listBanner.removeAll()
    }
    
    func refresh()
    {
        self.listAudio.removeAll()
        
        self.listBanner.removeAll()
        
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
            
            catalog?.sections.forEach { section in
                
                guard let sectionUrl = section.url else {
                    
                    DispatchQueue.main.async {
                        
                        self.isAllowLoading = false
                        self.isRequestStatus = .Error
                        
                        Toast.shared.show(text: "An error occurred while accessing the list")
                        
                    }
                    
                    return
                }
                
                if sectionUrl.contains("section=explore") {
                    
                    let id = section.id!
                    self.receiveSection(id: id)
                    
                }
            }
            
        }
    }
    
    private func receiveSection(id: String)
    {
        VKSection.shared.request(sectionId: id) { section, banners, result in
            
            guard result == .Success else {
                
                DispatchQueue.main.async {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                }
                
                return
            }
            
            guard let section = section else {
                
                DispatchQueue.main.async {
                    
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                    
                }
                
                return
            }
            
            if let banners = banners {
                DispatchQueue.main.async {
                    self.listBanner.removeAll()
                    self.listBanner.append(contentsOf: banners)
                }
            }
            
            // ищем блок "Новинки"
            // помечается в двух вариантах, как "new_songs" в url или
            // "music_audios" в dataType
            
            section.blocks.forEach { block in
                
                guard let dataType = block.dataType else {
                    
                    DispatchQueue.main.async {
                        
                        self.isAllowLoading = false
                        self.isRequestStatus = .Error
                        
                        Toast.shared.show(text: "An error occurred while accessing the list")
                        
                    }
                    
                    return
                }
                
                if let buttons = block.buttons,
                   let button = buttons.first(where: {$0.refDataType == "music_audios"})
                {
                    let sectionId = button.sectionId ?? ""
                    
                    DispatchQueue.main.async {
                        self.idNewSongs = sectionId
                    }
                }
                
                if dataType == "music_audios", let ids = block.audiosIds {
                    self.receiveAudiosFromSection(ids: ids)
                    return
                }
            }
            
        }
    }
    
    private func receiveAudiosFromSection(ids: [String])
    {
        VKAudioGetById.shared.request(audios: ids) { list, result in
            
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
                
                self.listAudio.removeAll()
                self.listAudio.append(contentsOf: list)
                
                self.isAllowLoading = false
                self.isRequestStatus = .Received
            }
            
        }
    }
}
