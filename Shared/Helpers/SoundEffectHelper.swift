//
//  SoundEffectHelper.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/19/23.
//  Edited by Pierre-Luc Robitaille on 9/6/24
//

import Foundation
import AVFoundation

class SoundEffectHelper {
    static var shared = SoundEffectHelper()

    static let numMykeSounds: Int = 20
    static let numStephenSounds: Int = 11
    static let numShotSounds: Int = 10

    enum SoundEffect: String, CaseIterable {
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

        var fileNames: [String] {
            switch self {
            case .mykeRandom:
                return (1...numMykeSounds).map { "myke\($0)" }
            case .stephenRandom:
                return (1...numStephenSounds).map { "stephen\($0)" }
            case .shotRandom:
                return (1...numShotSounds).map { "shot\($0)" }
            default:
                return [self.rawValue]
            }
        }
    }

    private class SoundEffectPlayer {
        private let audioPlayers: [AVAudioPlayer]
        private var currentAudioPlayer: AVAudioPlayer?

        init(fileNames: [String]) {
            self.audioPlayers = fileNames.compactMap { fileName in
                guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
                    appLogger.warning("Missing sound effect: \(fileName).mp3")
                    return nil
                }
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.prepareToPlay()
                    return audioPlayer
                } catch {
                    appLogger.error("Could not load \(fileName).mp3: \(error.localizedDescription)")
                    return nil
                }
            }
        }

        func play(allowOverlap: Bool) {
            if !allowOverlap {
                self.stop()
            }
            guard let audioPlayer = self.audioPlayers.randomElement() else { return }
            self.currentAudioPlayer = audioPlayer
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }

        func stop() {
            for audioPlayer in self.audioPlayers {
                audioPlayer.stop()
            }
            self.currentAudioPlayer = nil
        }
    }

    private var soundEffects: [SoundEffect: SoundEffectPlayer] = [:]

    // Always play sounds on this background queue thing to avoid blocking main
    private let audioQueue = DispatchQueue(label: "dev.snailedit.stjude.soundEffects")

    func setup() {
        self.audioQueue.async {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, options: [.mixWithOthers])
                try audioSession.setActive(true)
            } catch {
                appLogger.error("Could not configure audio session: \(error.localizedDescription)")
            }

            self.soundEffects = SoundEffect.allCases.reduce(into: [SoundEffect: SoundEffectPlayer]()) { result, soundEffect in
                result[soundEffect] = SoundEffectPlayer(fileNames: soundEffect.fileNames)
            }
        }
    }

    func play(_ soundEffect: SoundEffect, allowOverlap: Bool = false) {
        guard !UserDefaults.shared.disableSounds else { return }
        self.audioQueue.async {
            self.soundEffects[soundEffect]?.play(allowOverlap: allowOverlap)
        }
    }

    func stop(_ soundEffect: SoundEffect? = nil) {
        self.audioQueue.async {
            guard let soundEffect = soundEffect else {
                for player in self.soundEffects.values {
                    player.stop()
                }
                return
            }
            self.soundEffects[soundEffect]?.stop()
        }
    }
}
