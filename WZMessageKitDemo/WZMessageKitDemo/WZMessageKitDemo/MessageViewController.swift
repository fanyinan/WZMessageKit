//
//  MessageViewController.swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/9/26.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class MessageViewController: WZMessageViewController {
  
  var messageDataList: [WZMessageData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    delegate = self
    
    for _ in 0..<40 {
      messageDataList.append(TextMessage(text: "aaa"))
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "test", style: .plain, target: self, action: #selector(MessageViewController.test))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc private func test() {
    
  }
}

extension MessageViewController: WZMessageViewControllerDataSource, WZMessageViewControllerDelegate {
  
  func numberOfMessageInMessageViewController(_ messageViewController: WZMessageViewController) -> Int {
    return messageDataList.count
  }
  
  func messageViewController(_ messageViewController: WZMessageViewController, messageDataForCellAtRow row: Int) -> WZMessageData {
    return messageDataList[row]
  }
  
}
