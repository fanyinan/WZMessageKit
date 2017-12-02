//
//  WZMessageTextInputView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/3.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

enum AudioRecordStatus {
  case recording
  case canceling
  case stop
}

class WZMessageTextInputView: UIView {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var textViewContainerView: UIView!
  @IBOutlet weak var switchButton: UIButton!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewBottomMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewTopMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewContainerBottomMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewContainerTopMarginConstraint: NSLayoutConstraint!
  
  weak var inputViewContainer: WZMessageInputViewContainer?
  private var textViewContentSizeWhenOneLineText: CGFloat = 0
  private var previousInputViewHeight: CGFloat = 0
  private let oneLineTextMargin: CGFloat = 10
  private let severalLinesTextMargin: CGFloat = 4
  private var heightWhenShowTextInput: CGFloat!
  private var isShowTextInput = true
  
  var audioRecordStatus: AudioRecordStatus = .stop
  var heightChangeWithAnimation: (()->Void)?
  var originHeight: CGFloat { return textViewContentSizeWhenOneLineText + oneLineTextMargin * 2 + separatorHeightConstraint.constant + textViewContainerBottomMarginConstraint.constant + textViewContainerTopMarginConstraint.constant }
  
  let maxLines = 6 //textview 最大行数
  
  deinit{
    textView.removeObserver(self, forKeyPath: "contentSize")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setupUI()
  }
  
  func didClickSendButton() {
    
    inputViewContainer?.delegate?.textInputView(self, didClickSendButtonWithText: textView.text)
    
  }
  
  func hideKeyboard() {
    
    guard textView.isFirstResponder else { return }
    textView.resignFirstResponder()
    
  }
  
  func showKeyboard() {
    guard !textView.isFirstResponder else { return }
    textView.becomeFirstResponder()
  }
  
  func showTextInputView() {
    
    textViewContainerView.isHidden = false
    recordButton.isHidden = true
    switchButton.setImage(UIImage(named: "msg_voice"), for: .normal)
    inputViewContainer?.setHeightWithoutChangeBottomMargin(with: heightWhenShowTextInput)
    
  }
  
  func showAudioInputView() {
    
    //保存当前textinputview的高度
    heightWhenShowTextInput = frame.height
    
    textViewContainerView.isHidden = true
    recordButton.isHidden = false
    switchButton.setImage(UIImage(named: "msg_keyboard"), for: .normal)
    inputViewContainer?.setHeightWithoutChangeBottomMargin(with: originHeight)
  }
  
  @IBAction func onClickSwitchButton() {
    inputViewContainer?.delegate?.onCatchInputViewEvent(event: .switchToAudio)
    
    if isShowTextInput {
      showAudioInputView()
    } else {
      showTextInputView()
    }

    isShowTextInput = !isShowTextInput
  }
  
  @IBAction func onClickEmojiButton() {
    
    if !isShowTextInput {
      showTextInputView()
    }
    
    inputViewContainer?.delegate?.onCatchInputViewEvent(event: .emoji)
  }
  
  @IBAction func onClickPlusButton() {
   inputViewContainer?.delegate?.onCatchInputViewEvent(event: .more)
  }
  
  @IBAction func onClickTextViewContainerView() {
    textView.becomeFirstResponder()
  }
  
  @IBAction func onTouchDownRecordButton() {
    guard audioRecordStatus == .stop else { return }
    audioRecordStatus = .recording
    inputViewContainer?.delegate?.audioInputViewDidStartRecordingAudioAction()
    recordButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    recordButton.setTitle("松开 结束", for: UIControlState())
  }
  
  @IBAction func onTouchUpInsideRecordButton() {
    guard audioRecordStatus == .recording else { return }
    inputViewContainer?.delegate?.audioInputViewDidFinishRecoingAudioAction()
    recordButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    recordButton.setTitle("按住 说话", for: UIControlState())
  }
  
  @IBAction func onTouchUpOutsideRecordButton() {
    guard audioRecordStatus == .canceling else { return }
    inputViewContainer?.delegate?.audioInputViewDidCancelRecordingAudioAction()
    recordButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    recordButton.setTitle("按住 说话", for: UIControlState())
  }
  
  @IBAction func onDragEnterRecordButton() {
    guard audioRecordStatus == .canceling else { return }
    audioRecordStatus = .recording
    inputViewContainer?.delegate?.audioInputViewDidDragEnterAction()
    recordButton.setTitle("松开 结束", for: UIControlState())
  }
  
  @IBAction func onDragExitRecordButton() {
    guard audioRecordStatus == .recording else { return }
    audioRecordStatus = .canceling
    inputViewContainer?.delegate?.audioInputViewDidDragExitAction()
    recordButton.setTitle("松开 结束", for: UIControlState())
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    guard let newHeight = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgSizeValue.height else { return }
    
    guard let oldHeight = (change?[NSKeyValueChangeKey.oldKey] as? NSValue)?.cgSizeValue.height else { return }
    
    guard oldHeight != newHeight else { return }
    
    if object! as! NSObject == textView && keyPath! == "contentSize" {
      adjustInputViewFrameWithanimation()
    }
    
  }
  
  @objc func invitedVideoAudioChat() {
    
    onTouchUpInsideRecordButton()
  }

  private func setupUI() {
    
    textView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
    backgroundColor = UIColor.white
    textView.backgroundColor = UIColor.white
    textViewContainerView.wz_setBorder(0.5, color: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
    textViewContainerView.wz_setViewCornerRadius(3)
    
    recordButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    recordButton.wz_setBorder(0.5, color: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
    recordButton.wz_setViewCornerRadius(3)
    
  }

  //根据父view的高调整按钮的下边距，使按钮保持垂直居中
  //  func adjustButtons(with superViewFrameHeight: CGFloat) {
  
  //    audioButtonBottonMarginConstraint.constant = (superViewFrameHeight - CGRectGetHeight(audioButton.frame)) / 2
  //    sendButtonBottonMarginConstraint.constant = (superViewFrameHeight - CGRectGetHeight(sendButton.frame)) / 2
  
  //  }
  
  private func adjustInputViewFrameWithanimation() {
    
    let currentHeight = getInputViewHeight()
    let maxHeight = getMaxInputViewHeight()
    
    textView.showsVerticalScrollIndicator = false
    textView.bounces = false
    
    guard maxHeight > previousInputViewHeight || maxHeight > currentHeight else {
      
      textView.bounces = true
      textView.showsVerticalScrollIndicator = true
      return
    }
    
    adjustInputViewMargin()
    
    UIView.animate(withDuration: 0.25, animations: { () -> Void in
      
      if let inputViewContainer = self.inputViewContainer {
        inputViewContainer.setHeightWithoutChangeBottomMargin(with: self.getCurrentHeight())
      } else {
        self.frame.size.height = self.getCurrentHeight()
      }
      
      //for subviews of self
      self.setNeedsLayout()
      self.layoutIfNeeded()
      
      self.heightChangeWithAnimation?()
      
    }, completion: { (finish) -> Void in
      
      self.previousInputViewHeight = self.getInputViewHeight()
      
    })
  }
  
  private func getInputViewHeight() -> CGFloat{
    return textView.contentSize.height
  }
  
  private func getMaxInputViewHeight() -> CGFloat {
    return ceil(textView.font!.lineHeight * CGFloat(maxLines)) + textView.textContainerInset.bottom + textView.textContainerInset.top
  }
  
  private func getCurrentHeight() -> CGFloat {
    return min(getInputViewHeight(), getMaxInputViewHeight()) + textViewTopMarginConstraint.constant + separatorHeightConstraint.constant + textViewBottomMarginConstraint.constant + textViewContainerBottomMarginConstraint.constant + textViewContainerTopMarginConstraint.constant
  }
  
  private func adjustInputViewMargin() {
    
    let inputViewHeight = getInputViewHeight()
    
    if textView.text.isEmpty {
      
      textViewContentSizeWhenOneLineText = inputViewHeight
      
    }
    
    if textViewContentSizeWhenOneLineText == inputViewHeight {
      
      textViewTopMarginConstraint.constant = oneLineTextMargin
      textViewBottomMarginConstraint.constant = oneLineTextMargin
      
    } else {
      
      textViewTopMarginConstraint.constant = severalLinesTextMargin
      textViewBottomMarginConstraint.constant = severalLinesTextMargin
      
    }
    
  }
  
}

extension WZMessageTextInputView: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    if text == "\n" {
      
      didClickSendButton()
      
      return false
    }
    
    return true
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    inputViewContainer?.delegate?.onCatchInputViewEvent(event: .textViewDidBeginEditing)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    inputViewContainer?.delegate?.onCatchInputViewEvent(event: .textViewDidEndEditing)
  }
}
