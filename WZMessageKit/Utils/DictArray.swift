//
//  DictArray.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/1/23.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

import UIKit

class DictArray<T: Hashable, U: Any>: Sequence {

  private var data: [T: [U]] = [:]
  
  func append(_ item: U, to key: T) {
    
    var array = data[key] ?? []
    array += [item]

    data[key] = array
  }
  
  func removeFirst(with key: T) -> U? {
    
    guard var array = data[key] else { return nil }
    
    let item = array.removeFirst()
    
    data[key] = array
    
    if array.isEmpty {
      data[key] = nil
    }
    
    return item
  }
  
  subscript(key: T) -> [U] {
    return data[key] ?? []
  }
  
  func makeIterator() -> DictArrayIterator<T, U> {
    return DictArrayIterator<T, U>(data: data)
  }
}

class DictArrayIterator<T: Hashable, U: Any>: IteratorProtocol {
  
  private var data: [T: [U]]
  private var iterator: DictionaryIterator<T, [U]>
  
  init(data: [T: [U]]) {
    self.data = data
    self.iterator = data.makeIterator()
  }
  
  func next() -> (T, [U])? {
  
    return iterator.next()
    
  }
}
