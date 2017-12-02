//
//  TextMessageView.swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

import WZRichTextView

class RichTextMessageView: WZMessageBaseView {
  
  private var bubbleView: WZBubbleView!
  private var messageTextView: WZRichTextView!
  private var textMessage: TextMessage!
  
  static let textViewMarginOfCloseToArrow: CGFloat = 15
  static let textViewMarginOfNoArrow: CGFloat = 10
  static let textViewMarginInVertical: CGFloat = 12
  static let containerViewWidthRatio: CGFloat = 0.8
  static var interprets: [Interpreter] {
    return []
  }
  
  override func initView() {
    
    setupUI()
    
    let longTap = UILongPressGestureRecognizer(target: self, action: #selector(RichTextMessageView.onLongPress(gesture:)))
    addGestureRecognizer(longTap)
  }
  
  override func configContentView(with messageData: WZMessageData) {
    
    self.textMessage = messageData as! TextMessage
    
    layoutMessageBubbleView(with: textMessage)
    
    messageTextView.textStyle = RichTextMessageView.createRichTextStyle(textMessage: textMessage)
    messageTextView.text = textMessage.text
  }
  
  override class func preloadData(with messageData: WZMessageData) {
    
    guard let textMessage = messageData as? TextMessage else { return }
    
    let textStyle = createRichTextStyle(textMessage: textMessage)
    let textSize = calculateTextSize(with: textMessage)
    WZRichTextView.preCreateRichText(with: textMessage.text, with: textStyle, with: interprets, with: textSize)
  }
  
  override class func contentViewSize(with messageData: WZMessageData) -> CGSize {
    
    let textSize = calculateTextSize(with: messageData as! TextMessage)
    
    let bubbleContainerViewHeight = textSize.height + textViewMarginInVertical * 2
    let bubbleContainerViewWidth = textSize.width + textViewMarginOfCloseToArrow + textViewMarginOfNoArrow
    
    return CGSize(width: bubbleContainerViewWidth, height: bubbleContainerViewHeight)
  }
  
  @objc func onLongPress(gesture: UILongPressGestureRecognizer) {
    
    switch gesture.state {
    case .began:
      delegate?.onCatchEvent(event: WZMessageEvent(eventType: .longPress))
    default:
      break
    }
  }
  
  private func setupUI() {
    
    bubbleView = WZBubbleView(senderBubbleImageName: "message_bubble_sender_normal",
                              receiverBubbleImageName: "message_bubble_receiver_normal",
                              bubbleInsets: WZBubbleInsets(top: RichTextMessageView.textViewMarginInVertical, bottom: RichTextMessageView.textViewMarginInVertical, outside: RichTextMessageView.textViewMarginOfCloseToArrow, inside: RichTextMessageView.textViewMarginOfNoArrow))
    addSubview(bubbleView)
    
    messageTextView = WZRichTextView()
    messageTextView.cachedContent = true
    messageTextView.interpreters = RichTextMessageView.interprets
    bubbleView.addSubview(messageTextView)
    
  }
  
  private func layoutMessageBubbleView(with textMessage: TextMessage) {
    
    bubbleView.set(frame: bounds, owerType: textMessage.ownerType)
    messageTextView.frame = bubbleView.containerBounds
    
  }
  
  private static func createRichTextStyle(textMessage: TextMessage) -> WZTextStyle {
    
    let textStyle = WZTextStyle()
    textStyle.textColor = textMessage.ownerType == .sender ? UIColor.white : #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
    textStyle.font = UIFont.systemFont(ofSize: 15)
    textStyle.backgroundColor = UIColor.clear
    
    return textStyle
  }
  
  private class func calculateTextSize(with textMessage: TextMessage) -> CGSize {
    
    let maxWidth = getMaxWidth(with: textMessage) * containerViewWidthRatio
    
    let textMaxWidth = maxWidth - RichTextMessageView.textViewMarginOfCloseToArrow - RichTextMessageView.textViewMarginOfNoArrow
    
    let textStyle = RichTextMessageView.createRichTextStyle(textMessage: textMessage)
    let textSize = WZRichTextView.calculateSize(text: textMessage.text, textStyle: textStyle, interpreters: interprets, maxWidth: textMaxWidth)
    
    return textSize
  }
}
