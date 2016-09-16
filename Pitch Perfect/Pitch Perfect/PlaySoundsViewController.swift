//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Daniel Riehs on 3/5/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

	var audioPlayer:AVAudioPlayer!
	var receivedAudio:RecordedAudio!

	var audioEngine:AVAudioEngine!
	var audioFile:AVAudioFile!

	override func viewDidLoad() {
		super.viewDidLoad()

		audioEngine = AVAudioEngine()
		audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)

		audioPlayer = try? AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
		audioPlayer.enableRate = true

		//This piece of code sets the sound to always play on the Speakers
		let session = AVAudioSession.sharedInstance()
		do {
			try session.setCategory(AVAudioSessionCategoryPlayback)
		} catch let error as NSError {
			print(error)
		}
		do {
			try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
		} catch let error as NSError {
			print(error)
		}
		do {
			try session.setActive(true)
		} catch let error as NSError {
			print(error)
		}

	 /*   More information about how this all works can be found at this link: https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVAudioSession_ClassReference/index.html#//apple_ref/occ/cl/AVAudioSession1
		*/
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	@IBAction func playSlowAudio(_ sender: UIButton) {
		playAudioWithVariableSpeed(0.5)
	}


	@IBAction func playFastAudio(_ sender: UIButton) {
		playAudioWithVariableSpeed(1.5)
	}


	@IBAction func playChipmunkAudio(_ sender: UIButton) {
		playAudioWithVariablePitch(1000)
	}


	@IBAction func playDarthvaderAudio(_ sender: UIButton) {
		playAudioWithVariablePitch(-1000)
	}


	@IBAction func stopAudioButton(_ sender: AnyObject) {
		stopAudio()
	}


	//For audio for the fast or slow buttons.
	func playAudioWithVariableSpeed(_ audioRate: Float!) {

		//First, stops audio that is currently playing.
		stopAudio()

		audioPlayer.rate = audioRate

		// This statement ensures that the audio file restarts when a new sound effect is pressed.
		audioPlayer.currentTime = 0.0

		audioPlayer.play()
	}


	//Plays audio for the variable pitch buttons.
	func playAudioWithVariablePitch(_ pitch: Float){

		//First, stops audio that is currently playing.
		stopAudio()

		let audioPlayerNode = AVAudioPlayerNode()
		audioEngine.attach(audioPlayerNode)

		let changePitchEffect = AVAudioUnitTimePitch()
		changePitchEffect.pitch = pitch
		audioEngine.attach(changePitchEffect)

		audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
		audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)

		audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
		do {
			try audioEngine.start()
		} catch _ {
		}

		audioPlayerNode.play()
	}


	func stopAudio() {

		//Stops the fast and slow playback.
		audioPlayer.stop()

		//Stops the variable pitch playback.
		audioEngine.stop()
		audioEngine.reset()
	}
}
