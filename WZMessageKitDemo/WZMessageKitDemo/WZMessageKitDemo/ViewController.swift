//
//  ViewController.swift
//  WZMessageKitDemo
//
//  Created by 范祎楠 on 2017/5/2.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func click() {
    
    navigationController?.pushViewController(MessageViewController(), animated: true)
  }
}

