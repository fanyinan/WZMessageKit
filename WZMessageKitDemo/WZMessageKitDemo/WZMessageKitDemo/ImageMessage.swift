//
//  ImageMessage.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/1.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

class ImageMessage: WZMessageData {
  
  var imageURL: String
  
  init(imageURL: String) {
    
    self.imageURL = imageURL
    
    super.init()
    
    mappingMessageView = ImageMessageView.self

  }
}
