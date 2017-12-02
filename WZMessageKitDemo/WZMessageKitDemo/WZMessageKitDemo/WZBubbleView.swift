//
//  WZBubbleView.swift
//  JXiOS
//
//  Created by 范祎楠 on 2017/3/18.
//  Copyright © 2017年 JuXin. All rights reserved.
//

import UIKit

class WZBubbleView: UIView {
  
  private var bubbleImageView: UIImageView!
  private var senderBubbleImage: UIImage?
  private var receiverBubbleImage: UIImage?
  private var bubbleInsets: WZBubbleInsets?
  private(set) var containerView: UIView!
  
  var containerFrame: CGRect { return containerView.frame }
  var containerBounds: CGRect { return containerView.bounds }

  init(senderBubbleImageName: String? = nil, receiverBubbleImageName: String? = nil, bubbleInsets: WZBubbleInsets) {
    super.init(frame: CGRect.zero)
    
    if let senderBubbleImageName = senderBubbleImageName {
      self.senderBubbleImage = UIImage(named: senderBubbleImageName)
    }
    
    if let receiverBubbleImageName = receiverBubbleImageName {
      self.receiverBubbleImage = UIImage(named: receiverBubbleImageName)
    }
    
    self.bubbleInsets = bubbleInsets
    
    bubbleImageView = UIImageView()
    bubbleImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    bubbleImageView.isUserInteractionEnabled = false

    containerView = UIView()
    containerView.backgroundColor = .clear
    containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    addSubview(bubbleImageView)
    addSubview(containerView)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(frame: CGRect, owerType: WZMessageOwnerType, imageName: String? = nil) {
    
    if let imageName = imageName {
      if owerType == .sender {
        senderBubbleImage = UIImage(named: imageName)
      } else if owerType == .receiver {
        receiverBubbleImage = UIImage(named: imageName)
      }
    }
    
    self.frame = frame
    
    if owerType == .sender {
      bubbleImageView.image = senderBubbleImage
    } else if owerType == .receiver {
      bubbleImageView.image = receiverBubbleImage
    }
    
    guard let bubbleInsets = bubbleInsets else {
      containerView.frame = bounds
      return
    }
    
    containerView.frame = CGRect(x: owerType == .sender ? bubbleInsets.inside : bubbleInsets.outside,
                  y: bubbleInsets.top,
                  width: frame.width - bubbleInsets.inside - bubbleInsets.outside,
                  height: frame.height - bubbleInsets.top - bubbleInsets.bottom)
  }
  
  override func addSubview(_ view: UIView) {
   
    if view == containerView || view == bubbleImageView {
      super.addSubview(view)
    } else {
      containerView.addSubview(view)
    }
  }
}
