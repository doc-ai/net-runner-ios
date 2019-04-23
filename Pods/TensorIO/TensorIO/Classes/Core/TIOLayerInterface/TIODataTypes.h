//
//  TIODataTypes.h
//  TensorIO
//
//  Created by Phil Dow on 4/18/19.
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

#ifndef TIODataTypes_h
#define TIODataTypes_h

/**
 * The data types used by at least one of the supported backends
 */

typedef enum : NSUInteger {
    TIODataTypeUnknown,
    TIODataTypeUInt8,       // "uint8"
    TIODataTypeFloat32,     // "float32"
    TIODataTypeInt32,       // "int32"
    TIODataTypeInt64        // "int64"
} TIODataType;

#endif /* TIODataTypes_h */
