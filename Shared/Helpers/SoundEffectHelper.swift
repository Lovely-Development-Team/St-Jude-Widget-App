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
    
    private var drumrollAudioPlayer: AVAudioPlayer?
    
    func setupDrumrollSoundEffect() {
        do {
            if let url = Bundle.main.url(forResource: "drumroll", withExtension: "mp3") {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setActive(false)
                try audioSession.setCategory(.ambient)
                drumrollAudioPlayer = try AVAudioPlayer(contentsOf: url)
                drumrollAudioPlayer?.prepareToPlay()
            }
        } catch {
            print("SoundEffectHelper: \(error.localizedDescription)")
        }
    }
    
    func playDrumrollSoundEffect() {
        drumrollAudioPlayer?.stop()
        drumrollAudioPlayer?.currentTime = 0.0
        drumrollAudioPlayer?.play()
    }
    
    func stop() {
        drumrollAudioPlayer?.stop()
    }
    
}
