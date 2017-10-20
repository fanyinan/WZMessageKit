//
//  WZMessageBaseView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/1/19.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

import UIKit

public protocol WZMessageContentViewDelegate: NSObjectProtocol {
  func onCatchEvent(event: WZMessageEvent)
}

open class WZMessageBaseView: UIView {
  
  public weak var messageCell: WZMessageContainerCell?
  public weak var messageViewController: WZMessageViewController?
  public weak var delegate: WZMessageContentViewDelegate?
  
  public var row: Int!

  required public init() {
    super.init(frame: CGRect.zero)
    
    initView()
    
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func addTapGestureRecognizer() {
   let tap = UITapGestureRecognizer(target: self, action: #selector(WZMessageBaseView.onClickMessage))
    addGestureRecognizer(tap)
  }
  
  public class func getMaxWidth(with messageData: WZMessageData) -> CGFloat {
    return WZMessageContainerCell.getCustomViewMaxWidth(with: messageData)
  }
  
  open func initView() { }
  
  open func configContentView(with messageData: WZMessageData) {}
  
  @objc open func onClickMessage() {}
  
  open func messageViewWillDisplay() {}
  
  open func messageViewDidEndDisplay() {}
  
  open class func contentViewSize(with messageData: WZMessageData) -> CGSize { return CGSize.zero }
  
  open class func preloadData(with messageData: WZMessageData) {}
  
}
