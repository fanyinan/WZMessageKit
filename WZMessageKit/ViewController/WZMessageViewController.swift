//
//  WZMessageViewController.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

//MARK:- WZMessageViewControllerDataSource
public protocol WZMessageViewControllerDataSource: NSObjectProtocol {
  func messageViewController(_ messageViewController: WZMessageViewController, messageDataForCellAtRow row: Int) -> WZMessageData
  func numberOfMessageInMessageViewController(_ messageViewController: WZMessageViewController) -> Int
}

//MARK:- WZMessageViewControllerDelegate
@objc public protocol WZMessageViewControllerDelegate: NSObjectProtocol {
  
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, shouldDisplayTimestampAt index: Int) -> Bool
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, configAvatarImageView avatarImageView: UIImageView, atIndex index: Int)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, configTimeLabel date: Date, atIndex index: Int) -> String
  @objc optional func messageViewControllerWillLoadMoreMessages(_ messageViewController: WZMessageViewController) -> Bool
  @objc optional func messageViewControllerDidLoadMoreMessages(_ messageViewController: WZMessageViewController)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, didClickAvatarImageView avatarImageView: UIImageView, atIndex index: Int)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, didClickStatusView messageData: WZMessageData)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, messageContentView: WZMessageBaseView, onCatchEvent messageEvent: WZMessageEvent, atIndex index: Int)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, willDisplay messageData: WZMessageData)
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, inputViewFrameChangeWithAnimation inputViewFrame: CGRect)

}

//MARK:- WZMessageViewController
open class WZMessageViewController: UIViewController {
  
  public var messageTableView: WZMessageTableView!
  public var messageInputView: WZMessageInputView!
  public var bottomViewPoppingController: WZMessageBottomViewPoppingController!
  fileprivate var messageInputViewPopController: WZMessageInputViewPopController!
  fileprivate var timestampDisplayCache: [Int: Bool] = [:]
  fileprivate var canLoadData = true //用于标记是否在一次拖动中已经加载过数据，防止一次拖动多次加载
  fileprivate var actionsPerformWhenEndScrollingAnimation: [(() -> Void)] = []
  fileprivate var isDecelerating = false
  private var preloadedMessageCount = 0
  fileprivate var dateStringCache: [Int: String] = [:]
  
  public weak var delegate: WZMessageViewControllerDelegate?
  public weak var dataSource: WZMessageViewControllerDataSource?
  
  public var messageContainerCellClass = WZMessageContainerCell.self
  public var backgroundColor: UIColor = UIColor(hex: 0xeeeeee)
  
  public init() {
    super.init(nibName: nil, bundle: nil)
    
    WZMessageViewManager.shared.begin()
    
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - View lifecycle
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    //放在viewDidLayoutSubviews中可以获得tableview的实际尺寸
    preloadMessageData()
    
    //保证首次预加载完成之后再加载tableview的数据
    if messageTableView.dataSource == nil || messageTableView.delegate == nil {
      
      messageTableView.delegate = self
      messageTableView.dataSource = self
      
      reloadMessageData()
      scrollToBottomAnimated(isAnimated: false)
      
    }
    
  }
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    showLoadingIfNeeded()
    
  }
  
  deinit {
    WZMessageViewManager.shared.end()
  }
  
  /******************************************************************************
   *   method
   ******************************************************************************/
  //MARK: - method
  
  public func reloadMessageData() {
    
    clearIsTimestampDisplayCache()
    messageTableView.reloadData()
    
  }
  
  public func appendMessages(isScrollToBottom: Bool = true) {
    
    messageTableView.reloadData()
    
    if isScrollToBottom {
      scrollToBottomAnimated(isAnimated: true)
    }
    
  }
  
  public func deleteMessage(at index: Int, animation: UITableViewRowAnimation) {
    
    removeAndForwardTimestampDisplayCache(at: index)
    messageTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: animation)
    
  }
  
  public func reloadData(at index: Int) {
    
    messageTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    
  }
  
  public func addInputView(inputView: WZMessageInputView) {
    
    inputView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    view.addSubview(inputView)
    
    view.bringSubview(toFront: inputView)
    
    //管理messageInputView的弹出
    messageInputViewPopController = WZMessageInputViewPopController(delegate: self, inputView: inputView)
    messageInputView = inputView
    
    initPoppingBottomView()
  }
  
  public func finishLoadMoreMessages() {
    
    DispatchQueue.global().async {
      
      self.preloadMessageData()
      
      Thread.sleep(forTimeInterval: 0.1)
      
      DispatchQueue.main.async {
        
        self.updateUIWhenFinishLoadMoreMessage()
        
      }
    }
  }
  
  public func setStatus(_ status: WZMessageStatus, at index: Int) {
    
    if let cell = messageTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WZMessageContainerCell {
      cell.setMessageStatus(status)
    }
  }
  
  public func addPoppingView(_ view: UIView) {
    bottomViewPoppingController.addPoppingView(view)
  }
  
  public func togglePoppingView(_ view: UIView) {
    bottomViewPoppingController.toggleView(view)
  }
  
  public func hidePoppingView(isNoticeDelegate: Bool) {
    bottomViewPoppingController.hidePoppingView(isNoticeDelegate: isNoticeDelegate)
  }
  
  public func showKeyboard() {
    messageInputView.showKeyboard()
  }
  
  public func hideKeyboard() {
    messageInputView.hideKeyboard()
  }
  
  public func hideKeyboardAndBottomView() {
    bottomViewPoppingController.hidePoppingView()
    messageInputView.hideKeyboard()
  }
  
  public func setInputViewHidden(_ hidden: Bool, isAdjustBottomInset: Bool = true ) {
    
    guard messageInputView.isHidden != hidden else { return }
    
    hideKeyboardAndBottomView()
    
    messageInputView.isHidden = hidden
    
    if isAdjustBottomInset {
      
      messageTableView.setTableViewInsets(bottom: hidden == true ? 0 : messageInputView.frame.height)
      
    }
    
    messageInputViewPopController.enable = !hidden
    
  }
  
  public func scrollToBottomAnimated(isAnimated: Bool) {
    
    let numberOfRows = messageTableView.numberOfRows(inSection: 0)
    
    guard numberOfRows > 0 else { return }
    
    messageTableView.scrollToRow(at: IndexPath(row: numberOfRows - 1, section: 0), at: .bottom, animated: isAnimated)
    
  }
  
  //在不reload的情况下更新cell的messageData，不会更新UI
  public func updateCellMessageData(at index: Int) {
    
    guard let cell = messageTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WZMessageContainerCell else { return }
    
    guard let messageData = fetchMessageData(at: index) else { return }
    
    cell.configureCell(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: index))
    
  }
  
  public func actionWhenScrollStop(_ action: @escaping ()->Void) {
    
    actionsPerformWhenEndScrollingAnimation.append(action)
    
  }
  
  public func getMessageView(at index: Int) -> WZMessageBaseView? {
    
    guard let cell = messageTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WZMessageContainerCell, let messageBaseView = cell.customContentView else {
      
      return nil
    }
    
    return messageBaseView
  }
  
  /******************************************************************************
   *  private  method
   ******************************************************************************/
  //MARK: - private method
  
  fileprivate func setupUI() {
    
    view.backgroundColor = backgroundColor
    
    initMessageTableView()
    
  }
  
  fileprivate func initMessageTableView() {
    
    messageTableView = WZMessageTableView(frame: view.bounds)
    messageTableView.backgroundColor = backgroundColor

    let tap = UITapGestureRecognizer(target: self, action: #selector(WZMessageViewController.onClickTableView))
    tap.cancelsTouchesInView = false
    messageTableView.addGestureRecognizer(tap)
    view.addSubview(messageTableView)
    view.sendSubview(toBack: messageTableView)
    
  }

  fileprivate func initPoppingBottomView() {
    
    bottomViewPoppingController = WZMessageBottomViewPoppingController(withSuperView: view)
    bottomViewPoppingController.delegate = messageInputViewPopController
    
  }
  
  private func adjustDataCache(numberOfIncreasedMessages: Int) {
    
    for (index, timestamp) in timestampDisplayCache {
      timestampDisplayCache[numberOfIncreasedMessages + index] = timestamp
      timestampDisplayCache[index] = nil
    }
  }
  
  private func adjustTableViewOffset(previousNumberOfMessages: Int, previousContentOffsetY: CGFloat) {
    
    let currentNumberOfMessages = messageTableView.numberOfRows(inSection: 0)
    
    let previousFirstCellFrame = messageTableView.rectForRow(at: IndexPath(item: currentNumberOfMessages - previousNumberOfMessages, section: 0))
    
    messageTableView.setContentOffset(CGPoint(x: 0, y: previousFirstCellFrame.minY + previousContentOffsetY), animated: false)
    
  }
  
  fileprivate func fetchMessageData(at index: Int) -> WZMessageData? {
      
    return dataSource?.messageViewController(self, messageDataForCellAtRow: index)
  }
  
  /**
   获取是否显示时间
   */
  fileprivate func fetchIsTimestampDisplay(index: Int) -> Bool {
    
    if let isDisplay = timestampDisplayCache[index] {
      return isDisplay
    } else {
      
      guard let isDisplay = delegate?.messageViewController?(self, shouldDisplayTimestampAt: index) else {
        return false
      }
      
      timestampDisplayCache[index] = isDisplay
      return isDisplay
      
    }
  }
  
  /**
   清空缓存记录
   */
  fileprivate func clearIsTimestampDisplayCache() {
    timestampDisplayCache.removeAll()
  }
  
  /**
   如果需要显示loading则显示
   */
  fileprivate func showLoadingIfNeeded() {
    
    guard delegate?.messageViewControllerWillLoadMoreMessages?(self) ?? false else { return }
    messageTableView.showLoadingView()
    
  }
  
  /**
   执行加载历史数据
   */
  fileprivate func loadingMoreDataIfNeeded() {
    
    //是否滚动到最顶端停止
    guard canLoadData && isLoadViewDisplaying() else { return }
    
    guard delegate?.messageViewControllerWillLoadMoreMessages?(self) ?? false else { return }
    
    canLoadData = false
    
    delegate?.messageViewControllerDidLoadMoreMessages?(self)
    
  }
  
  private func isLoadViewDisplaying() -> Bool {
    
    return -messageTableView.contentOffset.y >= messageTableView.contentInset.top - messageTableView.loadingView.frame.height
    
  }
  
  fileprivate func removeAndForwardTimestampDisplayCache(at index: Int) {
    
    for (rowInTraverse, isTimestampDisplay) in timestampDisplayCache {
      
      if rowInTraverse > index {
        
        timestampDisplayCache[rowInTraverse - 1] = isTimestampDisplay
        timestampDisplayCache[rowInTraverse] = nil
      }
    }
  }
  
  private func preloadMessageData() {
    
    let messageCount = dataSource?.numberOfMessageInMessageViewController(self) ?? 0
    let numberOfIncreasedMessages = messageCount - preloadedMessageCount
    
    guard numberOfIncreasedMessages != 0 else { return }
    
    preloadedMessageCount = messageCount
    
    adjustDataCache(numberOfIncreasedMessages: numberOfIncreasedMessages)
    
    //必须正向遍历，因为时间戳是否显示是从较早的时间计算
    for i in 0..<numberOfIncreasedMessages {
      let _ = fetchIsTimestampDisplay(index: i)
    }
    
    //messageView的预加载要倒序进行，因为需要计算同时最多显示的同一种类型的cell的数量
    for i in (0..<numberOfIncreasedMessages).reversed() {
      
      guard let messageData = fetchMessageData(at: i) else { continue }
      
      let isDisplayTimestamp = fetchIsTimestampDisplay(index: i)
      WZMessageContainerCell.preloadData(messageData: messageData, isDisplayTime: isDisplayTimestamp, tableViewHeight: messageTableView.frame.height)
      
      if isDisplayTimestamp {
        let timeString = delegate?.messageViewController?(self, configTimeLabel: messageData.sendTime, atIndex: i) ?? ""
        dateStringCache[messageData.sendTime.hashValue] = timeString
      }
    }
  }
  
  private func updateUIWhenFinishLoadMoreMessage() {
    
    let previousContentOffsetY = messageTableView.contentOffset.y
    let previousNumberOfMessages = messageTableView.numberOfRows(inSection: 0)
    
    messageTableView.reloadData()
    
    //如果正在滚动则不调整contentOffset，不然会突然停住
    if !isDecelerating || isLoadViewDisplaying() {
      adjustTableViewOffset(previousNumberOfMessages: previousNumberOfMessages, previousContentOffsetY: previousContentOffsetY)
    }
    messageTableView.hideLoadingView()
    showLoadingIfNeeded()
    canLoadData = true
  }
  
  @objc private func onClickTableView() {
    hideKeyboardAndBottomView()
  }
}

//MARK:- UITableViewDataSourcea
extension WZMessageViewController: UITableViewDataSource {
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource?.numberOfMessageInMessageViewController(self) ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let row = indexPath.row
    
    guard let messageData = fetchMessageData(at: row) else {
      return UITableViewCell(style: .default, reuseIdentifier: nil)
    }
    
    let identifier = String(describing: messageData.mappingMessageView)
    
    var cell: WZMessageContainerCell!
    
    if let _cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WZMessageContainerCell {
      cell = _cell
    } else {
      tableView.register(messageContainerCellClass, forCellReuseIdentifier: identifier)
      cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! WZMessageContainerCell
    }
    
    cell.messageViewController = self
    cell.row = row
    
    if fetchIsTimestampDisplay(index: row) {
      
      if let timeString = dateStringCache[messageData.sendTime.hashValue] {
        
        cell.setTimeStamp(timeString)
        
      } else {
        
        let timeString = delegate?.messageViewController?(self, configTimeLabel: messageData.sendTime, atIndex: row) ?? ""
        cell.setTimeStamp(timeString)
        dateStringCache[messageData.sendTime.hashValue] = timeString
      }
    }
    
    delegate?.messageViewController?(self, configAvatarImageView: cell.avatarImageView, atIndex: row)
    
    cell.configureCell(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: row))
    
    return cell
    
  }
}

//MARK:- UITableViewDelegate
extension WZMessageViewController: UITableViewDelegate {
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    let row = indexPath.row
    
    guard let messageData = fetchMessageData(at: row) else {
      return 1
    }
    
    return WZMessageContainerCell.calculateMessageCellHeightWith(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: row))
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    bottomViewPoppingController.hidePoppingView()
    hideKeyboardAndBottomView()
    
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    isDecelerating = decelerate
    
    guard !decelerate else { return }
    loadingMoreDataIfNeeded()
    
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    isDecelerating = false
    
    loadingMoreDataIfNeeded()
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    
    for action in actionsPerformWhenEndScrollingAnimation {
      action()
    }
    
    actionsPerformWhenEndScrollingAnimation.removeAll()
    
  }
  
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    (cell as! WZMessageContainerCell).messageCellDidEndDisplay()
    
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if let messageData = fetchMessageData(at: indexPath.row) {
      delegate?.messageViewController?(self, willDisplay: messageData)
    }
    (cell as! WZMessageContainerCell).messageCellWillDisplay()
    
  }
  
  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    
    loadingMoreDataIfNeeded()
    
  }
}

//MARK:- WZMessageInputViewPopControllerDelegate
extension WZMessageViewController: WZMessageInputViewPopControllerDelegate {
  
  func inputViewPopController(_ inputViewPopController: WZMessageInputViewPopController, inputViewFrameChangeWithAnimation originFrame: CGRect, currentFrame: CGRect) {
    
    //当输入框被抬高时将messageTableView上移，同时改变contentInset.top
    let offsetLength = currentFrame.maxY - originFrame.maxY
    messageTableView.frame.origin.y = currentFrame.maxY - messageTableView.frame.height
    messageTableView.changeTableViewInsets(topIncrement: -offsetLength)
    
    //    不这么写是因为当tableView的高度变化的时候，contentOffset并不会改变，导致tableView的cell并不会被抬高
    //    messageTableView.frame.size.height = currentFrame.maxY
    
    
  }
}

//MARK:- WZMessageContainerCellDelegate
extension WZMessageViewController: WZMessageContainerCellDelegate {
  
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickAvatarImageView avatarImageView: UIImageView) {
    delegate?.messageViewController?(self, didClickAvatarImageView: avatarImageView, atIndex: messageContainerCell.row)
  }
  
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, didClickStatusView messageStatus: WZMessageStatus) {
    
    delegate?.messageViewController?(self, didClickStatusView: messageContainerCell.messageData)
    
  }
  
  func messageContainerCell(_ messageContainerCell: WZMessageContainerCell, messageEvent: WZMessageEvent) {
    delegate?.messageViewController?(self, messageContentView: messageContainerCell.customContentView, onCatchEvent: messageEvent, atIndex: messageContainerCell.row)
  }
}
