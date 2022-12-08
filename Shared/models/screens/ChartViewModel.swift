//
//  ChartViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 08.12.2022.
//

import Foundation

class ChartViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var isAllowLoading = true
    @Published var isRequestStatus: RequestLoadingStatus = .None
    @Published var idNewSongs = ""
    
    private let model = VKViewModel.shared
    
    private var token = ""
    private var secret = ""
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            
            // задержка на 200 мс
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveExploreCatalog()
            }
        } else {
            self.isAllowLoading = false
            self.isRequestStatus = .Error
        }
    }
    
    deinit
    {
        self.list.removeAll()
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
        
        self.model.getCatologAudio(token: token, secret: secret) { catalog, result in
            
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
        self.model.getCatalogSection(token: token,
                                     secret: secret,
                                     catalogSectionId: id) { section, result in
            
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
        self.model.getAudios(token: token,
                        secret: secret,
                        audios: ids) { list, result in
            
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