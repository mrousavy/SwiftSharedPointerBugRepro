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
inline void dummy(void(* _Nonnull callback)(SharedPtrOfString)) {
  auto shared = std::make_shared<std::string>("HELLO!");
  callback(shared);
}
```

2. Create a C-style Swift function that will be passed to C++ as a callback:

```swift
func callCppFunc() {
  // This is a static C-style Swift function (@convention(c))
  func __callback(value: SharedPtrOfString) {
    let string = String(value.pointee)
    print("Got from C++: \(string)")
  }
  // Call the C++ function
  dummy(__callback)
}
```

3. It crashes.
