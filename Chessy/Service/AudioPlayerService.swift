//
//  AudioPlayerService.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 15.08.2023.
//

import AVFoundation

class AudioPlayerService {
    static let instance = AudioPlayerService()
    private var player: AVAudioPlayer?

    func playSound(capture: Bool = false) {
        guard let url = Bundle.main.url(
            forResource: capture ? "capture" : "move",
            withExtension: "mp3"
        ) else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {}
    }
}
