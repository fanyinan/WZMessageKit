//
//  WZMessageAvatarCell.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/1.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

protocol WZMessageContainerCellDelegate: NSObjectProtocol {
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickAvatarImageView avatarImageView: UIImageView)
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickStatusView messageStatus: WZMessageStatus)
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, messageEvent: WZMessageEvent)
}

open class WZMessageContainerCell: UITableViewCell {
  
  public var customContentView: WZMessageBaseView!
  private var timeView: UIView!
  private var messageContainerView: UIView!
  private var avatarButton: UIControl!
  private(set) var avatarImageView: UIImageView!
  private(set) var timeLabel: UILabel!
  private(set) var statusView: WZMessageStatusView!
  private var contentViewType: WZMessageBaseView.Type!
  
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
  
  required override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentViewType = WZMessageViewManager.shared.messageViewType(typeIdentifier: reuseIdentifier!)
    setupUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    
    guard messageData != nil else { return }
    
    configTime()
    layoutMessageContainerView()
    configAvatarWithMessage()
    configCustomContentView()
    configStatusView()
    
  }
  
  public func configureCell(messageData: WZMessageData, isDisplayTime: Bool) {
    
    self.messageData = messageData
    self.isDisplayTime = isDisplayTime
    
    delegate = messageViewController as WZMessageContainerCellDelegate
  }
  
  public func setTimeStamp(_ timeString: String) {
    
    guard timeLabel.text != timeString else { return }
    timeLabel.text = timeString
  }
  
  public func setMessageStatus(_ status: WZMessageStatus) {
    statusView.setupUI(status: status)
  }
  
  public func reload(scrollToBottom: Bool) {
    
    let indexPath = IndexPath(row: row, section: 0)
    
    messageViewController.messageTableView.reloadRows(at: [indexPath], with: .none)
    
    if scrollToBottom {
      messageViewController.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
  
  public class func preloadData(messageData: WZMessageData, isDisplayTime: Bool, tableViewHeight: CGFloat) {
    
    messageData.mappingMessageView.preloadData(with: messageData)
    
    let cellHeight = calculateMessageCellHeightWith(messageData: messageData, isDisplayTime: isDisplayTime)
    WZMessageViewManager.shared.preload(with: messageData.mappingMessageView, with: cellHeight, maxHeight: tableViewHeight)
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
  
  @objc private func onClickAvatar(_ sender: UIControl) {
    delegate?.messageContainerCell(self, didClickAvatarImageView: avatarImageView)
  }
  
  open func createTimeLabel() -> UILabel {
    
    let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 18))
    timeLabel.textColor = .subText
    timeLabel.font = UIFont.systemFont(ofSize: 12)
    timeLabel.backgroundColor = messageViewController.backgroundColor
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
    avatarImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    
    return avatarImageView
  }
  
  open func configTime() {
    
    timeView.isHidden = !isDisplayTime
    
    let height = isDisplayTime ? WZMessageContainerCell.timeViewHeight : 0
    timeView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: height)
 
    timeLabel.frame = timeView.bounds

  }
  
  open func configAvatarWithMessage() {
    
    avatarButton.isHidden = messageData.ownerType == .custom
    
    guard !avatarButton.isHidden else { return }
    
    avatarButton.frame.size = CGSize(width: WZMessageContainerCell.avatarSideLength, height: WZMessageContainerCell.avatarSideLength)
    if messageData.ownerType == .sender {
      avatarButton.frame.origin.x = messageContainerView.frame.width - WZMessageContainerCell.contentMargin - WZMessageContainerCell.avatarSideLength
    } else if messageData.ownerType == .receiver{
      avatarButton.frame.origin.x = WZMessageContainerCell.contentMargin
    }
  }
  
  open func configCustomContentView() {
    
    customContentView.frame.size = type(of: self).calculateMessageCustomContentView(with: messageData)
    
    if messageData.ownerType != .custom {
      
      if messageData.ownerType == .sender {
        
        customContentView.frame.origin.x = avatarButton.frame.minX - WZMessageContainerCell.contentMargin - customContentView.frame.width
        
      } else if messageData.ownerType == .receiver{
        
        customContentView.frame.origin.x = avatarButton.frame.maxX + WZMessageContainerCell.contentMargin
        
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
  
  private func setupUI() {
    
    selectionStyle = .none
    contentView.backgroundColor = UIColor.clear
    backgroundColor = UIColor.clear
    
    initContainerView()
    initAvatar()
    initCustomView()
    initTimeLabel()
    initStatusView()
    
  }
  
  private func initContainerView() {
    
    timeView = UIView()
    contentView.addSubview(timeView)
    
    messageContainerView = UIView()
    contentView.addSubview(messageContainerView)
    
  }
  
  private func initAvatar() {
    
    avatarButton = UIControl()
    messageContainerView.addSubview(avatarButton)
    avatarButton.addTarget(self, action: #selector(WZMessageContainerCell.onClickAvatar(_:)), for: .touchUpInside)
    
    avatarImageView = createAvatarImageView()
    avatarButton.addSubview(avatarImageView)
    
  }
  
  private func initCustomView() {
    
    customContentView = WZMessageViewManager.shared.fetch(with: contentViewType)
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
    
    let frame = CGRect(x: 0, y: timeView.frame.maxY, width: contentView.frame.width, height: contentView.frame.height - timeView.frame.height)
    messageContainerView.frame = frame

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
