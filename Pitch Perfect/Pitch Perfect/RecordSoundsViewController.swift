//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Daniel Riehs on 3/4/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

	@IBOutlet weak var recordingInProgress: UILabel!
	@IBOutlet weak var stopButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var resumeButton: UIButton!
  
	var audioRecorder:AVAudioRecorder!
	var recordedAudio:RecordedAudio!

	let recordSettings =
		[AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
		 AVEncoderBitRateKey: 16,
		 AVNumberOfChannelsKey: 2,
		 AVSampleRateKey: 44100.0] as [String : Any]

	override func viewDidLoad() {
		super.viewDidLoad()
		recordingInProgress.text = "Tap Mic to Record"
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	override func viewWillAppear(_ animated: Bool) {
		recordButton.isEnabled = true
		stopButton.isHidden = true
		pauseButton.isHidden = true
		resumeButton.isHidden = true
	}


	@IBAction func recordAudio(_ sender: UIButton) {
		stopButton.isHidden = false
		recordButton.isEnabled = false
		recordingInProgress.text = "Recording..."
		pauseButton.isHidden = false

		let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 

		let currentDateTime = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "ddMMyyyy-HHmmss"
		let recordingName = formatter.string(from: currentDateTime)+".wav"
		let pathArray = [dirPath, recordingName]
		let filePath = NSURL.fileURL(withPathComponents: pathArray)

		let session = AVAudioSession.sharedInstance()
		do {
			try session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)))
		} catch _ {
		}

		do {
			try audioRecorder = AVAudioRecorder(url: filePath!, settings: recordSettings as [String : AnyObject])
		} catch _ {
		}

		audioRecorder.delegate = self
		audioRecorder.isMeteringEnabled = true
		audioRecorder.prepareToRecord()
		audioRecorder.record()
	}


	@IBAction func pauseRecording(_ sender: UIButton) {

		//The pause and resume buttons never display at the same time.
		pauseButton.isHidden = true
		resumeButton.isHidden = false

		recordingInProgress.isEnabled = false
		audioRecorder.pause()
	}


	@IBAction func resumeRecording(_ sender: UIButton) {

		//The pause and resume buttons never display at the same time.
		pauseButton.isHidden = false
		resumeButton.isHidden = true

		recordingInProgress.isEnabled = true
		audioRecorder.record()
	}


	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if (flag){
			recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
			self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
		} else {
			recordingInProgress.text = "Recording Error"
			recordButton.isEnabled = true
			stopButton.isHidden = true
			resumeButton.isHidden = true
			pauseButton.isHidden = true
		}
	}


	//The location of the recorded audio file is stored in a RecordedAudio object.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "stopRecording"){
			let playSoundsVC:PlaySoundsViewController = segue.destination as! PlaySoundsViewController
			let data = sender as! RecordedAudio
			playSoundsVC.receivedAudio = data
		}
	}


	@IBAction func stopRecording(_ sender: UIButton) {
		recordingInProgress.text = "Tap Mic to Record"
		resumeButton.isHidden = true
		pauseButton.isHidden = true
		audioRecorder.stop()
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setActive(false)
		} catch _ {
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
