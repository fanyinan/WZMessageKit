//
//  swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class MessageViewController: WZMessageViewController {
  
  var messageDataList: [WZMessageData] = []
  var inputViewContainer: WZMessageInputViewContainer!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    
    for _ in 0..<40 {
      messageDataList.append(TextMessage(text: "aaa"))
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "test", style: .plain, target: self, action: #selector(test))
    
    inputViewContainer = WZMessageInputViewContainer(delegate: self)
    addInputView(inputView: inputViewContainer)
    
  }
}

extension MessageViewController: WZMessageViewControllerDataSource, WZMessageViewControllerDelegate {
  
  func numberOfMessageInMessageViewController(_ messageViewController: WZMessageViewController) -> Int {
    return messageDataList.count
  }
  
  func messageViewController(_ messageViewController: WZMessageViewController, messageDataForCellAtRow row: Int) -> WZMessageData {
    return messageDataList[row]
  }
  
}

extension MessageViewController: WZMessageInputViewContainerDelegate {
  
  func inputViewContainer(_ inputViewContainer: WZMessageInputViewContainer, heightChanged increasedHeight: CGFloat) {
    
    messageTableView.changeTableViewInsets(bottomIncrement: increasedHeight, adjustIndicator: true)
    scrollToBottomAnimated(isAnimated: false)
    messageViewController(messageViewController, inputViewFrameChangeWithAnimation: inputViewContainer.frame)
  }
  
  func onCatchInputViewEvent(event: WZMessageInputViewEvent) {
    
    switch event {
    case .switchToAudio:
      hideKeyboardAndBottomView()
    case .switchToText:
      showKeyboard()
    case .textViewDidBeginEditing:
      scrollToBottomAnimated(isAnimated: false)
    case .textViewDidEndEditing:
      hideKeyboardAndBottomView()
    default:
      break
    }
  }
  
  func audioInputViewDidStartRecordingAudioAction() {
    
    
  }
  
  func audioInputViewDidFinishRecoingAudioAction() {
    
  }
  
  func audioInputViewDidCancelRecordingAudioAction() {
    
  }
  
  func audioInputViewDidDragEnterAction() {
    
  }
  
  func audioInputViewDidDragExitAction() {
    
  }
  
  func textInputView(_ textInputView: WZMessageTextInputView, didClickSendButtonWithText text: String) {
    
    guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else { return }
    
    let textMessage = TextMessage(text: text)
    textMessage.ownerType = .sender
    messageDataList.append(textMessage)
    append()
  }
}
