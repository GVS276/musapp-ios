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
                    
                    self.optionsItem(iconSet: "chart", title: "Popular", destination: PopularView().environmentObject(self.audioPlayer))
                    
                    self.optionsItem(iconSet: "listen", title: "Recommendations", destination: RecommendationsView().environmentObject(self.audioPlayer))
                    
                    self.optionsItem(iconSet: "user", title: "My music", destination: MyMusicView().environmentObject(self.audioPlayer))
                    
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
                        AudioItemView(item: item, playedId: self.audioPlayer.playedModel?.model.audioId) {
                            self.playOrPause(item: item)
                        } menuContent: {
                            Button {
                                self.audioPlayer.deleteAudioFromDB(audioId: item.model.audioId)
                            } label: {
                                Text("Delete")
                                    .foregroundColor(Color("color_text"))
                                    .font(.system(size: 16))
                            }
                        }
                        .id(item.id)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        .viewTitle(title: "Home", leading: HStack {
            PushView {
                SearchView().environmentObject(self.audioPlayer)
            } label: {
                Image("action_search")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
            
            Spacer()
        }, trailing: HStack {
            Spacer()
            
            PushView {
                AboutView()
            } label: {
                Image("action_settings")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
            }
        })
        .background(Color("color_background"))
    }
    
    private func optionsItem<D: View>(iconSet: String, title: String, destination: D) -> some View
    {
        PushView {
            destination
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
