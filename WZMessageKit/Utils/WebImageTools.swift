//
//  WebImageTool.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/3/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import SDWebImage

public class WebImageTools {
  
  static let localTmpImagePrefix = "local_tmp_image"
  static let localTmpGIFPrefix = "local_tmp_gif"
  static let localThumbTmpImageSuffix = "thumb"
  static let imageMaxSize = CGSize(width:  480, height: 800)
  
  class func fetchLocalImage(with imageURL: String) -> UIImage? {
    
    guard !imageURL.isEmpty else { return nil }
    
    return SDImageCache.shared().imageFromCache(forKey: imageURL)
    
  }
  
  class func fetchLocalImageData(with imageURL: String) -> Data? {
    
    guard !imageURL.isEmpty else { return nil }
    
    guard let path = SDImageCache.shared().defaultCachePath(forKey: imageURL) else { return nil }
    
    guard let data = FileManager.default.contents(atPath: path) else { return nil }
    
    return data
    
  }
  
  class func requestImageWithURL(_ imageURL: String, completion: @escaping (_ image: UIImage?) -> Void) {
    
    _ = SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: imageURL), options: .lowPriority, progress: nil, completed: { (image, data, error, finished) in
      
      guard error == nil else {
        completion(nil)
        return
      }
      
      completion(image)
      
    })
  }
  
  class func downloadAndCacheImageWithURL(_ imageURL: String, completion: @escaping (_ success: Bool) -> Void) {
    
    SDImageCache.shared().diskImageExists(withKey: imageURL) { isExist in
      
      guard !isExist else {
        completion(true)
        return
      }
      
      _ = SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: imageURL), options: .lowPriority, progress: nil, completed: { (image, data, error, finished) in
        
        guard error == nil else {
          
          print("缓存图片失败 \(imageURL)")
          completion(false)
          return
        }
        SDImageCache.shared().store(nil, imageData: data, forKey: imageURL, toDisk: true, completion: {
          completion(true)
        })
      })
    }
  }
  
  class func saveLocalImage(with image: UIImage, isCreateThumb: Bool) -> String {
    
    let key = "\(localTmpImagePrefix)_\(image.hash)"
    
    if isCreateThumb {
      
      let thumbKey = WebImageTools.getImageURLForIM(with: key)
      
      if let clipedImageForThumb = image.jx_scaleImageWithoutCliped(to: ImageMessageView.thumbImageMaxSize) {
        
        if let imageData = UIImageJPEGRepresentation(clipedImageForThumb, 1) {
          
          SDImageCache.shared().storeImageData(toDisk: imageData, forKey: thumbKey)
          
        }
      }
    }
    
    if let clipedImage = image.jx_scaleImageWithoutCliped(to: WebImageTools.imageMaxSize) {
      
      if let imageData = UIImageJPEGRepresentation(clipedImage, 1) {
        SDImageCache.shared().storeImageData(toDisk: imageData, forKey: key)
      }
    }
    
    return key
  }
  
  class func saveLocalImageData(with data: Data) -> String {
    
    let key = "\(localTmpGIFPrefix)_\((data as NSData).hash)"
    SDImageCache.shared().storeImageData(toDisk: data, forKey: key)
    return key
  }
  
  class func replaceImageDataCache(_ originalKey: String, to newKey: String) {
    
    let imageData = fetchLocalImageData(with: originalKey)
    SDImageCache.shared().storeImageData(toDisk: imageData, forKey: newKey)
    SDImageCache.shared().removeImage(forKey: originalKey)
    SDImageCache.shared().removeImage(forKey: getImageURLForIM(with: originalKey))
    
  }
  
  class func getImageURLForIM(with imageURL: String) -> String {
    
    if imageURL.hasPrefix(localTmpImagePrefix) {
      return "\(imageURL)_\(localThumbTmpImageSuffix)"
    }
    
    if imageURL.hasPrefix(localTmpGIFPrefix) {
      return imageURL
    }
    
    //    let suffix = "@1e_\(Int(imageMaxSize.width))w_\(Int(imageMaxSize.height))h_0c_0i_1o_90Q_1x.png"
    return imageURL
  }
  
}

extension UIImage {
  
  func compressForUpload(_ completion: @escaping ((_ compressedImageData: Data, _ compressedImage: UIImage) -> Void)){
    
    exChangeGlobalQueue {
      let maxSize: Int = 1024 * 250
      var currentCompression: CGFloat = 1
      let compressionByStep: CGFloat = 0.5
      let maxCompressionNum = 20
      var currentCompressionNum = 0
      
      let img = self.jx_scaleImageWithoutCliped(to: CGSize(width: 480, height: 800))!
      var imageData = UIImageJPEGRepresentation(img, 1)!
      
      while imageData.count > maxSize && maxCompressionNum > currentCompressionNum {
        
        currentCompressionNum += 1
        currentCompression *= compressionByStep
        imageData = UIImageJPEGRepresentation(self, currentCompression)!
        
      }
      
      let compressedImage = UIImage(data: imageData)!
      
      exChangeMainQueue({
        
        completion(imageData, compressedImage)
        
      })
    }
    
  }
}
