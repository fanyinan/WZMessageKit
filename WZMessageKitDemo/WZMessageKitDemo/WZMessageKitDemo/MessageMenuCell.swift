//
//  MessageMenuCell.swift
//  JXiOS
//
//  Created by 范祎楠 on 2017/3/27.
//  Copyright © 2017年 JuXin. All rights reserved.
//

import UIKit

class MessageMenuCell: UICollectionViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var iconContainerView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
   
    iconContainerView.wz_setViewCornerRadius(5)
    iconContainerView.wz_setBorder(0.5, color: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
  }
  
  func setData(messageMenuItem: MessageMenuItem) {
    
    titleLabel.text = messageMenuItem.title
    subtitleLabel.text = messageMenuItem.subtitle
    iconImageView.image = UIImage(named: messageMenuItem.imageName)
    isUserInteractionEnabled = messageMenuItem.enable
  }
}
