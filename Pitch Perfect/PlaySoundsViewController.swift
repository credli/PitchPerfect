//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nicholas Credli on 11/23/15.
//  Copyright © 2015 Novium Collective SARL. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var echoPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        echoPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        echoPlayer.delegate = self
        
        audioEngine = AVAudioEngine()
        
        try! audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl)
    }
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }
    
    @IBAction func playSlow(sender: UIButton) {
        playAtRate(0.5)
    }

    @IBAction func playFast(sender: UIButton) {
        playAtRate(1.5)
    }
    
    @IBAction func playChipmunk(sender: UIButton) {
        playWithVariablePitch(1000)
    }
    
    @IBAction func playVader(sender: UIButton) {
        playWithVariablePitch(-1000)
    }
    
    
    func playAtRate(var rate: Float) {
        if rate < 0.5 {
            rate = 0.5
        }
        if rate > 2.0 {
            rate = 2.0
        }
        
        enableButtons(false)
        
        stopAndResetAudio()
        
        //reset audioPlayer and play from the start
        audioPlayer.stop()
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
        audioPlayer.updateMeters()
    }
    
    //taken from http://sandmemory.blogspot.com/2014/12/how-would-you-add-reverbecho-to-audio.html
    @IBAction func playEcho(sender: UIButton) {
        enableButtons(false)
        
        stopAndResetAudio()
        
        //stop and reset any running audio players
        echoPlayer.stop()
        echoPlayer.currentTime = 0
        audioPlayer.stop()
        audioPlayer.rate = 1.0
        audioPlayer.currentTime = 0
        
        //set the delay effect
        let delay:NSTimeInterval = 0.2
        var echoOffset:NSTimeInterval
        echoOffset = echoPlayer.deviceCurrentTime + delay
        echoPlayer.stop()
        echoPlayer.currentTime = 0
        echoPlayer.volume = 0.5
        
        audioPlayer.play()
        echoPlayer.playAtTime(echoOffset)
    }
    
    @IBAction func playReverb(sender: UIButton) {
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.Cathedral)
        reverbEffect.wetDryMix = 50
        
        playAudioUnitEffect(reverbEffect)
    }
    
    func playWithVariablePitch(pitch: Float) {
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        playAudioUnitEffect(changePitchEffect)
    }
    
    func playAudioUnitEffect(unit: AVAudioUnit) {
        enableButtons(false)
        
        stopAndResetAudio()
        
        //create the audioPlayerNode
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        audioEngine.attachNode(unit)
        
        //connect audioPlayerNode -> unit -> audioEngine.outputNode
        audioEngine.connect(audioPlayerNode, to: unit, format: nil)
        audioEngine.connect(unit, to: audioEngine.outputNode, format: nil)
        
        //schedule the file
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            [unowned self] in
            
            //ensure we re-enable buttons on the main thread
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.enableButtons(true)
            })
        }
        
        try! audioEngine.start()
        audioPlayerNode.play()
    }
    
    func stopAndResetAudio() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func enableButtons(enabled: Bool) {
        stopButton.hidden = enabled
        slowButton.enabled = enabled
        fastButton.enabled = enabled
        chipmunkButton.enabled = enabled
        vaderButton.enabled = enabled
        echoButton.enabled = enabled
        reverbButton.enabled = enabled
    }
    
    @IBAction func stop(sender: UIButton) {
        if audioPlayer.playing {
            audioPlayer.stop()
        }
        
        if echoPlayer.playing {
            echoPlayer.stop()
        }
        
        audioEngine.stop()
        audioEngine.reset()
        
        self.enableButtons(true)
    }
    
    // MARK: - AVAudioPlayer Delegate Methods
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.enableButtons(true)
    }

}
