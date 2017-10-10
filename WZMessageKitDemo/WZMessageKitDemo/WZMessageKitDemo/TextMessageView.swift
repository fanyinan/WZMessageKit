//
//  TextMessageView.swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class TextMessageView: WZMessageBaseView {

  override func initView() {
    backgroundColor = .blue
  }
  
  override func configContentView(with messageData: WZMessageData) {
    
  }
  
  override class func contentViewSize(with messageData: WZMessageData) -> CGSize {
  
    return CGSize(width: 100, height: 50)
  }

}
