# Tensor/IO

[![Build Status](https://travis-ci.org/doc-ai/TensorIO.svg?branch=master)](https://travis-ci.org/doc-ai/TensorIO)
[![Version](https://img.shields.io/cocoapods/v/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![License](https://img.shields.io/cocoapods/l/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![Platform](https://img.shields.io/cocoapods/p/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)

## Introduction

Tensor/IO iOS is an Objective-C wrapper for machine learning with support for TensorFlow and TensorFlow Lite. It abstracts the work of copying bytes into and out of tensors and allows you to interract with native types instead, such as numbers, arrays, dictionaries, and pixel buffers. Tensor/IO for iOS supports packaging and deployment, inference, and training. This implementation is part of the [Tensor/IO project](https://doc-ai.github.io/tensorio/) with support for machine learning on iOS, Android, and React Native.

For more complete documentation, see the [Tensor/IO Documentation](https://github.com/doc-ai/tensorio/tree/master/documentation).

## Example

With Tensor/IO you can perform inference in just a few lines of code:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];

TIOTFLiteModel *model = [TIOTFLiteModel modelWithBundleAtPath:path];

NSDictionary *inference = (NSDictionary *)[model runOn:buffer];
NSDictionary *classification = [inference[@"classification"] topN:5 threshold:0.1];
```

And in Swift:

```swift
let image = UIImage(named: "example-image")!
let pixels = image.pixelBuffer()!
let value = pixels.takeUnretainedValue() as CVPixelBuffer
let buffer = TIOPixelBuffer(pixelBuffer:value, orientation: .up)

let model = TIOTFLiteModel.withBundleAtPath(path)!

let inference = model.run(on: buffer)
let classification = ((inference as! NSDictionary)["classification"] as! NSDictionary).topN(5, threshold: 0.1)
```

## Example Projects

To run the example project, clone the repo, and run `pod install` from the Example directory first. 

- See *MainViewController.mm* for sample code. 
- See *TensorIOTFLiteModelIntegrationTests.mm* for more complex models. 
- iPython notebooks for the test models may be found in the *notebooks* directory in this repo.

We include four example projects showing how to use Tensor/IO with the TF Lite and TensorFlow backends in both Objective-C and Swift.

## Requirements

Tensor/IO requires iOS 12.0+

## Adding Tensor/IO to Your Project

Tensor/IO is available through [CocoaPods](https://cocoapods.org). Add the following to your Podfile:

```ruby
pod 'TensorIO/TFLite'
```

And run `pod install`.

If you would prefer to use the TensorFlow backend add the following instead:

```ruby
pod 'TensorIO/TensorFlow'
```

#### Objective-C

Because the umbrella Tensor/IO header imports headers with C++ syntax, any files that use Tensor/IO must have Obj-C++ extensions. Rename your `.m` files to `.mm`.

Then wherever you'd like to use Tensor/IO, simply import it:

```objc
@import TensorIO;
```

#### Swift

Make sure `use_frameworks!` is uncommented in your Podfile, and wherever you'd like to use Tensor/IO, simply import it:

```swift
import TensorIO
```

For more informaiton on using Tensor/IO, refer to the [complete documentation](https://github.com/doc-ai/tensorio/tree/master/documentation) or see the four example projects included in this repo.

We also maintain a repository of example jupyter notebooks demonstrating how to build models for on device inference and training with Tensor/IO and include sample iOS code in Swift for running those models. See [tensorio/examples](https://github.com/doc-ai/tensorio/tree/master/examples) for more information.

## License

Tensor/IO is available under the Apache 2 license. See the [LICENSE](LICENSE) for more info.