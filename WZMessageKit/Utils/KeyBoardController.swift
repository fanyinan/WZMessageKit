//
//  KeyBoardManager.swift
//  WZMessageKitDemo
//
//  Created by 范祎楠 on 15/9/23.
//  Copyright © 2015年 fyn. All rights reserved.
//

import UIKit
import Foundation

protocol KeyBoardDelegate: NSObjectProtocol {
    func keyboardWillChange(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: UIView.AnimationOptions, isShow: Bool)
}

class KeyBoardController: NSObject {
  
  weak var delegate: KeyBoardDelegate?
  var isShow: Bool = false
  fileprivate var textFieldList: [UITextField] = []
  fileprivate var scrollView: UIScrollView?
  fileprivate var originContentOffset: CGPoint?
  
  init(scrollView: UIScrollView, textFieldList: [UITextField]) {
    
    self.scrollView = scrollView
    self.textFieldList = textFieldList
    super.init()
    
  }
  
  init(delegate: KeyBoardDelegate) {
    self.delegate = delegate
    super.init()
  }
  
  deinit{
    
    NotificationCenter.default.removeObserver(self)
    
  }
  
  func addObserverForKeyBoard() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillAppearNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidAppearNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidHideNotification(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
  }
  
  @objc func handleKeyboardWillAppearNotification(_ notification: Notification) {
    
    isShow = true
    keyBoardWillChange(notification)
  }
  
  @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
    
    if isShow {
      isShow = false
      keyBoardWillChange(notification)
    }
    
  }
  
  @objc func handleKeyboardDidAppearNotification(_ notification: Notification) {
  }
  
  @objc func handleKeyboardDidHideNotification(_ notification: Notification) {
  }
  
  func keyBoardWillChange(_ notification: Notification) {
    
    if let keyBoradInfoDic = notification.userInfo {
        let keyBoardFrame = (keyBoradInfoDic[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = keyBoradInfoDic[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = keyBoradInfoDic[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
    
        let animationOptions = UIView.AnimationOptions(rawValue: UInt(curve << 16))
    
        delegate?.keyboardWillChange(keyBoardFrame, animationDuration: duration, animationOptions: animationOptions, isShow: notification.name == UIResponder.keyboardWillShowNotification)
    }
  }
}
