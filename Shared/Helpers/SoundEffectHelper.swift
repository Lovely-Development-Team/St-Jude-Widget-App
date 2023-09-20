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
                drumrollAudioPlayer = try AVAudioPlayer(contentsOf: url)
                drumrollAudioPlayer?.prepareToPlay()
            }
        } catch {
            print(error)
        }
    }
    
    func playDrumrollSoundEffect() {
        drumrollAudioPlayer?.stop()
        drumrollAudioPlayer?.currentTime = 0.0
        drumrollAudioPlayer?.prepareToPlay()
        drumrollAudioPlayer?.play()
    }
}
