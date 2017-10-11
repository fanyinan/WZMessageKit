//
//  WZMessageInputViewPopManager.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/3.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

protocol WZMessageInputViewPopControllerDelegate: NSObjectProtocol {
  
  func inputViewPopController(_ inputViewPopController: WZMessageInputViewPopController, inputViewFrameChangeWithAnimation originFrame: CGRect, currentFrame: CGRect)
  
}

class WZMessageInputViewPopController: NSObject {
  
  private var inputView: UIView
  private var inputViewOriginY: CGFloat!
  private var keyboardController: KeyBoardController!
  
  var enable = true
  
  weak var delegate: WZMessageInputViewPopControllerDelegate?
  
  init(delegate: WZMessageInputViewPopControllerDelegate, inputView: UIView) {
    
    self.delegate = delegate
    self.inputView = inputView
    super.init()
    
    setup()
    
  }
  
  func setup() {
    keyboardController = KeyBoardController(delegate: self)
    keyboardController.addObserverForKeyBoard()
  }
  
  func animateInputViewWith(duration: TimeInterval, options: UIViewAnimationOptions, poppingViewHeight: CGFloat, isShow: Bool) {
    
    //需要在viewwillappear之后完成，因为需要得到messageInputViewContainer在navigationbar存在时的frame
    //并且只会被设置一次
    
    let originFrame = inputView.frame
    
    var bottomInset: CGFloat = 0
    
    if #available(iOS 11.0, *) {
      bottomInset = inputView.superview!.safeAreaInsets.bottom
    }
    
    let inputViewBottomMargin = isShow ? poppingViewHeight : bottomInset
    let inputViewY = inputView.superview!.frame.height - inputViewBottomMargin - inputView.frame.height
    
    UIView.animate(withDuration: duration, delay: 0, options: options, animations: { () -> Void in
      
      self.inputView.frame.origin.y = inputViewY
      
      self.delegate?.inputViewPopController(self, inputViewFrameChangeWithAnimation: originFrame, currentFrame: self.inputView.frame)
      
    }, completion: nil)
  }
}

extension WZMessageInputViewPopController: KeyBoardDelegate {
  
  func keyboardWillChange(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool) {
    
    guard enable else { return }
    
    animateInputViewWith(duration: animationDuration, options: animationOptions, poppingViewHeight: keyboardFrame.height, isShow: isShow)
  }
}

extension WZMessageInputViewPopController: WZMessageBottomViewPoppingControllerDelegate {
  
  func poppingBottomViewWillChange(_ viewFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool) {
    
    guard enable else { return }
    
    animateInputViewWith(duration: animationDuration, options: animationOptions, poppingViewHeight: viewFrame.height, isShow: isShow)
    
  }
}

