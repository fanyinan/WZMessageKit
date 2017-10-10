//
//  WZMessageContentViewManager.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/1/18.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

import UIKit

class WZMessageViewManager {

  static let shared = WZMessageViewManager()
  
  private var messageViewLoaderStack: [MessageViewLoader] = []
  
  private var currentMessageViewLoader: MessageViewLoader!
  
  func begin() {
    
    currentMessageViewLoader = MessageViewLoader()
    messageViewLoaderStack.append(currentMessageViewLoader)
    
  }
  
  func end() {
    
    messageViewLoaderStack.removeLast()
    currentMessageViewLoader = messageViewLoaderStack.last
    
  }
  
  func preload(with viewType: WZMessageBaseView.Type, with height: CGFloat, maxHeight: CGFloat) {
    
    currentMessageViewLoader.preload(viewType: viewType, height: height, maxHeight: maxHeight)
  }
  
  func fetch<T: WZMessageBaseView>(with viewType: T.Type) -> T {
    
    return currentMessageViewLoader.fetch(viewType: viewType)
  }
}
