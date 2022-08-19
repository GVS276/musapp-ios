//
//  MainView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

struct MainView: View
{
    @EnvironmentObject private var audioPlayer: AudioPlayerModelView
    
    private func binding(_ item: AudioStruct) -> Binding<AudioStruct>
    {
        guard let index = self.audioPlayer.audioList.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Can't find item in array")
        }
        return self.$audioPlayer.audioList[index]
    }
    
    var body: some View
    {
        VStack
        {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0)
                {
                    Text("Options")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .onlyLeading()
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                    
                    self.optionsItem(iconSet: "chart", title: "Popular") {
                        NavigationStackViewModel.shared.push(
                            view: PopularView().environmentObject(self.audioPlayer),
                            tag: "popular-view"
                        )
                    }
                    
                    self.optionsItem(iconSet: "listen", title: "Recommendations") {
                        NavigationStackViewModel.shared.push(
                            view: RecommendationsView().environmentObject(self.audioPlayer),
                            tag: "recom-view"
                        )
                    }
                    
                    self.optionsItem(iconSet: "user", title: "My music") {
                        NavigationStackViewModel.shared.push(
                            view: MyMusicView().environmentObject(self.audioPlayer),
                            tag: "my-music-view"
                        )
                    }
                    
                    Text("Added music")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .onlyLeading()
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                    
                    Text("The list is empty")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .onlyLeading()
                        .padding(.horizontal, 15)
                        .removed(!self.audioPlayer.audioList.isEmpty)
                    
                    ForEach(self.audioPlayer.audioList, id: \.id) { item in
                        self.audioItem(bind: self.binding(item)).id(item.id)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(title: "Home", leading: HStack {
            Button {
                NavigationStackViewModel.shared.push(
                    view: SearchView().environmentObject(self.audioPlayer),
                    tag: "search-view"
                )
            } label: {
                Image("action_search")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            
            Spacer()
        }, trailing: HStack {
            Spacer()
            
            Button {
                NavigationStackViewModel.shared.push(
                    view: AboutView(),
                    tag: "about-view"
                )
            } label: {
                Image("action_settings")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        })
        .background(Color("color_background"))
    }
    
    private func optionsItem(iconSet: String, title: String, clicked: @escaping () -> Void) -> some View
    {
        Button {
            clicked()
        } label: {
            HStack(spacing: 0)
            {
                Image(iconSet)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(10)
                    .background(Color("color_thumb"))
                    .clipShape(Circle())
                    .padding(.horizontal, 15)
                
                Text(title)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image("action_next")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.horizontal, 15)
            }
            .padding(.vertical, 10)
        }
    }
    
    private func audioItem(bind: Binding<AudioStruct>) -> some View
    {
        let item = bind.wrappedValue
        return HStack(spacing: 0)
        {
            Button {
                self.playOrPause(item: item)
            } label: {
                HStack(spacing: 15)
                {
                    AudioThumbView()
                    
                    VStack
                    {
                        Text(item.model.artist)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 16))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                        
                        Text(item.model.title)
                            .foregroundColor(Color("color_text"))
                            .font(.system(size: 14))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .onlyLeading()
                    }
                }
                .padding(.horizontal, 15)
            }
            .buttonStyle(AudioButtonStyle())
            
            Menu {
                Button {
                    self.audioPlayer.deleteAudioFromDB(audioId: item.model.audioId)
                } label: {
                    Text("Delete")
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 16))
                }
            } label: {
                VStack(alignment: .trailing)
                {
                    Image("action_menu")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color("color_text"))
                        .frame(width: 16, height: 16)
                        .padding(.trailing, 10)
                    
                    Text(item.model.duration.toTime())
                        .foregroundColor(Color("color_text"))
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .padding(.trailing, 15)
                }
            }
        }
        .padding(.vertical, 10)
        .background(item.model.audioId == self.audioPlayer.playedModel?.model.audioId ? Color("color_playing") : Color.clear)
    }
    
    private func playOrPause(item: AudioStruct)
    {
        if item.model.audioId == self.audioPlayer.playedModel?.model.audioId
        {
            self.audioPlayer.control(tag: .PlayOrPause)
        } else {
            self.audioPlayer.startStream(model: item)
            self.audioPlayer.setPlayerList(list: self.audioPlayer.audioList)
        }
    }
}
