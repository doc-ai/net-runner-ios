//
//  ObjcDefer.h
//  Net Runner
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef ObjcDefer_h
#define ObjcDefer_h

// Use defer_block like defer is used in Swift

#define defer_block_name_with_prefix(prefix, suffix) prefix ## suffix
#define defer_block_name(suffix) defer_block_name_with_prefix(defer_, suffix)
#define defer_block __strong void(^defer_block_name(__LINE__))(void) __attribute__((cleanup(defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void defer_cleanup_block(__strong void(^*block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop


#endif /* ObjcDefer_h */
