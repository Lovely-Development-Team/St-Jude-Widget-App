//
//  SoundEffectHelper.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/19/23.
//  Edited by Pierre-Luc Robitaille on 9/6/24
//

import Foundation
import AVKit

class SoundEffectHelper {
    static var shared = SoundEffectHelper()
    
    static let numMykeSounds: Int = 20
    static let numStephenSounds: Int = 11
    static let numShotSounds: Int = 10
    
    enum SoundEffect: String, CaseIterable {
        case none = ""
        case drumroll = "drumroll"
        case mykeRandom = "mykeRandom"
        case stephenRandom = "stephenRandom"
        case jump = "jump"
        case moof = "moof"
        case softMatt = "softmatt"
        case coin = "coin"
        case underworld = "underworld"
        case mykeNice = "mykenice"
        case stephenNice = "stephennice"
        
        // 2026
        case gameover = "gameover"
        case shotRandom = "shot"
        case winner = "winner"
        case begin = "begin"
        case hit = "hit"
        
        var soundEffectPlayer: SoundEffectPlayer {
            switch self {
            case .mykeRandom:
                return RandomSoundEffectPlayer(soundEffects: (1...numMykeSounds).map({"myke\($0)"}), defaultSoundEffect: "myke1")
            case .stephenRandom:
                return RandomSoundEffectPlayer(soundEffects: (1...numStephenSounds).map({"stephen\($0)"}), defaultSoundEffect: "stephen1")
            case .shotRandom:
                return RandomSoundEffectPlayer(soundEffects: (1...numShotSounds).map({"shot\($0)"}), defaultSoundEffect: "shot1")
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
                        try audioSession.setCategory(.ambient, options: .duckOthers)
                    } else {
                        try audioSession.setCategory(.playback, options: .duckOthers)
                    }
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.prepareToPlay()
                }
            } catch {
                print("SoundEffectHelper: \(error.localizedDescription)")
            }
        }
        
        func playSoundEffect(allowOverlap: Bool = false) {
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
                        try audioSession.setCategory(.ambient, options: .duckOthers)
                    } else {
                        try audioSession.setCategory(.playback, options: .duckOthers)
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
        
        override func playSoundEffect(allowOverlap: Bool = false) {
            if !allowOverlap {
                self.currentAudioPlayer?.stop()
            }
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
            try audioSession.setCategory(.ambient, options: .duckOthers)
        } catch {
            appLogger.debug("Could not set audio session category to playback: \(error.localizedDescription)")
        }
    }
    
    func setToOnlyPlayWhenUnmuted() {
        appLogger.debug("Setting audio session to ambient")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback, options: .duckOthers)
        } catch {
            appLogger.debug("Could not set audio session category to ambient: \(error.localizedDescription)")
        }
    }
    
    func play(_ soundEffect: SoundEffect, allowOverlap: Bool = false) {
        guard let soundEffectPlayer = self.soundEffects[soundEffect] else {
            return
        }
        
        soundEffectPlayer.playSoundEffect(allowOverlap: allowOverlap)
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
