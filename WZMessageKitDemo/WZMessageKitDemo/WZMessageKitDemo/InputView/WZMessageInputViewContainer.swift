//
//  WZMessageInputView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit
//import SnapKit

@objc enum WZMessageInputViewEvent: Int {
  case more
  case emoji
  case switchToAudio
  case switchToText
  case textViewDidBeginEditing
  case textViewDidEndEditing
}

protocol WZMessageInputViewContainerDelegate: NSObjectProtocol {
  func inputViewContainer(_ inputViewContainer: WZMessageInputViewContainer, heightChanged increasedHeight: CGFloat)
  func onCatchInputViewEvent(event: WZMessageInputViewEvent)
  func textInputView(_ textInputView: WZMessageTextInputView, didClickSendButtonWithText text: String)
  func audioInputViewDidStartRecordingAudioAction()
  func audioInputViewDidCancelRecordingAudioAction()
  func audioInputViewDidFinishRecoingAudioAction()
  func audioInputViewDidDragExitAction()
  func audioInputViewDidDragEnterAction()
}

class WZMessageInputViewContainer: WZMessageInputView {
  
  private var previousHeight: CGFloat = 0
  
  var textInputView: WZMessageTextInputView!
  weak var delegate: WZMessageInputViewContainerDelegate?
  override var textView: UITextView { return textInputView.textView }
  
  var isRecording: Bool {
    get {
      return textInputView.audioRecordStatus != .stop
    }
    
    set {
      textInputView.audioRecordStatus = newValue ? .recording : .stop
    }
  }
  
  init(delegate: WZMessageInputViewContainerDelegate) {
    
    self.delegate = delegate
    
    super.init(frame: CGRect.zero)
    frame.size.height = 50 //随便给一个比较大的值，防止xib出现约束冲突
    
    setupUI()
    
  }
  
  override func didMoveToSuperview() {
    
    guard let superview = superview else { return }
    
    po_frameBuilder().alignToBottomInSuperview(withInset: 0)
    po_frameBuilder().setWidth(superview.frame.width)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setHeightWithoutChangeBottomMargin(with height: CGFloat) {
    
    let originHeight = frame.height
    frame.size.height = height
    frame.origin.y += originHeight - height
    
    delegate?.inputViewContainer(self, heightChanged: height - previousHeight)
    
    previousHeight = height
  }
  
  override func hideKeyboard() {
    textInputView.hideKeyboard()
  }
  
  override func showKeyboard() {
    textInputView.showKeyboard()
  }

  
  private func setupUI() {
    
    loadSubViews()
    
  }
  
  private func loadSubViews() {
    
    let nib = UINib(nibName: String(describing: WZMessageTextInputView.self), bundle: Bundle(for: WZMessageTextInputView.self))
    textInputView = nib.instantiate(withOwner: nil, options: nil).first as! WZMessageTextInputView
    textInputView.inputViewContainer = self
    setHeightWithoutChangeBottomMargin(with: textInputView.frame.height)
    textInputView.frame = CGRect(x: 0, y: 0, width: frame.width, height: textInputView.frame.height)
    textInputView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(textInputView)
    
  }
}
