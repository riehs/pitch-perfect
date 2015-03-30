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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingInProgress.text = "Tap Mic to Record"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        recordButton.enabled = true
        stopButton.hidden = true
        pauseButton.hidden = true
        resumeButton.hidden = true
    }
    

    @IBAction func recordAudio(sender: UIButton) {
        stopButton.hidden = false
        recordButton.enabled = false
        recordingInProgress.text = "Recording..."
        pauseButton.hidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    

    @IBAction func pauseRecording(sender: UIButton) {
        
        //The pause and resume buttons never display at the same time.
        pauseButton.hidden = true
        resumeButton.hidden = false
        
        recordingInProgress.enabled = false
        audioRecorder.pause()
    }

    
    @IBAction func resumeRecording(sender: UIButton) {
        
        //The pause and resume buttons never display at the same time.
        pauseButton.hidden = false
        resumeButton.hidden = true
        
        recordingInProgress.enabled = true
        audioRecorder.record()
    }
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            recordingInProgress.text = "Recording Error"
            recordButton.enabled = true
            stopButton.hidden = true
            resumeButton.hidden = true
            pauseButton.hidden = true
        }
    }

    
    //The location of the recorded audio file is stored in a RecordedAudio object.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    
    @IBAction func stopRecording(sender: UIButton) {
        recordingInProgress.text = "Tap Mic to Record"
        resumeButton.hidden = true
        pauseButton.hidden = true
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }

}
