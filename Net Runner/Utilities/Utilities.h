//
//  Utilities.h
//  Net Runner
//
//  Created by Philip Dow on 7/3/18.
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

#ifndef Utilities_h
#define Utilities_h

#define safe_block(block, ...) if (block) { block(__VA_ARGS__); }

typedef void(^measurable)(void);

void measuring_latency(double* latency, measurable block);

#endif /* Utilities_h */
