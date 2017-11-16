//
//  TextMessage.swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

class TextMessage: WZMessageData {
  
  var text: String
  
  init(text: String) {
    
    self.text = text
    
    super.init()
    
    mappingMessageView = RichTextMessageView.self
    
  }
}
