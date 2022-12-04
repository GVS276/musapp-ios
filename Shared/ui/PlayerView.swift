//
//  PlayerView.swift
//  musapp (iOS)
//
//  Created by Виктор Губин on 06.08.2022.
//

import SwiftUI

// определим начальное положение плеера на экране от общей длины экрана
let PEEK_PLAYER_TOP: CGFloat = 70 * 2

// Размер мини плеера
let PEEK_PLAYER_SIZE: CGFloat = 70

struct PlayerView: View
{
    @EnvironmentObject var audioPlayer: AudioPlayerModelView
    
    @State private var currentTime: Float = .nan
    @State private var repeatAudio = false
    @State private var randomAudio = false
    @State private var touchedSlider = false
    
    @State private var dragOpacity: CGFloat = 0
    @State private var dragOffset: CGFloat = UIScreen.main.bounds.height - PEEK_PLAYER_TOP
    @State private var lastDragOffset: CGFloat = UIScreen.main.bounds.height - PEEK_PLAYER_TOP
    
    var body: some View
    {
        let end = abs(UIScreen.main.bounds.height / 2)
        let height = UIScreen.main.bounds.height - PEEK_PLAYER_TOP
        
        let drag = DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                // Ограничение для свайпа от начала экрана и конца экрана, дабы не рушить системные жесты
                if value.startLocation.y >= UIScreen.main.bounds.height - (PEEK_PLAYER_SIZE + 20) ||
                   value.startLocation.y <= 20 {
                    return
                }
                
                // Корректируем позицию Y из последнего положения плеера на экране
                let y = lastDragOffset + value.translation.height
                
                // Ограничение при перемещении вью плеера выше нуля
                if y <= 0
                {
                    dragOpacity = 1
                    dragOffset = .zero
                    lastDragOffset = .zero
                    return
                }
                
                // Ограничение при перемещении вью плеера нижу peek плеера
                if y >= height
                {
                    dragOpacity = .zero
                    dragOffset = height
                    lastDragOffset = height
                    return
                }
                
                // Y значение передаем в dragOffset для измнения позиции вью плеера
                dragOffset = y
                
                // Определим процентное соотношения открытости плеера где:
                // 0 - плеер закрыт полностью
                // 1 - плеер открыт полностью
                // если умножить на 100, то будут проценты 0%...100%
                dragOpacity = 1 - min(1, max(0, y / height))
            }
            .onEnded { value in
                let y = value.predictedEndTranslation.height
                
                if y >= end
                {
                    // Анимация закрытия полноэкранного плеера
                    hidePlayer()
                    
                    // Аналог onDestroy
                    closedPlayer()
                } else if lastDragOffset + y < end {
                    // Анимация открытия полноэкранного плеера
                    showPlayer()
                    
                    // Аналог onStart
                    openedPlayer()
                } else if dragOffset > end {
                    
                    // Анимация до-закрытия полноэкранного плеера
                    hidePlayer()
                }
            }
        
        ZStack(alignment: .top)
        {
            // Основной плеер
            contentPlayer
                .opacity(dragOpacity) // Управляем видимостью
            
            // Мини плеер
            peekPlayer
                .opacity(1.0 - dragOpacity) // Управляем видимостью
        }
        .background(Color("color_toolbar")) // основной задний фон
        .offset(y: dragOffset) // положение (сдвиг) плеера на экране
        .animation(.spring(), value: dragOffset) // анимируем dragOffset для spring
        .simultaneousGesture(touchedSlider ? nil : drag) // если задействан жест для перемотки, то отменяем свайп
    }
    
    // Мини плеер - UI
    private var peekPlayer: some View
    {
        HStack(spacing: 20)
        {
            VStack(spacing: 2)
            {
                Text(audioPlayer.playedModel?.artist ?? "Nothing is playing right now")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Text(audioPlayer.playedModel?.title ?? "Select a track")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("color_text"))
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
            
            Button {
                audioPlayer.control(tag: .PlayOrPause)
            } label: {
                Image(audioPlayer.audioPlaying ? "pause" : "play")
                    .renderingMode(.template)
                    .foregroundColor(Color("color_text"))
                    .padding(.trailing, 15)
            }
        }
        .frame(height: PEEK_PLAYER_SIZE)
        .padding(.leading, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            guard dragOpacity == 0 else { return }
            
            showPlayer()
            
            openedPlayer()
        }
    }
    
    // Шапка полноэкранного плеера - UI
    private var headerPlayer: some View
    {
        HStack(spacing: 20)
        {
            Button {
                hidePlayer()
                closedPlayer()
            } label: {
                Image("action_down")
                    .resizable()
                    .frame(width: 32, height: 32)
            }

            VStack
            {
                Text("Album")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                Text(audioPlayer.playedModel?.albumTitle ?? "Unknown")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                
            } label: {
                Image("menu")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.top, 15)
        .padding(.horizontal, 15)
    }
    
    // Полноэкранный плеер - UI
    private var contentPlayer: some View
    {
        VStack(spacing: 0)
        {
            headerPlayer
            
            if let art = audioPlayer.art
            {
                Image(uiImage: art)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
            } else {
                Image("audio")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200)
                    .background(Color("color_thumb_dark"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
            }
            
            Text(audioPlayer.playedModel?.artist ?? "Nothing is playing right now")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal, 30)
            
            Text(audioPlayer.playedModel?.title ?? "Select a track")
                .foregroundColor(.white)
                .font(.system(size: 14))
                .lineLimit(4)
                .multilineTextAlignment(.center)
                .padding(.top, 5)
                .padding(.horizontal, 30)
            
            Spacer()
            
            AudioSliderView(value: currentTime,
                            maxValue: Float(audioPlayer.playedModel?.duration ?? 0),
                            touchedHandler: { touched, currentValue in
                if !touched {
                    audioPlayer.seek(value: currentValue)
                    audioPlayer.play()
                } else {
                    if audioPlayer.audioPlaying {
                        audioPlayer.pause()
                    }
                    currentTime = currentValue
                }
                touchedSlider = touched
            })
                .padding(.bottom, 15)
                .padding(.horizontal, 30)
                .disabled(!audioPlayer.audioPlayerReady)
            
            Text("\(currentTime.toTime())  /  \(audioPlayer.playedModel?.duration.toTime() ?? "--")")
                .foregroundColor(.white)
                .font(.system(size: 12))
                .padding(.bottom, 25)
                .padding(.horizontal, 30)
            
            HStack(spacing: 0)
            {
                Button {
                    randomAudio.toggle()
                    audioPlayer.randomAudio(value: randomAudio)
                } label: {
                    Image(randomAudio ? "random_on" : "random")
                }
                
                Spacer()
                
                Button {
                    audioPlayer.control(tag: .Previous)
                } label: {
                    Image("previous")
                }
                
                Button {
                    audioPlayer.control(tag: .PlayOrPause)
                } label: {
                    Image(audioPlayer.audioPlaying ? "pause_circle" : "play_circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                .padding(.horizontal, 20)
                
                Button {
                    audioPlayer.control(tag: .Next)
                } label: {
                    Image("next")
                }
                
                Spacer()
                
                Button {
                    repeatAudio.toggle()
                    audioPlayer.repeatAudio(value: repeatAudio)
                } label: {
                    Image(repeatAudio ? "repeat_on" : "repeat")
                }
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 30)
        }
        .background(Color(uiColor: audioPlayer.artColor ??
                          UIColor(named: "color_player_default") ?? .clear))
    }
    
    private func initTimer()
    {
        currentTime = audioPlayer.currentTime()
        audioPlayer.initCurrentTime { current in
            currentTime = current
        }
    }
    
    private func openedPlayer()
    {
        repeatAudio = self.audioPlayer.isRepeatAudio()
        randomAudio = self.audioPlayer.isRandomAudio()
        initTimer()
    }
    
    private func closedPlayer()
    {
        audioPlayer.removeCurrentTime()
    }
    
    private func hidePlayer()
    {
        withAnimation(.spring()) {
            dragOpacity = .zero
            dragOffset = UIScreen.main.bounds.height - PEEK_PLAYER_TOP
        }
        
        lastDragOffset = UIScreen.main.bounds.height - PEEK_PLAYER_TOP
    }
    
    private func showPlayer()
    {
        withAnimation(.spring()) {
            dragOpacity = 1
            dragOffset = .zero
        }
        
        lastDragOffset = .zero
    }
}
