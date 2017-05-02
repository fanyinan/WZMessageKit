//
//  MessageStatusView.swift
//  Yuanfenba
//
//  Created by 范祎楠 on 16/4/7.
//  Copyright © 2016年 Juxin. All rights reserved.
//

import UIKit

public struct WZMessageStatus: Equatable {

  var rawValue = 0
  static let none = WZMessageStatus(rawValue: 0)
  
  public static func ==(lhs: WZMessageStatus, rhs: WZMessageStatus) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

open class WZMessageStatusView: UIControl {
  
  public var status: WZMessageStatus = .none
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    initUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func initUI() { }
  
  open func setupUI(status: WZMessageStatus) { }
}
