//
//  SoundEffectHelper.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/19/23.
//

import Foundation
import AVKit

class SoundEffectHelper {
    static var shared = SoundEffectHelper()
    
    enum SoundEffect: String, CaseIterable {
        case drumroll = "drumroll"
        case joe = "joe"
        case honk = "honk"
        case jump = "jump"
        case moof = "moof"
        case softMatt = "softmatt"
        
        var soundEffectPlayer: SoundEffectPlayer {
            return SoundEffectPlayer(soundEffect: self)
        }
    }
    
    class SoundEffectPlayer {
        private var soundEffect: SoundEffect
        private var audioPlayer: AVAudioPlayer?
        
        init(soundEffect: SoundEffect) {
            self.soundEffect = soundEffect
        }
        
        func setupSoundEffect() {
            do {
                if let url = Bundle.main.url(forResource: self.soundEffect.rawValue, withExtension: "mp3") {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setActive(false)
                    try audioSession.setCategory(.ambient)
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.prepareToPlay()
                }
            } catch {
                print("SoundEffectHelper: \(error.localizedDescription)")
            }
        }
        
        func playSoundEffect() {
            self.audioPlayer?.stop()
            self.audioPlayer?.currentTime = 0.0
            self.audioPlayer?.play()
        }
        
        func stop() {
            self.audioPlayer?.stop()
        }
    }
    
    var soundEffects: [SoundEffect: SoundEffectPlayer] = [:]
    
    init() {
        self.setup()
    }
    
    func setup() {
        for soundEffect in SoundEffect.allCases {
            let player = soundEffect.soundEffectPlayer
            player.setupSoundEffect()
            self.soundEffects[soundEffect] = player
        }
    }
    
    func play(_ soundEffect: SoundEffect) {
        guard let soundEffectPlayer = self.soundEffects[soundEffect] else {
            return
        }
        
        soundEffectPlayer.playSoundEffect()
    }
    
    func stop(_ soundEffect: SoundEffect? = nil) {
        guard let soundEffect = soundEffect else {
            for item in self.soundEffects {
                item.value.stop()
            }
            return
        }
        
        guard let soundEffectPlayer = self.soundEffects[soundEffect] else {
            return
        }
        
        soundEffectPlayer.stop()
    }
}
