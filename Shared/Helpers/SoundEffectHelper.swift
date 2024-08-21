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
        case none = ""
        case drumroll = "drumroll"
        case mykeRandom = "mykeRandom"
        case stephenRandom = "stephenRandom"
        case jump = "jump"
        case moof = "moof"
        case softMatt = "softmatt"
        case coin = "coin"
        
        var soundEffectPlayer: SoundEffectPlayer {
            switch self {
            case .mykeRandom:
                return RandomSoundEffectPlayer(soundEffects: ["honk","balls","wow","yes","turtles"], defaultSoundEffect: "honk")
            case .stephenRandom:
                return RandomSoundEffectPlayer(soundEffects: ["joe","constitution"], defaultSoundEffect: "joe")
            default:
                return SoundEffectPlayer(soundEffect: self)
            }
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
                    if UserDefaults.shared.playSoundsEvenWhenMuted {
                        try audioSession.setCategory(.playback, options: .mixWithOthers)
                    } else {
                        try audioSession.setCategory(.ambient)
                    }
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
    
    class RandomSoundEffectPlayer: SoundEffectPlayer {
        private var soundEffectList: [String]
        private var audioPlayers: [AVAudioPlayer] = []
        
        private var currentAudioPlayer: AVAudioPlayer?
        private var defaultSoundEffect: String
        private var defaultAudioPlayer: AVAudioPlayer?
        
        init(soundEffects: [String], defaultSoundEffect: String) {
            self.soundEffectList = soundEffects
            self.defaultSoundEffect = defaultSoundEffect
            super.init(soundEffect: .none)
        }
        
        func getAudioPlayer(for fileName: String) -> AVAudioPlayer? {
            do {
                if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setActive(false)
                    if UserDefaults.shared.playSoundsEvenWhenMuted {
                        try audioSession.setCategory(.playback, options: .mixWithOthers)
                    } else {
                        try audioSession.setCategory(.ambient)
                    }
                    let newAudioPlayer = try AVAudioPlayer(contentsOf: url)
                    return newAudioPlayer
                } else {
                    return nil
                }
            } catch {
                print("RandomSoundEffectPlayer: \(error.localizedDescription)")
                return nil
            }
        }
        
        override func setupSoundEffect() {
            self.defaultAudioPlayer = self.getAudioPlayer(for: self.defaultSoundEffect)
            for soundEffect in self.soundEffectList {
                if let newPlayer = self.getAudioPlayer(for: soundEffect) {
                    self.audioPlayers.append(newPlayer)
                }
            }
        }
        
        override func playSoundEffect() {
            self.currentAudioPlayer?.stop()
            self.currentAudioPlayer = self.audioPlayers.randomElement() ?? self.defaultAudioPlayer
            self.currentAudioPlayer?.prepareToPlay()
            self.currentAudioPlayer?.currentTime = 0
            self.currentAudioPlayer?.play()
        }
        
        override func stop() {
            self.currentAudioPlayer?.stop()
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
    
    func setToPlayEvenOnMute() {
        appLogger.debug("Setting audio session to playback")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback, options: .mixWithOthers)
        } catch {
            appLogger.debug("Could not set audio session category to playback: \(error.localizedDescription)")
        }
    }
    
    func setToOnlyPlayWhenUnmuted() {
        appLogger.debug("Setting audio session to ambient")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.ambient)
        } catch {
            appLogger.debug("Could not set audio session category to ambient: \(error.localizedDescription)")
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
