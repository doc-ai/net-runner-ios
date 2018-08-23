# TensorIO

[![CI Status](https://img.shields.io/travis/phil@phildow.net/TensorIO.svg?style=flat)](https://travis-ci.org/phil@phildow.net/TensorIO)
[![Version](https://img.shields.io/cocoapods/v/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![License](https://img.shields.io/cocoapods/l/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![Platform](https://img.shields.io/cocoapods/p/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)

TensorIO is an Objective-C wrapper for TensorFlow Lite. It abstracts the work of copying bytes into and out of tensors and allows you to interract with native types instead, such as numbers, arrays, dictionaries, and pixel buffers.

With TensorIO you can perform inference in just a few lines of code:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];

id<TIOModel> model = [TIOTFLiteModel modelWithBundleAtPath:path];    
NSDictionary *classification = [((NSDictionary*)[model runOn:buffer])[@"classification"] topN:5 threshold:0.1];
```

## Overview

TensorIO aims to support multiple kinds of models with multiple input and output layers of different shapes and kinds but with minimal boilerplate code. In fact, you can run a variety of models without needing to write any model specific code at all.

Instead, TensorIO relies on a json description of the model that you provide. During inference, the library matches incoming data to the model layers that expect it, performing any transformations that are needed and ensuring that the underlying bytes are copied to the right place. 

Once inference is complete, the library copies bytes from the output tensors to native Objectice-C types, again relying on the json description of the model to perform any transformations and copy bytes to the right place.

The built-in class for working with tensorflow lite models, `TIOTFLiteModel`, includes support for multiple input and output layers; single-valued, vectored, matrix, and image data; pixel normalization and denormalization; and quantization and dequantization of data.

In case you require a completely custom interface to a model you may specify your own class in the json description, and TensorIO will use it in place of the default class.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. 

See *MainViewController.mm* for sample code. See *TensorIOTFLiteModelIntegrationTests.mm* for examples on how to run inference on models with multiple kinds of inputs and outputs. iPython notebooks for the test models may be found in the *notebooks* directory in this repo.

 For more detailed information about using TensorIO, refer to the **Usage** section below.

## Requirements

TensorIO works on iOS 9.3 or higher.

## Installation

TensorIO is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TensorIO'
```

## Author

philip@doc.ai (http://doc.ai)

## License

TensorIO is available under the Apache 2 license. See the LICENSE file for more info.

## Usage

Because the umbrella TensorIO header imports headers with C++ syntax, any files that use TensorIO must have Obj-C++ extensions. Rename any `.m` file to `.mm`.

Then wherever you'd like to use TensorIO, add:

```objc
#import <TensorIO/TensorIO.h>
```

To use TensorIO as a module, make sure `use_frameworks!` is uncommented in your Podfile, then wherever you'd lke to use TensorIO, add:

```objc
@import TensorIO;
```

