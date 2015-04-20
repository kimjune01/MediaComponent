

import UIKit

class MediaViewController: UIViewController {
  
  var videoCamera: GPUImageVideoCamera!
  var videoView: GPUImageView!
  var movieWriter: GPUImageMovieWriter!
  var textField: UITextField!
  var currentOutputURL: NSURL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.lightGrayColor()
    setupVideoCamera()
    setupVideoView()
    setupMovieWriter()
    setupTextInput()
    
  }
  
  func setupVideoCamera(){
    videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
    videoCamera.outputImageOrientation = .Portrait
    videoCamera.horizontallyMirrorFrontFacingCamera = true
  }
  
  func setupVideoView() {
    videoView = GPUImageView(frame: self.view.bounds)
    //maybe adjust video gravity later... perhaps with crop filter?
    view.addSubview(videoView)
  }
  
  func setupMovieWriter() {
    movieWriter = GPUImageMovieWriter(movieURL: outputURL(), size: CGSizeMake(480.0, 640.0))
    movieWriter.shouldPassthroughAudio = true
  }
  
  func setupTextInput() {
    let textFieldWidth = self.view.bounds.width
    let textFieldHeight: CGFloat = 100
    textField = UITextField(frame: CGRectMake(0, (self.view.bounds.height - textFieldHeight)/2, textFieldWidth, textFieldHeight))
    textField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    textField.delegate = self
    textField.font = UIFont(name: "Helvetica", size: 30)
    textField.attributedText = textFieldFont()
    view.addSubview(textField)
    
  }
  
  func textFieldFont() -> NSAttributedString {
    return NSAttributedString(string: " ", attributes:
      [NSForegroundColorAttributeName: UIColor.whiteColor()])
  }
  
  func outputURL() -> NSURL {
    let timeInterval = NSDate().timeIntervalSince1970
    let outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/" + "\(timeInterval)" + "-movie.m4v")
    currentOutputURL = NSURL(fileURLWithPath: outputString, isDirectory: false)!
    return currentOutputURL
  }
  
  
  override func viewWillAppear(animated: Bool) {
    videoCamera.addTarget(videoView)
    videoCamera.addTarget(movieWriter)
    videoCamera.audioEncodingTarget = movieWriter
    videoCamera.startCameraCapture()
    
  }
  
  override func viewDidAppear(animated: Bool) {
    movieWriter.startRecording()
    
  }
  
  
  
  
  
}

extension MediaViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    movieWriter.finishRecordingWithCompletionHandler {
      mediaMuxer.mux(videoUrl: self.currentOutputURL, and: textField.attributedText!.string)
      println("movieWriter.finishRecordingWithCompletionHandler")
      //TODO: process with string.
    }
    return true
  }
}
