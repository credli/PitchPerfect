//
//  RecordSoundsViewController
//  Pitch Perfect
//
//  Created by Nicholas Credli on 11/23/15.
//  Copyright © 2015 Novium Collective SARL. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var showListButton: UIButton!
    
    let drawerAnimation = DrawerAnimation()
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var formatter: NSDateFormatter!
    var drawerOpen = false
    var listSoundVC: ListSoundsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd-Hmmss"
        
        listSoundVC = storyboard?.instantiateViewControllerWithIdentifier("ListSoundsView") as! ListSoundsViewController
        listSoundVC.delegate = self
        listSoundVC.transitioningDelegate = self
        listSoundVC.modalPresentationStyle = .Custom
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //set the scene's initial state
        recordingInProgress.text = "Tap to Record"
        stopRecordingButton.hidden = true
        showListButton.hidden = false
        recordButton.enabled = true
        recordButton.setImage(UIImage(named: "microphone"), forState: .Normal)
        recordButton.tag = 0
    }

    @IBAction func recordAudio(sender: UIButton) {
        //using the button's tag, we determine state of the button
        //TODO: ideally use a finite state machine here?
        
        if sender.tag == 0 { //when tapped in the initial state
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let now = NSDate()
            let recordingName = formatter.stringFromDate(now) + ".wav"
            print(recordingName)
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)!
            print(filePath)
            
            let session = AVAudioSession.sharedInstance()
            
            //we want to listen to our audio using the phone's outer speakers
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)

            audioRecorder = try! AVAudioRecorder(URL: filePath, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            stopRecordingButton.hidden = false
            recordingInProgress.text = "Recording..."
            sender.setImage(UIImage(named: "pause"), forState: .Normal)
            print("recording was started")
            sender.tag = 1
            
        } else if sender.tag == 1 { //when tapped in recording state
            audioRecorder.pause()
            sender.setImage(UIImage(named: "microphone"), forState: .Normal)
            recordingInProgress.text = "Paused, tap again to resume"
            print("recording was paused")
            sender.tag = 2
            
        } else if sender.tag == 2 { //when tapped in paused state
            audioRecorder.record()
            recordingInProgress.text = "Recording..."
            sender.setImage(UIImage(named: "pause"), forState: .Normal)
            print("recording was resumed")
            sender.tag = 1
            
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        stopRecordingButton.hidden = true
        recordButton.enabled = false
        recordingInProgress.text = "Saving..."
        
        audioRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(true)
        print("recording was stopped")
    }
    
    @IBAction func showList(sender: UIButton) {
        if !drawerOpen {
            presentViewController(listSoundVC, animated: true, completion: nil)
        } else {
            listSoundVC.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecordingSegue" {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
            
        }
    }
}

extension RecordSoundsViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag == true else {
            print("Recording was not successful")
            stopRecordingButton.hidden = true
            return
        }
        recordedAudio = RecordedAudio(url: recorder.url)
        performSegueWithIdentifier("stopRecordingSegue", sender: recordedAudio)
    }
}

extension RecordSoundsViewController : ListSoundsViewControllerDelegate {
    
    func listSoundViewController(listSoundsViewController: ListSoundsViewController, didSelectSoundFile soundFileURL: NSURL) {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            self.recordedAudio = RecordedAudio(url: soundFileURL)
            self.performSegueWithIdentifier("stopRecordingSegue", sender: self.recordedAudio)
        }
    }
}

extension RecordSoundsViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        drawerAnimation.presenting = true
        drawerOpen = true
        showListButton.setImage(UIImage(named: "collapse"), forState: .Normal)
        return drawerAnimation
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        drawerAnimation.presenting = false
        drawerOpen = false
        showListButton.setImage(UIImage(named: "list"), forState: .Normal)
        return drawerAnimation
    }
}