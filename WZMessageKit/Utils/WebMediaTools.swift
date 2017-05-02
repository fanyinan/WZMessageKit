//
//  WebVideoTools.swift
//  Yuanfenba
//
//  Created by 范祎楠 on 16/6/30.
//  Copyright © 2016年 Juxin. All rights reserved.
//

import SDWebImage

class WebMediaTools: NSObject {
  
  static var downloadingVideoURLs = Set<String>()
  
  class func flagDownloadingVideoURL(with videoURL: String) {
    
    downloadingVideoURLs.insert(videoURL)
    
  }
  
  class func flagVideoURLFinishDownload(with videoURL: String) {
    
    downloadingVideoURLs.remove(videoURL)
  }
  
  class func isVideoURLDownloading(_ videoURL: String) -> Bool {
    
    return downloadingVideoURLs.contains(videoURL)
    
  }
  
  class func saveAudioInCache(with audioData: Data) -> String {
    
    let key = "local_tmp_audio_\((audioData as NSData).hash).amr"
    
    SDImageCache.shared().storeImageData(toDisk: audioData, forKey: key)
    
    return key
  }
  
  class func saveVideoInCacheAndDeleteOriginFile(with videoURL: URL) -> String {
    
    let key = "local_tmp_video_\((videoURL as NSURL).hash).mp4"
    
    SDImageCache.shared().storeImageData(toDisk: try? Data(contentsOf: videoURL), forKey: key)
    
    if FileManager.default.fileExists(atPath: videoURL.path) {
      
      try! FileManager.default.removeItem(at: videoURL)
      
    }
    
    return key
  }
  
  class func getMediaURL(with mediaKey: String) -> URL? {
    
    guard let path = SDImageCache.shared().defaultCachePath(forKey: mediaKey) else { return nil }
    
    return URL(fileURLWithPath: path)
    
  }
  
  class func replaceMediaCache(with originKey: String, to newKey: String) {
    
    let originMediaPath = SDImageCache.shared().defaultCachePath(forKey: originKey)
    let mediaData = try? Data(contentsOf: URL(fileURLWithPath: originMediaPath!))
    SDImageCache.shared().storeImageData(toDisk: mediaData, forKey: newKey)
    SDImageCache.shared().removeImage(forKey: originKey, fromDisk: true)
    
  }
  
  class func mediaExist(with key: String) -> Bool {
    
    guard let path = SDImageCache.shared().defaultCachePath(forKey: key) else { return false }
    
    return FileManager().fileExists(atPath:  path)
    
  }
  
  class func downloadMedia(with mediaURL: String, progress: ((_ mediaURL: String, _ progress: CGFloat) -> Void)?, completion: @escaping (_ mediaURL: String, _ data: Data?, _ cached: Bool) -> Void) {
    
//    NetworkManager.shared.downloadMedia(mediaURL, progressBlock: { (downloaded, total, mediaURL) in
//      
//      guard let mediaURL = mediaURL?.absoluteString else { return }
//      
//      progress?(mediaURL, CGFloat(downloaded) / CGFloat(total))
//      
//    }, completetionBlock: { (fileURL, cached) in
//      
//      completion(mediaURL, fileURL, cached)
//      
//    })
    
  }
  
  class func removeMediaURLCache(with key: String) {
    
    SDImageCache.shared().removeImage(forKey: key)
    
  }
  
  class func fetchMediaData(with mediaKey: String) -> Data? {
    
    guard !mediaKey.isEmpty else { return nil }
    
    guard mediaExist(with: mediaKey) else {
      return nil
    }
    
    guard let mediaDataURL = getMediaURL(with: mediaKey) else { return nil }
    
    guard let videoData = try? Data(contentsOf: mediaDataURL) else { return nil }
    
    return videoData
    
  }
}
