//
//  AudioPlayerService.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 15.08.2023.
//

import AVFoundation

struct AudioPlayerService {
    let moveSoundUrl: URL?
    let captureSoundUrl: URL?

    private var moveAudioPlayer: AVAudioPlayer?
    private var captureAudioPlayer: AVAudioPlayer?

    init(moveSoundUrl: URL?, captureSoundUrl: URL?) {
        self.moveSoundUrl = moveSoundUrl
        self.captureSoundUrl = captureSoundUrl

        do {
            guard let moveSoundUrl = moveSoundUrl,
                  let captureSoundUrl = captureSoundUrl else { return }
            self.moveAudioPlayer = try AVAudioPlayer(contentsOf: moveSoundUrl)
            self.captureAudioPlayer = try AVAudioPlayer(contentsOf: captureSoundUrl)
        } catch {}
    }

    func playSound(capture: Bool = false) {
        if capture {
            captureAudioPlayer?.play()
        } else {
            moveAudioPlayer?.play()
        }
    }
}
