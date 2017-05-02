//
//  LoadingView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/4/6.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class MessageLoadingView: UIView {

  @IBOutlet weak var indicatorView: UIActivityIndicatorView!
  
  override func awakeFromNib() {
    indicatorView.startAnimating()
  }
}
