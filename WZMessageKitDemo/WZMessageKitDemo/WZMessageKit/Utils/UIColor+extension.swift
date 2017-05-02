//
//  MuColor.swift
//  MuMu
//
//  Created by 范祎楠 on 15/4/9.
//  Copyright (c) 2015年 范祎楠. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
  
  class var subText: UIColor { return UIColor(hex: 0xaaaaaa) }
  class var separator: UIColor { return UIColor(hex: 0xe5e5e5) }
  class var mainBackground: UIColor { return UIColor(hex: 0xeeeeee) }
  class var mainText: UIColor { return UIColor(hex: 0x333333) }
  class var disableBackground: UIColor { return UIColor(hex: 0xdddddd) }
  class var recordAudioButton: UIColor { return UIColor(hex: 0xffffff) }
  class var recordAudioButtonDown: UIColor { return UIColor(hex: 0xcccccc) }

  convenience init(hex: Int, alpha: CGFloat = 1) {
    
    let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat((hex & 0x0000FF)) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  class var random: UIColor {
    let hue = CGFloat(arc4random() % 256) / 256.0
    let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256.0 + 0.5
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
  }

}
