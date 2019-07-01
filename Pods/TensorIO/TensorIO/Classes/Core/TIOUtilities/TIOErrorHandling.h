//
//  TIOErrorHandling.h
//  TensorIO
//
//  Created by Phil Dow on 6/3/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#ifndef TIOErrorHandling_h
#define TIOErrorHandling_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Logs an error message to the console and creates an `NSError` at `ptr` with
 * a domain `d`, code `c`, and message `m`.
 */

#define TIO_LOGSET_ERROR(m, d, c, ptr) { \
        NSLog(@"%@",m); \
        ptr = [[NSError alloc] initWithDomain:d code:c userInfo:@{ \
            NSLocalizedDescriptionKey: m \
        }]; \
    }

NS_ASSUME_NONNULL_END

#endif /* TIOErrorHandling_h */
