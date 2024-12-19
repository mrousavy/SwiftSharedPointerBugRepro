//
//  SwiftPart.swift
//  SwiftSharedPointerTest
//
//  Created by Marc Rousavy on 19.12.24.
//

func runBugCode() {
  func __call(value: SharedPtrOfString) {
    let string = String(value.pointee)
    print("Got value from C++: \(value)")
  }
  dummy(__call)
}
