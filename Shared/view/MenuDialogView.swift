//
//  MenuDialogView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 07.09.2022.
//

import SwiftUI

struct MenuDialogView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    @StateObject private var model = MenuDialog.shared
    @State private var dragTranslation: CGFloat = .zero
    @State private var showArtists = false
    
    var body: some View
    {
        // свайп для закрытия диалога
        let end = abs(UIScreen.main.bounds.height / 3)
        let drag = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let y = value.translation.height
                
                if y <= 0
                {
                    self.dragTranslation = .zero
                    return
                }
                
                self.dragTranslation = y
            }
            .onEnded { value in
                if value.predictedEndTranslation.height >= end
                {
                    self.close()
                } else {
                    self.cancel()
                }
            }
        
        VStack(spacing: 0)
        {
            Spacer()
            
            dialog
                .offset(y: self.dragTranslation)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .removed(!self.model.showed)
        }
        .background(Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .removed(!self.model.showed))
        .simultaneousGesture(self.model.showed ? drag : nil)
    }
    
    // создаем диалог
    private var dialog: some View
    {
        VStack(spacing: 0)
        {
            bar
            
            if self.showArtists
            {
                artists
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                menu
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            }
        }
        .background(Color("color_background").ignoresSafeArea(edges: .bottom))
        .onDisappear {
            self.model.clear()
            self.dragTranslation = .zero
            self.showArtists = false
        }
    }
    
    // создаем бар для диалога
    private var bar: some View
    {
        HStack(spacing: 15)
        {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.showArtists = false
                }
            } label: {
                Image("action_back")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .removed(!self.showArtists)
            
            VStack(spacing: 2)
            {
                Text("\(self.model.audio?.artist ?? "Artist")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 5)
                {
                    Image("action_explicit")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .frame(width: 14, height: 14)
                        .removed(!(self.audioPlayer.playedModel?.isExplicit ?? false))
                    
                    Text("\(self.model.audio?.title ?? "Title") • \(self.model.audio?.duration.toTime() ?? "--")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Button {
                self.close()
            } label: {
                Image("action_close")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color("color_toolbar"))
    }
    
    // создаем основное меню
    private var menu: some View
    {
        VStack(spacing: 10)
        {
            let isAddedAudio = self.audioPlayer.isAddedAudio(audioId: self.model.audio?.audioId ?? "")
            self.item(iconSet: isAddedAudio ? "action_delete" : "action_add",
                      title: isAddedAudio ? "Delete from library" : "Add to library")
            {
                guard let audio = self.model.audio else {
                    return
                }
                
                if self.audioPlayer.isAddedAudio(audioId: audio.audioId) {
                    self.audioPlayer.deleteAudioFromDB(audioId: audio.audioId)
                } else {
                    self.audioPlayer.addAudioToDB(model: audio)
                }
                
                close()
            }
            
            self.item(iconSet: "action_artist", title: "Go to artist") {
                guard let audio = self.model.audio else {
                    return
                }
                
                if audio.artists.count > 1
                {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.showArtists = true
                    }
                } else {
                    let item = audio.artists[0]
                    RootStack.shared.pushToView(view: ArtistView(artistModel: item).environmentObject(self.audioPlayer))
                    close()
                }
            }
            .removed(self.model.audio?.artists.isEmpty ?? true)
            
            self.item(iconSet: "action_album", title: "Go to album") {
                guard let audio = self.model.audio else {
                    return
                }
                
                RootStack.shared.pushToView(view: AlbumView(
                    albumId: audio.albumId,
                    albumName: audio.albumTitle,
                    artistName: audio.artist,
                    ownerId: Int(audio.albumOwnerId) ?? 0,
                    accessKey: audio.albumAccessKey).environmentObject(self.audioPlayer))
                
                close()
            }
            .removed(self.model.audio?.albumId.isEmpty ?? true)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }
    
    // создаем список всех исполнителей
    private var artists: some View
    {
        VStack(spacing: 10)
        {
           if let artists = self.model.audio?.artists
            {
                ForEach(artists, id: \.id) { item in
                    self.item(iconSet: "action_next", title: item.name) {
                        RootStack.shared.pushToView(view: ArtistView(artistModel: item).environmentObject(self.audioPlayer))
                        close()
                    }
                    .id(item.id)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
    }
    
    // пункты
    private func item(iconSet: String, title: String, clicked: @escaping () -> Void) -> some View
    {
        Button {
            clicked()
        } label: {
            HStack
            {
                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                
                Spacer()
                
                Image(iconSet)
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            .padding(.vertical, 10)
        }
    }
    
    // управления диалогом
    private func close()
    {
        self.model.hideMenu()
    }
    
    private func cancel()
    {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.dragTranslation = .zero
        }
    }
}

// класс для работы с диалогом
class MenuDialog: ObservableObject
{
    static let shared = MenuDialog()
    @Published var showed = false
    @Published var audio: AudioModel? = nil
    
    func clear()
    {
        self.audio = nil
    }
    
    func showMenu(audio: AudioModel)
    {
        self.audio = audio
        withAnimation(.easeInOut(duration: 0.2)) {
            self.showed = true
        }
    }
    
    func hideMenu()
    {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.showed = false
        }
    }
}
