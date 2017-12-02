//
//  ImageMessageView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/1/20.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

class ImageMessageView: WZMessageBaseView {
  
  private var messageImageView: UIImageView!
  private var imageMessageData: ImageMessage!
  private var loadingView: UIActivityIndicatorView!
  private(set) var imageLoaded = false
  
  static let thumbImageMaxSize = CGSize(width: UIScreen.main.bounds.width * 0.6, height: 200)
  static let imageDefaultSize = CGSize(width: 100, height: 100)

  override func initView() {
    
    setupUI()
    addTapGestureRecognizer()
  }
  
  override func configContentView(with messageData: WZMessageData) {
    
    imageMessageData = messageData as! ImageMessage
    
    layoutMessageImageView(imageMessageData)
    configImageView(imageMessageData)
    
  }
  
  override class func contentViewSize(with messageData: WZMessageData) -> CGSize {
    
    let imageMessageData = messageData as! ImageMessage
    
    let url = WebImageTools.getImageURLForIM(with: imageMessageData.imageURL)
    let imageSize = WZMessageCellTools.calculateImageSize(with: url, maxSize: ImageMessageView.thumbImageMaxSize) ?? ImageMessageView.imageDefaultSize
    
    return imageSize
  }
  
  override class func preloadData(with messageData: WZMessageData) {
    
    guard let imageMessageData = messageData as? ImageMessage else { return }
    
    _ = WebImageTools.fetchLocalImageData(with: WebImageTools.getImageURLForIM(with: imageMessageData.imageURL))
    
  }
  
  override func onClickMessage() {
    
    guard imageLoaded else { return }
    
    delegate?.onCatchEvent(event: WZMessageEvent(eventType: .tap))
    
  }
  
  @objc func onLongPress(gesture: UILongPressGestureRecognizer) {
    
    switch gesture.state {
    case .began:
      delegate?.onCatchEvent(event: WZMessageEvent(eventType: .longPress))
    default:
      break
    }
  }
  
  //for AnimatedTransition
  func getImageViewFrameInCell() -> CGRect {
    
    return messageCell!.convert(messageImageView.frame, from: self)
  }
  
  //for AnimatedTransition
  func getImage() -> UIImage? {
    return messageImageView.image
  }
  
  private func setupUI() {
    
    let longTap = UILongPressGestureRecognizer(target: self, action: #selector(ImageMessageView.onLongPress(gesture:)))
    addGestureRecognizer(longTap)
    
    messageImageView = UIImageView()
    addSubview(messageImageView)
    messageImageView.backgroundColor = UIColor.clear
    
    loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    loadingView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
    addSubview(loadingView)
    
  }
  
  private func layoutMessageImageView(_ imageMessageData: ImageMessage) {
    
    messageImageView.frame = bounds
    loadingView.po_frameBuilder().centerInSuperview()

  }
  
  private func configImageView(_ imageMessageData: ImageMessage) {
    
    imageLoaded = false
    
    let imageKey = WebImageTools.getImageURLForIM(with: imageMessageData.imageURL)
    let isImageCached = WebImageTools.fetchLocalImageData(with: imageKey) != nil
    
    setupIndicatorView(with: !isImageCached)
//    loadNetworkImage(withImageURL: imageKey)
    
    if isImageCached {
      messageImageView.image = UIImage(data: WebImageTools.fetchLocalImageData(with: imageKey)!)
    }
  }
  
  private func loadNetworkImage(withImageURL imageURL: String) {
    
//    messageImageView.wz_setGIFImage(with: imageURL, placeholderImage: UIImage(named: "default_pic")) { (success, isFromCache) in
//
//      guard success else { return }
//
//      self.imageLoaded = true
//
//      guard !isFromCache else { return }
//
//      guard let messageCell = self.messageCell, let messageViewController = self.messageViewController else { return }
//
//      let isLastCell = messageViewController.messageTableView.numberOfCells - 1 == self.row
//
//      if isLastCell {
//
//        messageCell.reload(scrollToBottom: true)
//
//      } else {
//
//        messageViewController.messageTableView.reloadData()
//
//      }
//    }
  }
  
  private func setupIndicatorView(with isShowLoading: Bool) {
    
    if isShowLoading {
      
      loadingView.startAnimating()
      
    } else {
      
      loadingView.stopAnimating()
      
    }
  }
}
