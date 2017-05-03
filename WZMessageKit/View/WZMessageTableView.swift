//
//  WZTableView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/1/30.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

public class WZMessageTableView: UITableView {
  
  private(set) var loadingView: MessageLoadingView!
  private let loadingViewHeight: CGFloat = 50
  private(set) var recentChangeContentInsets = UIEdgeInsets.zero
  
  var isLoading = false
  
  public init(frame: CGRect) {
    super.init(frame: frame, style: .plain)
    
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    separatorStyle = .none
    addLoadView()
  }

  private func addLoadView() {
    
    let nib = UINib(nibName: "MessageLoadingView", bundle: Bundle(for: MessageLoadingView.self))
    loadingView = nib.instantiate(withOwner: nil, options: nil).first as! MessageLoadingView
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
  
  public func changeTableViewInsets(topIncrement: CGFloat? = nil, bottomIncrement: CGFloat? = nil, adjustIndicator: Bool = true) {
    
    recentChangeContentInsets = UIEdgeInsets(top: topIncrement ?? 0, left: 0, bottom: bottomIncrement ?? 0, right: 0)
    
    contentInset.top = contentInset.top + recentChangeContentInsets.top
    contentInset.bottom = contentInset.bottom + recentChangeContentInsets.bottom
    
    if adjustIndicator {
      
      scrollIndicatorInsets.top = scrollIndicatorInsets.top + recentChangeContentInsets.top
      scrollIndicatorInsets.bottom = scrollIndicatorInsets.bottom + recentChangeContentInsets.bottom
      
    }
  }
  
  public func setTableViewInsets(top: CGFloat? = nil, bottom: CGFloat? = nil, adjustIndicator: Bool = true) {
    
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

