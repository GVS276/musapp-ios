//
//  ItemsSectionAudioView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 13.12.2022.
//

import SwiftUI

struct ItemsSectionAudioView: View
{
    let block: SectionBlock
    let clicked: (_ audio: AudioModel) -> Void
    
    var body: some View
    {
        ForEach(block.audios.indices, id: \.self) { index in
            
            let item = block.audios[index]
            let playedId = "" //audioPlayer.playedModel?.audioId
            
            AudioItemView(item: item, source: .OtherAudio, playedId: playedId) { type in
                switch type {
                case .Menu:
                    MenuDialog.shared.showMenu(audio: item)
                    
                case .Item:
                    clicked(item)
                }
            }
        }
    }
}
