//
//  SearchViewModel.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import Foundation

class SearchViewModel: ObservableObject
{
    @Published var list = [AudioModel]()
    @Published var listSuggestion = [Suggestion]()
    @Published var isAllowLoading = false
    @Published var isRequestStatus: RequestLoadingStatus = .None
    
    private let model = VKViewModel.shared
    private var token = ""
    private var secret = ""
    private var query: String = ""
    
    private let maxCount = 50
    
    init()
    {
        if let info = UIUtils.getInfo()
        {
            self.token = info["token"] as! String
            self.secret = info["secret"] as! String
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.receiveSuggestions()
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
    
    func startReceiveAudio(q: String)
    {
        self.query = q
        
        self.list.removeAll()
        
        self.isAllowLoading = true
        
        self.receiveAudio(offset: 0)
    }
    
    func clearSearch()
    {
        self.query.removeAll()
        
        self.list.removeAll()
        
        self.isAllowLoading = false
        
        self.isRequestStatus = .None
    }
    
    func receiveAudio(offset: Int)
    {
        if !self.isAllowLoading {
            return
        }
        
        if self.isRequestStatus == .Receiving {
            return
        } else {
            self.isRequestStatus = .Receiving
        }
        
        self.model.searchAudio(token: self.token,
                               secret: self.secret,
                               q: self.query, count: self.maxCount, offset: offset) { count, list, result in
            DispatchQueue.main.async {
                switch result {
                case .ErrorInternet:
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "Problems with the Internet")
                case .ErrorRequest:
                    self.isAllowLoading = false
                    self.isRequestStatus = .Error
                    
                    Toast.shared.show(text: "An error occurred while accessing the list")
                case .Success:
                    if let list = list {
                        
                        if list.isEmpty
                        {
                            self.isAllowLoading = false
                            self.isRequestStatus = self.list.isEmpty ? .Empty : .ReceivedLast
                        } else {
                            self.uniquedList(list: list)
                            self.isAllowLoading = count > self.maxCount
                            self.isRequestStatus = .Received
                        }
                        
                    }
                }
            }
        }
    }
    
    private func uniquedList(list: [AudioModel])
    {
        // если главный список пуст то добавим в него новые данные
        if self.list.isEmpty
        {
            self.list.append(contentsOf: list)
            return
        }
        
        // временный список
        var temp = [AudioModel]()
        
        // проверяем данные на повтороение в главном списке
        list.forEach { model in
            if !self.list.contains(where: {$0.audioId == model.audioId}) {
                temp.append(model)
            }
        }
        
        // заносим новый данные в главный список
        self.list.append(contentsOf: temp)
        
        // очищаем временный список
        temp.removeAll()
    }
    
    private func receiveSuggestions()
    {
        model.getSearchSuggestions(token: token,
                                   secret: secret) { list, result in
            
           DispatchQueue.main.async {
               
               guard result == .Success else {
                   return
               }
               
               guard let list = list else {
                   return
               }
                
               self.listSuggestion.removeAll()
               self.listSuggestion.append(contentsOf: list)
               
            }
        }
    }
}
