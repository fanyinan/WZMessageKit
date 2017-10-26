//
//  Utility.swift
//  WZMessageKitDemo
//
//  Created by 范祎楠 on 16/7/4.
//  Copyright © 2016年 fyn. All rights reserved.
//

import Foundation

func swiftClassFromString(_ className: String) -> AnyClass? {
  // get the project name NSClassFromString 在Swift中已经 no effect
  if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
    // generate the full name of your class (take a look into your "SHCC-swift.h" file)
    let classStringName = "_TtC\(appName.utf16.count)\(appName)\(className.characters.count)\(className)"
    let  cls: AnyClass?  = NSClassFromString(classStringName)
    //     cls = NSClassFromString("\(appName).\(className)")
    return cls
    
  }
  return nil
}

