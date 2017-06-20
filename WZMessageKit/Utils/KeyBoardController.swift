//
//  KeyBoardManager.swift
//  MuMu
//
//  Created by 范祎楠 on 15/9/23.
//  Copyright © 2015年 juxin. All rights reserved.
//

import UIKit
import Foundation

protocol KeyBoardDelegate: NSObjectProtocol {
  func keyboardWillChange(_ keyboardFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool)
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillAppearNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidAppearNotification(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardController.handleKeyboardDidHideNotification(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
  }
  
  func handleKeyboardWillAppearNotification(_ notification: Notification) {
    
    isShow = true
    keyBoardWillChange(notification)
  }
  
  func handleKeyboardWillHideNotification(_ notification: Notification) {
    
    if isShow {
      isShow = false
      keyBoardWillChange(notification)
    }
    
  }
  
  func handleKeyboardDidAppearNotification(_ notification: Notification) {
  }
  
  func handleKeyboardDidHideNotification(_ notification: Notification) {
  }
  
  func keyBoardWillChange(_ notification: Notification) {
    
    if let keyBoradInfoDic = notification.userInfo {
      let keyBoardFrame = (keyBoradInfoDic[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
      let duration = keyBoradInfoDic[UIKeyboardAnimationDurationUserInfoKey] as! Double
      let curve = keyBoradInfoDic[UIKeyboardAnimationCurveUserInfoKey] as! Int
    
      let animationOptions = UIViewAnimationOptions(rawValue: UInt(curve << 16))
    
      delegate?.keyboardWillChange(keyBoardFrame, animationDuration: duration, animationOptions: animationOptions, isShow: notification.name == NSNotification.Name.UIKeyboardWillShow)
    }
  }
}
