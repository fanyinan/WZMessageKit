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
  
  public var data: [String: Any] = [:]
  public var envetType: WZMessageEventType
  public var messageData: WZMessageData!
  
  public init(eventType: WZMessageEventType) {
    self.envetType = eventType
  }
}
