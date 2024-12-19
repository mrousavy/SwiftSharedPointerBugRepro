//
//  SwiftPart.swift
//  SwiftSharedPointerTest
//
//  Created by Marc Rousavy on 19.12.24.
//

func runBugCode() {
  class ClosureWrapper {
    private let closure: (String) -> Void
    
    init(closure: @escaping (String) -> Void) {
      self.closure = closure
    }
    
    func call(value: String) {
      closure(value)
    }
  }
  
  let closureWrapper = ClosureWrapper { value in
    print("Got value from C++: \(value)")
  }
  let state = Unmanaged.passRetained(closureWrapper).toOpaque()
  func __call(state: UnsafeMutableRawPointer, value: SharedPtrOfString) {
    let __closure = Unmanaged<ClosureWrapper>.fromOpaque(state).takeRetainedValue()
    let string = String(value.pointee)
    __closure.call(value: string)
  }
  dummy(state, __call)
}
