## Reproduction for a Swift <> C++ `shared_ptr` bug

This is a reproduction for a Swift compiler bug where passing a `std::shared_ptr` from C++ to Swift will cause a crash:

```diff
- SwiftSharedPointerTest(33577,0x1e6e6f840) malloc: Heap corruption detected, free list is damaged at 0x600002b91a10
- *** Incorrect guard value: 1
- SwiftSharedPointerTest(33577,0x1e6e6f840) malloc: *** set a breakpoint in malloc_error_break to debug
```

The setup is fairly simple;

1. Create a C++ function that receives a "callback":

```cpp
#pragma once

#include <string>
#include <memory>

// A Type alias so we can use shared_ptr<string> in Swift
using SharedPtrOfString = std::shared_ptr<std::string>;

// Call `dummy` with a C-style Swift function (the "callback")
inline void dummy(void* _Nonnull state, void(* _Nonnull callback)(void* _Nonnull, SharedPtrOfString)) {
  auto shared = std::make_shared<std::string>("HELLO!");
  callback(state, shared);
}
```

2. Create a Swift function that wraps the Callback in a `void*` so we can safely pass it to C++:

```swift
func callCppFunc() {
  // Swift Closures are wrapped in a Swift class,
  // so we can convert it to Unmanaged / void*
  class ClosureWrapper {
    private let closure: (String) -> Void
    init(closure: @escaping (String) -> Void) {
      self.closure = closure
    }
    func call(value: String) {
      closure(value)
    }
  }

  let __closureWrapper = ClosureWrapper { value in
    print("Got value from C++: \(value)")
  }

  // This holds the closure as a void*
  let __state = Unmanaged.passRetained(__closureWrapper).toOpaque()
  // This calls the actual closure as a static C-style function
  // by unwrapping `state` (the ClosureWrapper) from the void*.
  func __callback(state: UnsafeMutableRawPointer, value: SharedPtrOfString) {
    let __closure = Unmanaged<ClosureWrapper>.fromOpaque(state).takeRetainedValue()
    let string = String(value.pointee)
    __closure.call(value: string)
  }
  // Call the C++ function
  dummy(__state, __callback)
}
```

3. It crashes.
