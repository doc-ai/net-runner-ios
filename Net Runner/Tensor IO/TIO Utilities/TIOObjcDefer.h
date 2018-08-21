//
//  TIOObjcDefer.h
//  TensorIO
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef TIOObjcDefer_h
#define TIOObjcDefer_h

// Use tio_defer_block like defer is used in Swift

#define tio_defer_block_name_with_prefix(prefix, suffix) prefix ## suffix
#define tio_defer_block_name(suffix) tio_defer_block_name_with_prefix(defer_, suffix)
#define tio_defer_block __strong void(^tio_defer_block_name(__LINE__))(void) __attribute__((cleanup(tio_defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void tio_defer_cleanup_block(__strong void(^*block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop

#endif /* TIOObjcDefer_h */
