//
//  WZMessageBottomPopViewController.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/3.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

protocol WZMessageBottomViewPoppingControllerDelegate: NSObjectProtocol {
  func poppingBottomViewWillChange(_ viewFrame: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions, isShow: Bool)
}

public class WZMessageBottomViewPoppingController: NSObject {
  
  public var poppingView: UIView?
  private var superView: UIView
  private var popViews: [UIView] = []
  
  weak var delegate: WZMessageBottomViewPoppingControllerDelegate?
  
  let popAnimationDuration: TimeInterval = 0.25
  
  //键盘的弹出动画样式
  let popAnimationOptions: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: 458752).union(.allowUserInteraction)
  
  init(withSuperView superView: UIView) {
    self.superView = superView
    super.init()
  }
  
  /******************************************************************************
   *  public method
   ******************************************************************************/
  //MARK: - public method
  
  func addPoppingView(_ view: UIView) {
    
    superView.addSubview(view)
    
    initPoppingViewPosition(view)
    
    popViews.append(view)
  }
  
  func popView(_ view: UIView) {
    
    guard popViews.contains(view) else {
      print("you are using a wrong key to pop view")
      return
    }
    
    initPoppingViewPosition(view)
    
    superView.bringSubview(toFront: view)
    poppingView = view
    animateBottomView(poppingView: view, isShow: true)
  }
  
  //isNotice : 是否通知delegate弹出框位置发生变化
  func hidePoppingView(isNoticeDelegate: Bool = true) {
    
    guard let poppingView = poppingView else { return }
    
    self.poppingView = nil
    animateBottomView(poppingView: poppingView, isShow: false, isNoticeDelegate: isNoticeDelegate)
    
  }
  
  func toggleView(_ view: UIView) {
    
    guard let poppingView = poppingView else {
      
      popView(view)
      return
    }
    
    hidePoppingView()
    
    if view != poppingView {
      
      popView(view)
    }
  }
  
  /******************************************************************************
   *  private  method
   ******************************************************************************/
  //MARK: - private method
  
  private func initPoppingViewPosition(_ view: UIView) {
    
    //只改变view的Y坐标，把view放在下方
    var viewFrame = view.frame
    viewFrame.origin.y = superView.frame.height
    view.frame = viewFrame
    
  }
  
  private func animateBottomView(poppingView: UIView, isShow: Bool, isNoticeDelegate: Bool = true) {
    
    var poppingFrame = poppingView.frame
    poppingFrame.origin.y = isShow ? superView.frame.height - poppingFrame.height : superView.frame.height
    
    if isNoticeDelegate {
      delegate?.poppingBottomViewWillChange(poppingFrame, animationDuration: popAnimationDuration, animationOptions: popAnimationOptions, isShow: isShow)
    }
    
    UIView.animate(withDuration: popAnimationDuration, delay: 0, options: popAnimationOptions, animations: { () -> Void in
      
      poppingView.frame = poppingFrame
      
      }, completion: nil)
    
  }
}
