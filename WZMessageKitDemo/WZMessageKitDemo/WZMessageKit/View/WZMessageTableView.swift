//
//  WZTableView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZMessageTableView: UITableView {
  
  private(set) var loadingView: MessageLoadingView!
  private let loadingViewHeight: CGFloat = 50
  private(set) var recentChangeContentInsets = UIEdgeInsets.zero
  
  var isLoading = false
  
  init(frame: CGRect) {
    super.init(frame: frame, style: .plain)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    separatorStyle = .none
    addLoadView()
  }

  func addLoadView() {
    
    loadingView = Bundle.main.loadNibNamed("MessageLoadingView", owner: self, options: nil)?.last as! MessageLoadingView
    loadingView.frame = CGRect(x: 0, y: -loadingViewHeight, width: frame.width, height: loadingViewHeight)
    loadingView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
    loadingView.backgroundColor = backgroundColor
    loadingView.isHidden = true
    
    addSubview(loadingView)
    
  }
  
  func showLoadingView() {
    
    guard !isLoading else { return }
    
    loadingView.isHidden = false
    changeTableViewInsets(topIncrement: loadingViewHeight, adjustIndicator: false)
    isLoading = true
  }
  
  func hideLoadingView() {
    
    guard isLoading else { return }
    
    loadingView.isHidden = true
    changeTableViewInsets(topIncrement: -loadingViewHeight, adjustIndicator: false)
    isLoading = false
  }
  
  func changeTableViewInsets(topIncrement: CGFloat? = nil, bottomIncrement: CGFloat? = nil, adjustIndicator: Bool = true) {
    
    recentChangeContentInsets = UIEdgeInsets(top: topIncrement ?? 0, left: 0, bottom: bottomIncrement ?? 0, right: 0)
    
    contentInset.top = contentInset.top + recentChangeContentInsets.top
    contentInset.bottom = contentInset.bottom + recentChangeContentInsets.bottom
    
    if adjustIndicator {
      
      scrollIndicatorInsets.top = scrollIndicatorInsets.top + recentChangeContentInsets.top
      scrollIndicatorInsets.bottom = scrollIndicatorInsets.bottom + recentChangeContentInsets.bottom
      
    }
  }
  
  func setTableViewInsets(top: CGFloat? = nil, bottom: CGFloat? = nil, adjustIndicator: Bool = true) {
    
    if let top = top {
      
      contentInset.top = top
      
      if adjustIndicator {
        scrollIndicatorInsets.top = top
      }
      
    }
    
    if let bottom = bottom {
      
      contentInset.bottom = bottom
      
      if adjustIndicator {
        scrollIndicatorInsets.bottom = bottom
      }
    }
  }
}

