//
//  WZMessageAvatarCell.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/1.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import WZReusableView

protocol WZMessageContainerCellDelegate: NSObjectProtocol {
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickAvatarImageView avatarImageView: UIImageView)
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickStatusView messageStatus: WZMessageStatus)
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, messageEvent: WZMessageEvent)
}

open class WZMessageContainerCell: WZReusableCell {
  
  public var customContentView: WZMessageBaseView!
  private var timeView: UIView!
  public private(set) var messageContainerView: UIView!
  public private(set) var avatarImageView: UIImageView!
  private(set) var timeLabel: UILabel!
  private(set) var statusView: WZMessageStatusView!
  
  var row: Int! {
    didSet{
      customContentView.row = row
    }
  }
  
  weak var messageViewController: WZMessageViewController! {
    didSet{
      customContentView.messageViewController = messageViewController
    }
  }
  
  open static let timeViewHeight: CGFloat = 40
  open static let contentMargin: CGFloat = 10
  open static let avatarSideLength: CGFloat = 45
  open static let statusViewMargin: CGFloat = 5
  
  fileprivate(set) var messageData: WZMessageData!
  fileprivate(set) var isDisplayTime: Bool = true
  
  fileprivate weak var delegate: WZMessageContainerCellDelegate?
  
  required public init(frame: CGRect, contentViewType: UIView.Type) {
    super.init(frame: frame, contentViewType: contentViewType)
    setupUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func setupUI() {
    
    backgroundColor = UIColor.clear
    
    initContainerView()
    initAvatar()
    initCustomView()
    initTimeLabel()
    initStatusView()
    
  }
  
  open func configureCell(messageData: WZMessageData, isDisplayTime: Bool) {
    
    self.messageData = messageData
    self.isDisplayTime = isDisplayTime
    
    delegate = messageViewController as WZMessageContainerCellDelegate
    
    configTime()
    layoutMessageContainerView()
    configAvatarWithMessage()
    configCustomContentView()
    configStatusView()
  }
  
  public func setTimeStamp(_ timeString: String) {
    
    guard timeLabel.text != timeString else { return }
    timeLabel.text = timeString
  }
  
  public func setMessageStatus(_ status: WZMessageStatus) {
    statusView.setupUI(status: status)
  }
  
  public func reload(scrollToBottom: Bool) {
    
    messageViewController.messageTableView.reload(indices: [row])
    
    if scrollToBottom {
      messageViewController.messageTableView.scroll(to: row, at: .bottom, animated: true)
    }
  }
  
  public func messageCellDidEndDisplay() {
    customContentView.messageViewDidEndDisplay()
  }
  
  public func messageCellWillDisplay() {
    customContentView.messageViewWillDisplay()
  }
  
  public class func calculateMessageCellHeightWith(messageData: WZMessageData, isDisplayTime: Bool) -> CGFloat {
    
    return calculateMessageCellHeightWith(messageData: messageData, customContentViewHeight: calculateMessageCustomContentView(with: messageData).height, isDisplayTime: isDisplayTime)
  }
  
  public class func preloadData(messageData: WZMessageData, isDisplayTime: Bool, collectionViewHeight: CGFloat) {
    
    messageData.mappingMessageView.preloadData(with: messageData)
    
    let cellHeight = calculateMessageCellHeightWith(messageData: messageData, isDisplayTime: isDisplayTime)
    WZMessageViewManager.shared.preload(with: messageData.mappingMessageView, with: cellHeight, maxHeight: collectionViewHeight)
  }
  
  public class func getCustomViewMaxWidth(with messageData: WZMessageData) -> CGFloat {
    
    if messageData.ownerType == .custom {
      
      return UIScreen.main.bounds.width - contentMargin * 2
      
    } else {
      
      return UIScreen.main.bounds.width - contentMargin * 2 - avatarSideLength
      
    }
  }
  
  
  @objc private func statusViewClick(_ sender: WZMessageStatusView) {
    delegate?.messageContainerCell(self, didClickStatusView: sender.status)
  }
  
  @objc private func onClickAvatar() {
    delegate?.messageContainerCell(self, didClickAvatarImageView: avatarImageView)
  }
  
  open func createTimeLabel() -> UILabel {
    
    let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 18))
    timeLabel.textColor = .subText
    timeLabel.font = UIFont.systemFont(ofSize: 12)
    timeLabel.textAlignment = .center
    
    return timeLabel
  }
  
  open func createStatusView() -> WZMessageStatusView {
    
    return WZMessageStatusView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
  }
  
  open func createAvatarImageView() -> UIImageView {
    
    let avatarImageView = UIImageView()
    avatarImageView.contentMode = .scaleAspectFill
    avatarImageView.clipsToBounds = true
    
    return avatarImageView
  }
  
  open func configTime() {
    
    timeView.isHidden = !isDisplayTime
    
    let height = isDisplayTime ? WZMessageContainerCell.timeViewHeight : 0
    timeView.frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
    timeLabel.frame = timeView.bounds

  }
  
  open func configAvatarWithMessage() {
    
    avatarImageView.isHidden = messageData.ownerType == .custom
    
    guard !avatarImageView.isHidden else { return }
    
    avatarImageView.frame.size = CGSize(width: WZMessageContainerCell.avatarSideLength, height: WZMessageContainerCell.avatarSideLength)
    if messageData.ownerType == .sender {
      avatarImageView.frame.origin.x = messageContainerView.frame.width - WZMessageContainerCell.contentMargin - WZMessageContainerCell.avatarSideLength
    } else if messageData.ownerType == .receiver{
      avatarImageView.frame.origin.x = WZMessageContainerCell.contentMargin
    }
  }
  
  open func configCustomContentView() {
    
    customContentView.frame.size = type(of: self).calculateMessageCustomContentView(with: messageData)
    
    if messageData.ownerType != .custom {
      
      if messageData.ownerType == .sender {
        
        customContentView.frame.origin.x = avatarImageView.frame.minX - WZMessageContainerCell.contentMargin - customContentView.frame.width
        
      } else if messageData.ownerType == .receiver{
        
        customContentView.frame.origin.x = avatarImageView.frame.maxX + WZMessageContainerCell.contentMargin
        
      }
      
    } else {
      
      customContentView.center.x = messageContainerView.frame.midX
      
    }
    
    customContentView.configContentView(with: messageData)
    
  }
  
  open func configStatusView() {
    
    setMessageStatus(messageData.status)
    
    if messageData.ownerType == .sender {
      statusView.frame.origin.x = customContentView.frame.minX - WZMessageContainerCell.statusViewMargin - statusView.frame.width
    } else {
      statusView.frame.origin.x = customContentView.frame.maxX + WZMessageContainerCell.statusViewMargin
    }
    
    statusView.center.y = customContentView.frame.height / 2
    
  }
  
  private func initStatusView() {
    
    statusView = createStatusView()
    messageContainerView.addSubview(statusView)
    statusView.addTarget(self, action: #selector(WZMessageContainerCell.statusViewClick(_:)), for: .touchUpInside)
  }
  
  private func initContainerView() {
    
    timeView = UIView()
    addSubview(timeView)
    
    messageContainerView = UIView()
    addSubview(messageContainerView)
  }
  
  private func initAvatar() {
    
    avatarImageView = createAvatarImageView()
    messageContainerView.addSubview(avatarImageView)
    
    avatarImageView.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(onClickAvatar))
    avatarImageView.addGestureRecognizer(tap)
    
  }
  
  private func initCustomView() {
    
    customContentView = WZMessageViewManager.shared.fetch(with: contentViewType as! WZMessageBaseView.Type)
    customContentView.messageCell = self
    customContentView.delegate = self
    messageContainerView.addSubview(customContentView)
    
  }
  
  private func initTimeLabel() {
    
    timeLabel = createTimeLabel()
    timeView.addSubview(timeLabel)
    timeLabel.center = timeView.center
    
  }
  
  private func layoutMessageContainerView() {
    
    messageContainerView.frame = CGRect(x: 0, y: timeView.frame.maxY, width: frame.width, height: frame.height - timeView.frame.height)

  }
  
  private class func getCellEdgesHeightWithMessage(isDisplayTime: Bool) -> CGFloat {
    
    var cellEdgesHeight = contentMargin * 2
    
    if isDisplayTime {
      cellEdgesHeight += timeViewHeight
    }
    
    return cellEdgesHeight
  }
  
  fileprivate class func calculateMessageCellHeightWith(messageData: WZMessageData, customContentViewHeight: CGFloat, isDisplayTime: Bool) -> CGFloat {
    
    //当消息类型不为custom时，customContentViewHeight和avatarSideLength中去较大的
    let cellHeight = max(messageData.ownerType == .custom ? 0 : WZMessageContainerCell.avatarSideLength, customContentViewHeight) + getCellEdgesHeightWithMessage(isDisplayTime: isDisplayTime) + 0.5
    
    return cellHeight
  }
  
  fileprivate class func calculateMessageCustomContentView(with messageData: WZMessageData) -> CGSize {
    return messageData.mappingMessageView.contentViewSize(with: messageData)
  }
}

extension WZMessageContainerCell: WZMessageContentViewDelegate {
  public func onCatchEvent(event: WZMessageEvent) {
    event.messageData = messageData
    delegate?.messageContainerCell(self, messageEvent: event)
  }
}
