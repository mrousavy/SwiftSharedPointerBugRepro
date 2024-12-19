//
//  CppPart.hpp
//  SwiftSharedPointerTest
//
//  Created by Marc Rousavy on 19.12.24.
//

#pragma once

#include <string>
#include <memory>

using SharedPtrOfString = std::shared_ptr<std::string>;

inline void dummy(void* _Nonnull state, void(* _Nonnull call)(void* _Nonnull, SharedPtrOfString)) {
  auto shared = std::make_shared<std::string>("HELLO!");
  call(state, shared);
}
