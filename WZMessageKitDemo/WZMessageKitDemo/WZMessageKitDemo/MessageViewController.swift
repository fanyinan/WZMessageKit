//
//  swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit
import WZImagePicker

class MessageViewController: WZMessageViewController {
  
  var messageDataList: [WZMessageData] = []
  var inputViewContainer: WZMessageInputViewContainer!
  lazy var menuView: WZMessageMenuView = self.initBottomMenuView()
  private lazy var imagePick: WZImagePickerHelper = WZImagePickerHelper(delegate: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    
    for i in 0..<40 {
      let textMessage = TextMessage(text: "aaa")
      textMessage.ownerType = i % 2 == 0 ? WZMessageOwnerType.sender : WZMessageOwnerType.receiver
      messageDataList.append(textMessage)
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "test", style: .plain, target: self, action: #selector(test))
    
    inputViewContainer = WZMessageInputViewContainer(delegate: self)
    addInputView(inputView: inputViewContainer)
    
  }
  
  @objc private func test() {
    
  }
  
  private func initBottomMenuView() -> WZMessageMenuView {
    
    let menuView = WZMessageMenuView(delegate: self, frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: 130)))
    menuView.menuDataList.append(MessageMenuItem(imageName: "pick_photo", title: "照片", subtitle: "", enable: true))
    addPoppingView(menuView)
    
    return menuView
  }
}

extension MessageViewController: WZMessageViewControllerDataSource, WZMessageViewControllerDelegate {
  
  func numberOfMessageInMessageViewController(_ messageViewController: WZMessageViewController) -> Int {
    return messageDataList.count
  }
  
  func messageViewController(_ messageViewController: WZMessageViewController, messageDataForCellAtRow row: Int) -> WZMessageData {
    return messageDataList[row]
  }
  
  func messageViewController(_ messageViewController: WZMessageViewController, configAvatarImageView avatarImageView: UIImageView, atIndex index: Int) {
    
    if messageDataList[index].ownerType == .sender {
      avatarImageView.backgroundColor = .red
    } else if messageDataList[index].ownerType == .receiver {
      avatarImageView.backgroundColor = .blue
    }
  }
}

extension MessageViewController: WZMessageInputViewContainerDelegate {
  
  func inputViewContainer(_ inputViewContainer: WZMessageInputViewContainer, heightChanged increasedHeight: CGFloat) {
    
    messageTableView.changeTableViewInsets(bottomIncrement: increasedHeight, adjustIndicator: true)
    scrollToBottomAnimated(isAnimated: false)
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
    case .more:
      hideKeyboard()
      togglePoppingView(self.menuView)
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
    
    textInputView.textView.text = ""
    
    let textMessage = TextMessage(text: text)
    textMessage.ownerType = .sender
    messageDataList.append(textMessage)
    append()
  }
}

// MARK: - WZMessageMenuViewDelegate
extension MessageViewController: WZMessageMenuViewDelegate {
  func menuView(_ menuView: WZMessageMenuView, didSelectItemAtIndex menuItemIndex: Int) {
    
    togglePoppingView(menuView)
    
    switch menuItemIndex {
      
    case 0:
      imagePick.resourceOption = [.image, .data]
      imagePick.start()
    
    default:
      break
    }
  }
}

// MARK: - WZImagePickerDelegate
extension MessageViewController: WZImagePickerDelegate {
  
  func pickedPhoto(_ imagePickerHelper: WZImagePickerHelper, didPickResource resource: WZResourceType) {
    
    switch resource {
    case .image(images: let images):
      guard let image = images.first else { return }
      DispatchQueue.global().async {
        let imageKey = WebImageTools.saveLocalImage(with: image, isCreateThumb: true)
        DispatchQueue.main.async {
          let imageMessage = ImageMessage(imageURL: imageKey)
          imageMessage.ownerType = .sender
          self.messageDataList.append(imageMessage)
          self.append()
        }
      }

    default:
      break
    }
  }
}
