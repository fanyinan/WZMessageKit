//
//  WZEvent.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/3/18.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

import Foundation

public enum WZMessageEventType {
  case tap
  case longPress
}

public class WZMessageEvent: NSObject {
  
  var data: [String: Any] = [:]
  var envetType: WZMessageEventType
  var messageData: WZMessageData!
  
  init(eventType: WZMessageEventType) {
    self.envetType = eventType
  }
}
