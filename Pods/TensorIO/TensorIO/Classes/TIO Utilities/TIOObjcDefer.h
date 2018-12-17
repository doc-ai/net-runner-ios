//
//  TIOObjcDefer.h
//  TensorIO
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#ifndef TIOObjcDefer_h
#define TIOObjcDefer_h

// Use tio_defer_block like defer is used in Swift

#define tio_defer_block_name_with_prefix(prefix, suffix) prefix ## suffix
#define tio_defer_block_name(suffix) tio_defer_block_name_with_prefix(defer_, suffix)
#define tio_defer_block __strong void(^tio_defer_block_name(__LINE__))(void) __attribute__((cleanup(tio_defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
/**
 * A magical utility function that performs like a a `defer` in Swift.
 *
 * Do not use this function directly. Instead use `tio_defer_block()`.
 * Code that is wrapped a call to `tio_defer_block` will automatically be called
 * when the enclosing scope exits.
 */
static void tio_defer_cleanup_block(__strong void(^*block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop

#endif /* TIOObjcDefer_h */
