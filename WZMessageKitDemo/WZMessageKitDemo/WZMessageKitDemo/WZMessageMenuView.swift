//
//  WZMessageMenuView.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/3/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

struct MessageMenuItem {
  
  var imageName = ""
  var title = ""
  var subtitle = ""
  var enable = true
}

protocol WZMessageMenuViewDelegate: NSObjectProtocol {
  
  func menuView(_ menuView: WZMessageMenuView, didSelectItemAtIndex menuItemIndex: Int)
  
}

class WZMessageMenuView: UIView {
  
  fileprivate weak var delegate: WZMessageMenuViewDelegate?
  private var collectionView: UICollectionView!
  var menuDataList: [MessageMenuItem] = []
  
  var canAudio = false
  var canVideo = false
  
  var numberOfCol: CGFloat = 4
  var numberOfRow = 1
  var hMargin: CGFloat = 30
  var vMargin: CGFloat = 20
  let itemWidth: CGFloat = 60
  
  init(delegate: WZMessageMenuViewDelegate, frame: CGRect) {
    
    self.delegate = delegate
    
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func reload() {
    collectionView.reloadData()
  }
  
  func setupUI() {
    
    backgroundColor = .white
    
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: frame.height - vMargin * 2)
    collectionViewFlowLayout.minimumInteritemSpacing = (frame.width - hMargin * 2 - itemWidth * CGFloat(numberOfCol)) / (CGFloat(numberOfCol) - 1)
    
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
    addSubview(collectionView)
    collectionView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: vMargin, left: hMargin, bottom: vMargin, right: hMargin))
    }
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .white
    collectionView.register(UINib(nibName: "MessageMenuCell", bundle: nil ), forCellWithReuseIdentifier: "MessageMenuCell")
  }
  
  func menuItemClick(_ sender: UIControl) {
    delegate?.menuView(self, didSelectItemAtIndex: sender.tag)
  }
}

extension WZMessageMenuView: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return menuDataList.count
  }
    
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageMenuCell", for: indexPath) as! MessageMenuCell
    
    cell.setData(messageMenuItem: menuDataList[indexPath.row])
    
    cell.iconImageView.alpha = 1
    
    if indexPath.row == 1 {
      cell.iconImageView.alpha = canVideo ? 1 : 0.2
    }
    
    if indexPath.row == 2 {
      cell.iconImageView.alpha = canAudio ? 1 : 0.2
    }
    
    return cell
  }
}

extension WZMessageMenuView: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.menuView(self, didSelectItemAtIndex: indexPath.row)
  }
}
