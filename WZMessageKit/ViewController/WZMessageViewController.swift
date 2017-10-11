//
//  WZMessageViewController.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit
import WZReusableView

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
  @objc optional func messageViewController(_ messageViewController: WZMessageViewController, configMessageContainerCell messageContainerCell: WZMessageContainerCell, atIndex index: Int)

}

//MARK:- WZMessageViewController
open class WZMessageViewController: UIViewController {
  
  public var messageTableView: WZMessageTableView!
  public var messageInputView: WZMessageInputView?
  public var bottomViewPoppingController: WZMessageBottomViewPoppingController?
  fileprivate var messageInputViewPopController: WZMessageInputViewPopController?
  fileprivate var timestampDisplayCache: [Int: Bool] = [:]
  fileprivate var canLoadData = true //用于标记是否在一次拖动中已经加载过数据，防止一次拖动多次加载
  fileprivate var actionsPerformWhenEndScrollingAnimation: [(() -> Void)] = []
  fileprivate var isDecelerating = false
  private var preloadedMessageCount = 0
  fileprivate var dateStringCache: [Int: String] = [:]
  private var isPreloadedAtFirst = false
  
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
    if !isPreloadedAtFirst {
      isPreloadedAtFirst = true
      preloadMessageData(viewHeight: messageTableView.frame.height)
      
      //保证首次预加载完成之后再加载tableview的数据
      reloadMessageData()
      scrollToBottomAnimated(isAnimated: false)
    }
    
    if let messageInputView = messageInputView {
      delegate?.messageViewController?(self, inputViewFrameChangeWithAnimation: messageInputView.frame)
    }
    
  }
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    showLoadingIfNeeded()
    
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    messageTableView.visibleCells.forEach { cell in
      
      guard let messageCell = cell as? WZMessageContainerCell else { return }
      messageCell.messageCellDidEndDisplay()
    }
  }
  
  deinit {
    WZMessageViewManager.shared.end()
  }
  
  /******************************************************************************
   *   method
   ******************************************************************************/
  //MARK: - method
  
  public func refresh(isScrollToBottom: Bool = true) {
    
    messageTableView.reloadData()
    
    if isScrollToBottom {
      scrollToBottomAnimated(isAnimated: true)
    }
    
  }
  
  public func reloadMessageData() {
    
    clearIsTimestampDisplayCache()
    messageTableView.reloadData()
    showLoadingIfNeeded()

  }
  
//  public func deleteMessage(at index: Int, animation: WZReusableViewCellAnimation, completion: @escaping ()->Void) {
//
//    removeAndForwardTimestampDisplayCache(at: index)
//    messageTableView.delete(at: index, with: animation, completion: completion)
//
//  }
  
  public func reloadData(at index: Int) {
    
    messageTableView.reload(indices: [index])

  }
  
  public func addInputView(inputView: WZMessageInputView) {
    
    inputView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    view.addSubview(inputView)
    view.bringSubview(toFront: inputView)
    
    if #available(iOS 11.0, *) {
      inputView.frame.origin.y -= navigationController!.view.safeAreaInsets.bottom
    }
    
    //管理messageInputView的弹出
    messageInputViewPopController = WZMessageInputViewPopController(delegate: self, inputView: inputView)
    messageInputView = inputView
    
    initPoppingBottomView()
  }
  
  public func finishLoadMoreMessages() {
    
    let viewHeight = messageTableView.frame.height
    
    preloadMessageData(viewHeight: viewHeight)
    
    let delay = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delay) {
      self.updateUIWhenFinishLoadMoreMessage()
    }
    
  }
  
  public func setStatus(_ status: WZMessageStatus, at index: Int) {
    
    if let cell = messageTableView.cell(at: index) as? WZMessageContainerCell {
      cell.setMessageStatus(status)
    }
  }
  
  public func addPoppingView(_ view: UIView) {
    bottomViewPoppingController?.addPoppingView(view)
  }
  
  public func togglePoppingView(_ view: UIView) {
    bottomViewPoppingController?.toggleView(view)
  }
  
  public func hidePoppingView(isNoticeDelegate: Bool) {
    bottomViewPoppingController?.hidePoppingView(isNoticeDelegate: isNoticeDelegate)
  }
  
  public func showKeyboard() {
    messageInputView?.showKeyboard()
  }
  
  public func hideKeyboard() {
    messageInputView?.hideKeyboard()
  }
  
  public func hideKeyboardAndBottomView() {
    bottomViewPoppingController?.hidePoppingView()
    messageInputView?.hideKeyboard()
  }
  
  public func setInputViewHidden(_ hidden: Bool, isAdjustBottomInset: Bool = true ) {
    
    guard let messageInputView = messageInputView, messageInputView.isHidden != hidden else { return }
    
    hideKeyboardAndBottomView()
    
    messageInputView.isHidden = hidden
    
    if isAdjustBottomInset {
      
      messageTableView.setTableViewInsets(bottom: hidden ? 0 : messageInputView.frame.height)
      
    }
    
    messageInputViewPopController?.enable = !hidden
    
  }
  
  public func scrollToBottomAnimated(isAnimated: Bool) {
    
    let numberOfCells = messageTableView.numberOfCells
    
    guard numberOfCells > 0 else { return }
    
    messageTableView.scroll(to: numberOfCells - 1, at: .bottom, animated: isAnimated)
  }
  
  //在不reload的情况下更新cell的messageData，不会更新UI
  public func updateCellMessageData(at index: Int) {
    
    guard let cell = messageTableView.cell(at: index) as? WZMessageContainerCell else { return }
    
    guard let messageData = fetchMessageData(at: index) else { return }
    
    cell.configureCell(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: index))
    
  }
  
  public func actionWhenScrollStop(_ action: @escaping ()->Void) {
    
    actionsPerformWhenEndScrollingAnimation.append(action)
    
  }
  
  public func getMessageView(at index: Int) -> WZMessageBaseView? {
    
    guard let cell = messageTableView.cell(at: index) as? WZMessageContainerCell, let messageBaseView = cell.customContentView else {
      
      return nil
    }
    
    return messageBaseView
  }
  
  /******************************************************************************
   *  private  method
   ******************************************************************************/
  //MARK: - private method
  
  private func setupUI() {
    
    view.backgroundColor = backgroundColor
    
    initMessageTableView()
    
  }
  
  private func initMessageTableView() {
    
    messageTableView = WZMessageTableView(frame: view.bounds)
    messageTableView.backgroundColor = backgroundColor
    messageTableView.reusableViewDelegate = self
    messageTableView.dataSource = self
    messageTableView.register(cellClass: messageContainerCellClass)
    view.addSubview(messageTableView)
    view.sendSubview(toBack: messageTableView)

    let tap = UITapGestureRecognizer(target: self, action: #selector(WZMessageViewController.onClickTableView))
    tap.cancelsTouchesInView = false
    messageTableView.addGestureRecognizer(tap)
    
  }
  
  private func initPoppingBottomView() {
    
    let bottomViewPoppingController = WZMessageBottomViewPoppingController(withSuperView: view)
    bottomViewPoppingController.delegate = messageInputViewPopController
    
    self.bottomViewPoppingController = bottomViewPoppingController
  }
  
  private func adjustDataCache(numberOfIncreasedMessages: Int) {
    
    for (index, timestamp) in timestampDisplayCache {
      timestampDisplayCache[numberOfIncreasedMessages + index] = timestamp
      timestampDisplayCache[index] = nil
    }
  }
  
  private func adjustTableViewOffset(previousNumberOfMessages: Int, previousContentOffsetY: CGFloat) {
    
    let currentNumberOfMessages = messageTableView.numberOfCells
    
    let previousFirstCellFrame = messageTableView.rect(at: currentNumberOfMessages - previousNumberOfMessages)
    
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
    
    guard delegate?.messageViewControllerWillLoadMoreMessages?(self) ?? false else {
      messageTableView.hideLoadingView()
      return
    }
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
  
  private func preloadMessageData(viewHeight: CGFloat) {
    
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
      WZMessageContainerCell.preloadData(messageData: messageData, isDisplayTime: isDisplayTimestamp, collectionViewHeight: viewHeight)
      
      if isDisplayTimestamp {
        let timeString = delegate?.messageViewController?(self, configTimeLabel: messageData.sendTime, atIndex: i) ?? ""
        dateStringCache[messageData.sendTime.hashValue] = timeString
      }
    }
  }
  
  private func updateUIWhenFinishLoadMoreMessage() {
    
    let previousContentOffsetY = messageTableView.contentOffset.y
    let previousNumberOfMessages = messageTableView.numberOfCells
    
    messageTableView.reloadData()
    
    //如果正在滚动则不调整contentOffset，不然会突然停住
    if !isDecelerating || isLoadViewDisplaying() {
      adjustTableViewOffset(previousNumberOfMessages: previousNumberOfMessages, previousContentOffsetY: previousContentOffsetY)
    }
    showLoadingIfNeeded()
    canLoadData = true
  }
  
  @objc private func onClickTableView() {
    hideKeyboardAndBottomView()
  }
}

//MARK:- UITableViewDataSourcea
extension WZMessageViewController: WZReusableViewDataSource {
  
  public func numberOfCells(_ reusableView: WZReusableView) -> Int {
    return dataSource?.numberOfMessageInMessageViewController(self) ?? 0
  }

  public func reusableView(_ reusableView: WZReusableView, cellAt index: Int) -> WZReusableCell {
    
    guard let messageData = fetchMessageData(at: index) else {
      return WZReusableCell(frame: .zero, contentViewType: UIView.self)
    }
    
    let cell = reusableView.dequeueReusableCell(contentViewType: messageData.mappingMessageView, for: index) as! WZMessageContainerCell
    cell.messageViewController = self
    cell.row = index
    
    if fetchIsTimestampDisplay(index: index) {
      
      if let timeString = dateStringCache[messageData.sendTime.hashValue] {
        
        cell.setTimeStamp(timeString)
        
      } else {
        
        let timeString = delegate?.messageViewController?(self, configTimeLabel: messageData.sendTime, atIndex: index) ?? ""
        cell.setTimeStamp(timeString)
        dateStringCache[messageData.sendTime.hashValue] = timeString
      }
    }
    
    delegate?.messageViewController?(self, configAvatarImageView: cell.avatarImageView, atIndex: index)
    
    cell.configureCell(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: index))
    
    delegate?.messageViewController?(self, configMessageContainerCell: cell, atIndex: index)

    return cell
    
  }
  
  public func reusableView(_ reusableView: WZReusableView, heightAt index: Int) -> CGFloat {
    
    guard let messageData = fetchMessageData(at: index) else {
      return 1
    }
    
    return WZMessageContainerCell.calculateMessageCellHeightWith(messageData: messageData, isDisplayTime: fetchIsTimestampDisplay(index: index))
    
  }
}

//MARK:- UITableViewDelegate
extension WZMessageViewController: WZReusableViewDelegate {
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    
    bottomViewPoppingController?.hidePoppingView()
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
  
  public func reusableView(_ reusableView: WZReusableView, willDisplay cell: WZReusableCell, at index: Int) {
    
    (cell as! WZMessageContainerCell).messageCellDidEndDisplay()
    
  }

  public func reusableView(_ reusableView: WZReusableView, didEndDisplaying cell: WZReusableCell, at index: Int) {
    
    if let messageData = fetchMessageData(at: index) {
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
    //    不这么写是因为当collectionView的高度变化的时候，contentOffset并不会改变，导致collectionView的cell并不会被抬高
    //    messageTableView.frame.size.height = currentFrame.maxY
    
    delegate?.messageViewController?(self, inputViewFrameChangeWithAnimation: currentFrame)
    
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
