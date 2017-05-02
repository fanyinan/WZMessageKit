//
//  WZMessageBaseModel.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

public enum WZMessageOwnerType {
  case sender
  case receiver
  case custom
}

open class WZMessageData: NSObject {
  
  open var mappingMessageView: WZMessageBaseView.Type = WZMessageBaseView.self
  public var ownerType: WZMessageOwnerType!
  public var sendTime = Date()
  public var status: WZMessageStatus = .none

}

