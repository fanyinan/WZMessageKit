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
  private var timestampView: UIView!
  private var messageContainerView: UIView!
  private var avatarButton: UIControl!
  private(set) var avatarImageView: UIImageView!
  private(set) var timestampLabel: UILabel!
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
  
  open static let timestampViewHeight: CGFloat = 40
  open static let contentMargin: CGFloat = 10
  open static let avatarSize: CGFloat = 45
  
  fileprivate(set) var messageData: WZMessageData!
  fileprivate(set) var isDisplayTimestamp: Bool = true
  
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
    
    configTimestamp()
    layoutMessageContainerView()
    configAvatarWithMessage()
    configCustomContentView()
    configStatusView()
    
  }
  
  public func configureCell(messageData: WZMessageData, isDisplayTimestamp: Bool) {
    
    self.messageData = messageData
    self.isDisplayTimestamp = isDisplayTimestamp
    
    delegate = messageViewController as WZMessageContainerCellDelegate
  }
  
  public func setTimeStamp(_ timeString: String) {
    
    guard timestampLabel.text != timeString else { return }
    timestampLabel.text = timeString
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
  
  public class func calculateMessageCellHeightWith(messageData: WZMessageData, isDisplayTimestamp: Bool) -> CGFloat {
    
    return calculateMessageCellHeightWith(messageData: messageData, customContentViewHeight: calculateMessageCustomContentView(with: messageData).height, isDisplayTimestamp: isDisplayTimestamp)
  }
  
  public class func preloadData(messageData: WZMessageData, isDisplayTimestamp: Bool, tableViewHeight: CGFloat) {
    
    messageData.mappingMessageView.preloadData(with: messageData)
    
    let cellHeight = calculateMessageCellHeightWith(messageData: messageData, isDisplayTimestamp: isDisplayTimestamp)
    WZMessageViewManager.shared.preload(with: messageData.mappingMessageView, with: cellHeight, maxHeight: tableViewHeight)
  }
  
  public class func getCustomViewMaxWidth(with messageData: WZMessageData) -> CGFloat {
    
    if messageData.ownerType == .custom {
      
      return UIScreen.main.bounds.width - contentMargin * 2
      
    } else {
      
      return UIScreen.main.bounds.width - contentMargin * 2 - avatarSize
      
    }
  }
  
  
  @objc private func statusViewClick(_ sender: WZMessageStatusView) {
    delegate?.messageContainerCell(self, didClickStatusView: sender.status)
  }
  
  @objc private func onClickAvatar(_ sender: UIControl) {
    delegate?.messageContainerCell(self, didClickAvatarImageView: avatarImageView)
  }
  
  open func createTimestampLabel() -> UILabel {
    
    let timestampLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 18))
    timestampLabel.textColor = .subText
    timestampLabel.font = UIFont.systemFont(ofSize: 12)
    timestampLabel.backgroundColor = UIColor(hex: 0xeeeeee)
    timestampLabel.textAlignment = .center
    
    return timestampLabel
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
  
  open func configTimestamp() {
    
    timestampView.isHidden = !isDisplayTimestamp
    
    timestampView.po_frameBuilder().alignToTopInSuperview(withInset: 0)
    timestampView.po_frameBuilder().setWidth(contentView.frame.width)
    timestampView.po_frameBuilder().alignLeftInSuperview(withInset: 0)
    timestampView.po_frameBuilder().setHeight(isDisplayTimestamp == true ? WZMessageContainerCell.timestampViewHeight : 0)
  }
  
  open func configAvatarWithMessage() {
    
    avatarButton.isHidden = messageData.ownerType == .custom
    
    guard !avatarButton.isHidden else { return }
    
    avatarButton.po_frameBuilder().alignToTopInSuperview(withInset: 0)
    avatarButton.po_frameBuilder().setSizeWithWidth(WZMessageContainerCell.avatarSize, height: WZMessageContainerCell.avatarSize)
    if messageData.ownerType == .sender {
      avatarButton.po_frameBuilder().alignRightInSuperview(withInset: WZMessageContainerCell.contentMargin)
    } else if messageData.ownerType == .receiver{
      avatarButton.po_frameBuilder().alignLeftInSuperview(withInset: WZMessageContainerCell.contentMargin)
    }
    
  }
  
  open func configCustomContentView() {
    
    customContentView.po_frameBuilder().alignToTopInSuperview(withInset: 0)
    customContentView.po_frameBuilder().setSize(type(of: self).calculateMessageCustomContentView(with: messageData))
    
    if messageData.ownerType != .custom {
      
      if messageData.ownerType == .sender {
        //        customContentView.po_frameBuilder().alignRightInSuperviewWithInset(WZMessageContainerCell.contentMargin)
        
        customContentView.po_frameBuilder().alignLeft(of: avatarButton, offset: WZMessageContainerCell.contentMargin)
        
      } else if messageData.ownerType == .receiver{
        customContentView.po_frameBuilder().alignRight(of: avatarButton, offset: WZMessageContainerCell.contentMargin)
      }
      
    } else {
      
      customContentView.po_frameBuilder().alignLeftInSuperview(withInset: WZMessageContainerCell.contentMargin)
      
    }
    
    customContentView.configContentView(with: messageData)
    
  }
  
  open func configStatusView() {
    
    let isShowStatus = messageData.ownerType == .sender
    statusView.isHidden = !isShowStatus
    
    if isShowStatus {
      setMessageStatus(messageData.status)
    }
    
    if messageData.ownerType == .sender {
      statusView.po_frameBuilder().alignLeft(of: customContentView, offset: 5)
    } else {
      statusView.po_frameBuilder().alignRight(of: customContentView, offset: 5)
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
    initTimestampLabel()
    initStatusView()
    
  }
  
  private func initContainerView() {
    
    timestampView = UIView()
    contentView.addSubview(timestampView)
    
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
  
  private func initTimestampLabel() {
    
    timestampLabel = createTimestampLabel()
    timestampView.addSubview(timestampLabel)
    timestampLabel.center = timestampView.center
    
  }
  
  private func layoutMessageContainerView() {
    
    messageContainerView.po_frameBuilder().align(toBottomOf: timestampView, offset: 0)
    messageContainerView.po_frameBuilder().setHeight(contentView.frame.height - timestampView.frame.height)
    messageContainerView.po_frameBuilder().setWidth(contentView.frame.width)
    messageContainerView.po_frameBuilder().alignLeftInSuperview(withInset: 0)
    
  }
  
  private class func getCellEdgesHeightWithMessage(isDisplayTimestamp: Bool) -> CGFloat {
    
    var cellEdgesHeight = contentMargin * 2
    
    if isDisplayTimestamp {
      cellEdgesHeight += timestampViewHeight
    }
    
    return cellEdgesHeight
  }
  
  fileprivate class func calculateMessageCellHeightWith(messageData: WZMessageData, customContentViewHeight: CGFloat, isDisplayTimestamp: Bool) -> CGFloat {
    
    //当消息类型不为custom时，customContentViewHeight和avatarSize中去较大的
    let cellHeight = max(messageData.ownerType == .custom ? 0 : WZMessageContainerCell.avatarSize, customContentViewHeight) + getCellEdgesHeightWithMessage(isDisplayTimestamp: isDisplayTimestamp) + 0.5
    
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
