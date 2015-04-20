
import UIKit
import AVFoundation

let mediaMuxer = MediaMuxer()

class MediaMuxer: NSObject {
   //TODO: combine video and text together.
  //input nsurl and string
  //output avasset
  //or output nsurl of combined asset
  //composition
  var mutableComposition: AVMutableComposition!
  var mutableVideoComposition: AVMutableVideoComposition!
  var mutableAudioMix: AVMutableAudioMix!
  var exportSession: AVAssetExportSession!
  
  override init() {
    super.init()
    mutableComposition = AVMutableComposition()
  }
  
  func mux(#videoUrl:NSURL, and text:String) -> NSURL? {
    let mediaAsset = assetFromURL(videoUrl)
    let videoAssetTrack = mediaAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
    let assetAudioTrack = mediaAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack
    
    //
    let videoTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID( kCMPersistentTrackID_Invalid))
    var error: NSError?
    videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, mediaAsset.duration), ofTrack: videoAssetTrack, atTime: kCMTimeZero, error: &error)
    assert(error == nil, "We have a muxing error!!! \(error)")
    //
    let videoInstruction = AVMutableVideoCompositionInstruction()
    videoInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mediaAsset.duration)
    let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, atTime: kCMTimeZero)
    videoLayerInstruction.setOpacity(0, atTime: mediaAsset.duration)
    videoInstruction.layerInstructions = [videoLayerInstruction]
    mutableVideoComposition = AVMutableVideoComposition(propertiesOfAsset: mediaAsset)
    mutableVideoComposition.instructions = [videoInstruction]
    mutableVideoComposition.renderSize = CGSizeMake(480, 640) //Variable.
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
    
    //configuring text.
    let overlayText = CATextLayer()
    overlayText.font = "Helvetica"
    overlayText.fontSize = 36
    overlayText.frame = CGRectMake(0, 0, 100, 100)
    overlayText.string = text
    overlayText.alignmentMode = kCAAlignmentCenter
    overlayText.foregroundColor = UIColor.whiteColor().CGColor
    overlayText.backgroundColor = UIColor.blackColor().CGColor
    
    let overlayLayer = CALayer()
    overlayLayer.addSublayer(overlayText)
    overlayLayer.backgroundColor = UIColor.darkGrayColor().CGColor
    overlayLayer.frame = CGRectMake(0, 0, 100, 100)
    overlayLayer.masksToBounds = true
    overlayLayer.opacity = 0.8
    
    let parentLayer = CALayer()
    parentLayer.frame = CGRectMake(0, 0, 480, 640)

    let videoLayer = CALayer()
    videoLayer.frame = CGRectMake(0, 0, 480, 640)
    videoLayer.opacity = 0.5
    
    parentLayer.addSublayer(videoLayer)
    parentLayer.addSublayer(overlayLayer)
    
    mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    //
    let mutableAudioTrack = mutableComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID( kCMPersistentTrackID_Invalid))
    mutableAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, mediaAsset.duration), ofTrack: assetAudioTrack as AVAssetTrack, atTime: kCMTimeZero, error: &error)
    assert(error == nil, "audio error!! \(error)")
    let mixParameters:AVAudioMixInputParameters = AVMutableAudioMixInputParameters(track: mutableAudioTrack)
    mutableAudioMix = AVMutableAudioMix()
    mutableAudioMix.inputParameters = [mixParameters]
    
    
    let exportSession = AVAssetExportSession(asset: mutableComposition.copy() as! AVAsset, presetName: AVAssetExportPreset640x480)
    exportSession.videoComposition = mutableVideoComposition
    exportSession.audioMix = mutableAudioMix
    exportSession.outputURL = outputURL()
    exportSession.outputFileType = AVFileTypeQuickTimeMovie
    
    exportSession.exportAsynchronouslyWithCompletionHandler {
      if exportSession.status == .Completed {
        println("exportSession Completed!!!")
        UISaveVideoAtPathToSavedPhotosAlbum(exportSession.outputURL.relativePath, self, "didFinishExporting", nil)
      } else {
        println("self.exportSession.error: \(self.exportSession.error)")
      }
    }
    
    return nil
  }

  func didFinishExporting() {
    println("didFinishExporting!!!")
  }

  func outputURL() -> NSURL {
    let timeInterval = NSDate().timeIntervalSince1970
    let outputString = NSHomeDirectory().stringByAppendingPathComponent("Documents/" + "\(timeInterval)" + "-movie.m4v")
    return NSURL(fileURLWithPath: outputString, isDirectory: false)!

  }
  
  func assetFromURL(url:NSURL) -> AVAsset {
    return AVAsset.assetWithURL(url) as! AVAsset
  }
  
  
}

