# TensorIO

[![Build Status](https://travis-ci.org/doc-ai/TensorIO.svg?branch=master)](https://travis-ci.org/doc-ai/TensorIO)
[![Version](https://img.shields.io/cocoapods/v/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![License](https://img.shields.io/cocoapods/l/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)
[![Platform](https://img.shields.io/cocoapods/p/TensorIO.svg?style=flat)](https://cocoapods.org/pods/TensorIO)

TensorIO is an Objective-C wrapper for TensorFlow Lite. It abstracts the work of copying bytes into and out of tensors and allows you to interract with native types instead, such as numbers, arrays, dictionaries, and pixel buffers.

With TensorIO you can perform inference in just a few lines of code:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];

TIOTFLiteModel *model = [TIOTFLiteModel modelWithBundleAtPath:path];

NSDictionary *inference = (NSDictionary*)[model runOn:buffer];
NSDictionary *classification = [inference[@"classification"] topN:5 threshold:0.1];
```

See the <a href="#usage">Usage</a> section below for important notes on adding TensorIO to your project.

## Table of Contents

* [ Overview ](#overview)
* [ Example ](#example)
* [ Requirements ](#requirements)
* [ Installation ](#installation)
* [ Author ](#author)
* [ License ](#license)
* [ Usage ](#usage)
	* [ Add TensorIO to Your Project ](#importing)
	* [ Basic Usage ](#basic-usage)
	* [ Model Bundles ](#model-bundles)
	* [ The Model JSON File ](#model-json)
		* [ Basic Structure ](#basic-structure)
		* [ The Model Field ](#model-field)
		* [ The Inputs Field ](#inputs-field)
		* [ The Outputs Field ](#outputs-field)
		* [ A Complete Example ](#complete-example)
	* [ Quantization and Dequantization ](#quantization)
		* [ A Basic Example ](#quantization-basic-example)
		* [ The Quantize Field ](#quantize-field)
		* [ The Dequantize Field ](#dequantize-field)
		* [ Selecting the Scale and Bias Terms ](#selecting-scale-bias)
		* [ A Complete Example ](#quantization-complete-example)
		* [ Quantized Models without Quantization ](#quantization-without-quantization)
	* [ Working with Image Data ](#images)
		* [A Basic Example](#images-basic-example)
		* [ Pixel Buffers ](#pixel-buffer)
		* [ The Format Field ](#pixel-format)
		* [ Pixel Normalization ](#pixel-normalization)
		* [ Pixel Denormalization ](#pixel-normalization)
		* [ A Complete Example ](#pixel-buffer-complete-example)
* [ Advanced Usage ](#advanced-usage)
* [ Net Runner ](#netrunner)
* [ FAQ ](#faq)

<a name="overview"></a>
## Overview

TensorIO supports many kinds of models with multiple input and output layers of different shapes and kinds but with minimal boilerplate code. In fact, you can run a variety of models without needing to write any model specific code at all.

Instead, TensorIO relies on a json description of the model that you provide. During inference, the library matches incoming data to the model layers that expect it, performing any transformations that are needed and ensuring that the underlying bytes are copied to the right place.  Once inference is complete, the library copies bytes from the output tensors back to native Objective-C types.

The built-in class for working with TensorFlow Lite (TF Lite) models, `TIOTFLiteModel`, includes support for multiple input and output layers; single-valued, vectored, matrix, and image data; pixel normalization and denormalization; and quantization and dequantization of data.

In case you require a completely custom interface to a model you may specify your own class in the json description, and TensorIO will use it in place of the default class.

<a name="example"></a>
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. 

- See *MainViewController.mm* for sample code. 
- See *TensorIOTFLiteModelIntegrationTests.mm* for more complex models. 
- iPython notebooks for the test models may be found in the *notebooks* directory in this repo.

For more detailed information about using TensorIO, refer to the <a href="#usage">Usage</a> section below.

<a name="requirements"></a>
## Requirements

TensorIO requires iOS 9.3+

<a name="installation"></a>
## Installation

TensorIO is available through [CocoaPods](https://cocoapods.org). Add the following to your Podfile:

```ruby
pod 'TensorIO'
```

And run `pod install`.

<a name="author"></a>
## Author

Philip Dow (philip@doc.ai)

<a name="license"></a>
## License

TensorIO is available under the Apache 2 license. See the LICENSE file for more info.

<a name="usage"></a>
## Usage

<a name="importing"></a>
### Adding TensorIO to Your Project

Because the umbrella TensorIO header imports headers with C++ syntax, any files that use TensorIO must have Obj-C++ extensions. Rename your `.m` files to `.mm`.

Wherever you'd like to use TensorIO, add:

```objc
#import <TensorIO/TensorIO.h>
```

To use TensorIO as a module, make sure `use_frameworks!` is uncommented in your Podfile, and add the following *Other C Flags* to your project's build settings:

```
-fmodules
-fcxx-modules
```

Wherever you'd like to use TensorIO, add:

```objc
@import TensorIO;
```

Because of how Objective-C++ and Objective-C headers interract, you may only import TensorIO into implementation files. If you reference TensorIO types in your header files, forward declare them with `@class` and `@protocol` directives:

**MyClass.h**

```objc
@import Foundation;

@class TIOTFLiteModel;

@interface MyClass: NSObject
@property TIOTFLiteModel *model;
@end
```

**MyClass.m**

```objc
#import "MyClass.h"

@import TensorIO;

@implementation MyClass
// Do something with the model
@end

```

<a name="basic-usage"></a>
### Basic Usage

A TensorIO model takes a set of inputs, performs inference, and returns a set of outputs.

Consider a model that predicts the price of a house given a feacture vector that includes square footage, number of bedrooms, number of bathrooms, proximity to a school, and so forth.

With TensorIO you construct an `NSArray` of numeric values for these features, pass the array to your model, and extract the price from the results.

```objc
TIOTFLiteModel *model = ...
NSArray *input = @[ @(1890), @(3), @(2), @(1.6) ];
NSDictionary *output = (NSDictionary*)[model runOn:input];
NSNumber *price = output[@"price"];
```

**TIOData**

TensorIO models take inputs and produce outputs of type `TIOData`. This is a protocol that defines two required methods. One method copies bytes from the conforming class to an input tensor's buffer, and the other instantiates an object from the bytes in an output tensor's buffer.

The TensorIO library includes implementations of this protocol for the following classes:

- NSNumber
- NSData
- NSArray
- NSDictionary
- CVPixelBufferRef with TIOPixelBuffer


In the above example, we're passing a single `NSArray` to the model. The model extracts numeric byte values from the array, copying them into the underlying TF Lite model. It asks the underlying model to perform inference, and then copies the resulting bytes back into an `NSNumber`. That `NSNumber` is added to a dictionary under the `@"price"` key, and it is this dictionary which the model returns.

**Model Outputs**

Why is the resulting price not returned directly, and how do we know that the value is keyed to `@"price"` in the returned dictionary?

Because models may have multiple inputs and outputs, TensorIO tries to make no assumptions about how many input and output layers a model actually has. This gives it some flexiblity in what kinds of inputs it can take, for example a single numeric value, arrays of numeric arrays, or a dictionary, and it intelligently matches those inputs to the underlying tensor buffers, but a model consequently always returns a dictionary of outputs. 

(*Note: this may change in a future implementation, and single outputs may be returned directly*)

To understand why the output value is keyed to a specific entry, we must understand how TensorIO is able to match Objective-C inputs and outputs to the underlying model's input and output layers, and for that we require an understanding of model bundles and the JSON file which describes the underlying model.


<a name="model-bundles"></a>
### Model Bundles

TensorIO currently includes support for TensorFlow Lite (TF Lite) models. Although the library is built with support for other machine learning frameworks in mind, we'll focus on TF Lite models here.

A TF Lite model is contained in a single *.tflite* file. All the operations and weights required to perform inference with a model are included in this file.

However, a model may have other assets that are required to interpret the resulting inference. For example, an MNIST image classification model will output 1000 values corresponding to the softmax probability that a particular object has been recognized in an image. The model doesn't match probabilities to their labels, for example "rocking chair" or "lakeside", it only outputs numeric values. It is left to us to associate the numeric values with their labels.

Rather than requiring a developer to do this in application space and consequently store the lables in a text file or in some code somewhere in the application, TensorIO wraps models in a bundle and allows model builders to include additional assets in that bundle.

A TensorIO bundle is just a folder with an extension that identifies it as such. For TF Lite models, the extension is *.tfbundle*. Assets may be included in this bundle and then referenced from model specific code. 

*When you use your own models with TensorIO, make sure to put them in a folder with the .tfbundle extension.*

A TensorIO TF Lite bundle has the following directory structure:

```
mymodel.tfbundle
  - model.tflite
  - model.json
  - assets
    - file.txt
    - ...
```

The *model.json* file is required. It describes the interface to your model and includes other metadata about it. More on that below.

The *model.tflite* file is required but may have another name. The bundle must include some *.tflite* file, but its actual name is specified in *model.json*.

The *assets* directory is optional and contains any additional assets required by your specific use case. Those assets may be referenced from *model.json*.

Because image classification is such a common task, TensorIO includes built-in support for it, and no additional code is required. You'll simply need to specify a labels file in the model's json description, which we'll look at in a moment.

**Using Model Bundles**

TensorIO encapsulate information about a model in `TIOModelBundle` . This class parses the metadata for a model from the *model.json* file and manage access to files in the *assets* directory.

You may load a bundle from a known path:

```objc
NSString *path = @"...";
TIOModelBundle *bundle = [[TIOModelBundle alloc] initWithPath:path];
```

Model bundles are also used to instantiate model instances with the `newModel` method, effectively functioning as model factories. Each call to this method produces a new model instance:

```objc
id<TIOModel> model = [bundle newModel];
```

Classes that conform to the `TIOModel` protocol also implement a convenience method for instantiating models directly from a model bundle path:

```objc
NSString *path = @"...";
TIOTFLiteModel *model = [TIOTFLiteModel modelWithBundleAtPath:path];
```

<a name="model-json"></a>
### The Model JSON File

One of TensorIO's goals is to reduce the amount of new code required to integrate TF Lite models into an application.

The primary work of using a TF Lite model on iOS involves copying bytes of the right length to the right place. TF Lite is a C++ library, and the input and output tensors are exposed as C style buffers. In order to use a model we must copy byte representations of our input data into these buffers, ask TensorFlow to perform inference on those bytes, and then extract the byte representations back out of them.

Model interfaces can vary widely. Some models may have a single input and single output layer, others multiple inputs with a single output, or vice versa. The layers may be of varying shapes, with some layers taking single values, others an array of values, and yet others taking matrices or volumes of higher dimensions. Some models may work on four byte, floating point representations of data, while others use single byte, unsigned integer representations (these are called *quantized* models, more on them below).

Consequently, every time we want to try a different model, or even the same model with a slightly different interface, we must modify the code that moves bytes into and out of  buffers.

TensorIO abstracts the work of copying bytes into and out of tensors and replaces that imperative code with a declarative language you already know: json.

The *model.json* file in a TensorIO bundle contains metadata about your underlying model as well as a description of the model's input and output layers. TensorIO parses those descriptions and then, when you perform inference with the model, internally handles all the byte copying operations, taking into account layer shapes, data sizes, data transformations, and even output labeling. All you have to do is provide data to the model and ask for the data out of it.

The *model.json* file is the primary point of interaction with the TensorIO library. Any code you write to prepare data for a model and read data from a model will depend on a description of the model's input and output layers that you provide in this file.

Let's have a closer look.

<a name="basic-structure"></a>
#### Basic Structure

The *model.json* file has the following basic structure:

```json
{
  "name": "name of your model",
  "details": "description of your model",
  "id": "unique-identifier",
  "version": "1",
  "author": "you",
  "license": "MIT",
  "model": {
    "file": "model.tflite",
    "quantized": false,
    "type": "image.classification.imagenet"
  },
  "inputs": [
    {
      ...
    }
  ],
  "outputs": [
    {
      ...
    }
  ]
}

```

In addition to the model's metadata, such as name, identifier, version, etc, all of which are required, the json file also includes three additional, required entries:

1. The *model* field is a dictionary that contains information about the model itself
2. The *inputs* field is an array of dictionaries that describe the model's input layers
3. The *outputs* field is an array of dictionaries that describe the model's output layers

<a name="model-field"></a>
#### The Model Field

The model field is a dictionary that itself contains two to four entries:

```json
"model": {
  "file": "model.tflite",
  "quantized": false,
  "type": "image.classification.imagenet",
  "class": "MyOptionalCustomClassName"
}
```

*file*

The *file* field is a string value that contains the name of your TF Lite model file. It is the file with the *.tflite* extension that resides at the top level of your model bundle folder. 

This field is required.

*quantized*

The *quantized* field is a boolean value that is `true` when your model is quantized and `false` when it is not. Quantized models perform inference on single byte, unsigned integer representations of your data (`uint8_t`). Quantized models involve additional considerations which are discussed below.

This field is required.

*type*

The *type* field is a string value that describes the class of models your model belongs to. Currently the field supports arbitrary strings with no formal hierarchy.

This field is optional.

*class*

The *class* field is a string value that contains the Objective-C class name of the custom class you would like to use with your model. It must conform to the `TIOModel` protocol and ship with your application. A custom class is not required, and TensorIO will use `TIOTFLiteModel` for TensorFlow Lite models if you do not provide one.

This field is optional.

<a name="inputs-field"></a>
#### The Inputs Field

The *inputs* field is an array of dictionaries that describe the input layers of your model. There must be a dictionary entry for each input layer in your model. TensorIO uses the information in this field to match inputs to model layers and correctly copy bytes into tensor buffers.

A basic entry in this array will have the following fields:

```json
{
  "name": "layer-name",
  "type": "array",
  "shape": [224]
}
```

*name*

The *name* field is a string value that names this input tensor. It does not have to match the name of a tensor in the underlying model but is rather a reference in application space in case you would like to pass an `NSDictionary` as input to a model's `runOn:` method.

This field is required.

*type*

The *type* field specifies the kind of data this tensor expects. Only two types are currently supported:

- *array*
- *image*

Use the *array* type for shapes of any dimension, including single values, vectors, matrices, and higher dimensional tensors. Use the *image* type for image inputs.

This field is required.

*shape*

The *shape* field is an array of integer values that describe the size of the input layer, ignoring whether the layer expects four byte or single byte values. Common shapes might include:

```json
// a single-valued input
"shape": [1] 			

// a vector with 16 values
"shape": [16]			

// a matrix with 32 rows and 100 columns
"shape": [32,100]		

// a three dimensional image volume with a width of 224px, 
// a height of 224px, and 3 channels (RGB)
"shape": [224,224,3]	
```

This field is required.

**Unrolling Data**

Although we describe the inputs to a layer in terms of shapes with multiple dimensions, and from a mathematical perspective work with vectors, matrices, and tensors, at a machine level, neither TensorIO nor TensorFlow Lite has a concept of a shape.

From a tensor's perspective all shapes are represented as an unrolled vector of numeric values and packed into a contiguous region of memory, i.e. a buffer. Similary, from an Objective-C perspective, all values passed as input to a TensorIO model must already be unrolled into an array of data, either an array of bytes when using `NSData` or an array of `NSNumber` when using `NSArray`.

When you order your data into an array of bytes or an array of numbers in preparation for running a model on it, unroll the bytes using row major ordering. That is, traverse higher order dimensions before lower ones.

For example, a two dimensional matrix with the following values should be unrolled across columns first and then rows. That is, start with the first row, traverse every column, move to the second row, traverse every column, and so on:

```objc
[ [ 1 2 3 ]
  [ 4 5 6 ] ]
  
NSArray *matrix = @[ @(1), @(2), @(3), @(4), @(5), @(6) ]; 
```

Apply the same approach for volumes of a higher dimension, as mind-boggling as it starts to get.

**Additional Fields**

There are additional fields for handling data transformations such as quantization and pixel normalization. These will be discussed in their respective sections below.

**Both Order and Name Matter**

Input to a `TIOModel` may be organized by either index or name, so that both the order of the dictionaries in the *inputs* array and their names are significant. TF Lite tensors are accessed by index, but internally TensorIO associates a name with each index in case you prefer to send `NSDictionary` inputs to your models.

**Example**

Here's what the *inputs* field looks like for a model with two input layers, the first a vector with 8 values and the second a 10x10 matrix:

```json
"inputs": [
  {
    "name": "vector-input",
    "type": "array",
    "shape": [8]
  },
  {
    "name": "matrix-input",
    "type": "array",
    "shape": [10,10]
  }
],
```

With this description we can pass either an array of arrays or a dictionary of arrays to the model's `runOn:` method. To pass an array, make sure the order of your inputs matches the order of their entries in the json file:

```objc
NSArray *vectorInput = @[ ... ]; // with 8 values
NSArray *matrixInput = @[ ... ]; // with 100 values in row major order

NSArray *arrayInputs = @[
  vectorInput,
  matrixInput
];

[model runOn:arrayInputs];
```

To pass a dictionary, simply associate the correct name with each value:

```objc
NSArray *vectorInput = @[ ... ]; // with 8 values
NSArray *matrixInput = @[ ... ]; // with 100 values in row major order

NSDictionary *dictionaryInputs = @{
  @"vector-input": vectorInput,
  @"matrix-input": matrixInput
};

[model runOn:dictionaryInputs];
```

<a name="outputs-field"></a>
#### The Outputs Field

The *outputs* field is an array of dictionaries that describe the output layers of your model. The *outputs* field is structured the same way as the *inputs* field, and the dictionaries contain the same basic entries as those in the *inputs* field:

```json
"outputs": [
  {
    "name": "vector-output",
    "type": "array",
    "shape": [8]
  }
]
```

**The Labels Field**

An *array* type output optionally supports the presence of a *labels* field for classification outputs:

```json
"outputs": [
  {
    "name": "classification-output",
    "type": "array",
    "shape": [1000],
    "labels": "labels.txt"
  }
]
```

The value of this field is a string which corresponds to the name of a text file in the bundle's *assets* directory.  The *.tfbundle* directory structure for this model might look like:

```
mymodel.tfbundle
  - model.json
  - model.tflite
  - assets
    - labels.txt
```

Each line of the *labels.txt *text file contains the name of the classification for that line number index in the layer's output. When a *labels* field is present, TensorIO internally maps labels to their numeric outputs and returns an `NSDictionary` representation of that mapping, rather than a simple `NSArray` of values. Let's see what that looks like.

**Model Outputs**

Normally, a model returns a dictionary of array values from its `runOn:` method, and those values will usually be arrays. Each layer produces its own entry in that dictionary, corresponding to the name of the layer in its json description. 

For example, a self-driving car model might classify three kinds of things in an image (well, hopefully more than that!). The *outputs* field for this model might look like:

```json
"outputs": [
  {
    "name": "classification-output",
    "type": "array",
    "shape": [3],
  }
]
```

After performing inference the underlying TensorFlow model will produce an output with three values corresponding to the softmax probability that this item appears in the image. TensorIO extracts those bytes and packs them into an `NSArray` of `NSNumber`:

```objc
NSDictionary *inference = (NSDictionary*)[model runOn:input];
NSArray<NSNumber*> *classifications = inference[@"classification-output"];

// classifications[0] == 0.25
// classifications[1] == 0.75
// classifications[2] == 0.25
```

However, when a *labels* entry is present for a layer, the entry for that layer will itself be a dictionary mapping names to values.

Our self-driving car model might for example add a *labels* field to the above description:

```json
"outputs": [
  {
    "name": "classification-output",
    "type": "array",
    "shape": [3],
    "labels": "labels.txt"
  }
]
```

With a *labels.txt* file in the bundle's *assets* directory that looks like:

```txt
pedestrian
car
motorcycle
```

The underlying tensorflow model still produces an output with three values corresponding to the softmax probability that this item appears in the image. TensorIO, however, now maps labels to those probabilities and returns a dictionary of those mappings:

```objc
NSDictionary *inference = (NSDictionary*)[model runOn:input];
NSDictionary<NSString*, NSNumber*> *classifications = inference[@"classification-output"];

// classifications[@"pedestrian"] == 0.25
// classifications[@"car"] == 0.75
// classifications[@"motorcycle"] == 0.25
```

**Single Valued Outputs**

In some cases your model might output a single value in one of its output layers. Consider the housing price model we discussed earlier. When that is the case, instead of wrapping that single value in an array and returning an array for that layer, TensorIO will simply output a single value for it.

Consider a model with two output layers. The first layer outputs a vector of four values while the second outputs a single value:

```json
"outputs": [
  {
    "name": "vector-output",
    "type": "array",
    "shape": [4]
  },
  {
    "name": "scalar-output",
    "type": "array",
    "shape": [1]
  }
]
```

After performing inference, access the first layer as an array of numbers and the second layer as a single number:

```objc
NSDictionary *inference = (NSDictionary*)[model runOn:input];
NSArray<NSNumber*> *vectorOutput = inference[@"vector-output"];
NSNumber *scalarOutput = inference[@"scalar-output"];
```

*Scalar outputs are supported as a convenience. Model outputs may change in a later version of this library and so this convenience may be removed or modified.*

<a name="complete-example"></a>
#### A Complete Example

Let's see a complete example of a model with two input layers and two output layers. The model takes two vectors, the first with 4 values and the second with 8 values, and outputs two vectors, the first with 3 values and the second with 6.

Our *tfbundle* folder will have the following contents:

```
mymodel.tfbundle
  - model.json
  - model.tflite
```

The *model.json* file might look something like:

```json
{
  "name": "Example Model",
  "details": "This model takes two vector valued inputs and produces two vector valued outputs",
  "id": "my-awesome-model",
  "version": "1",
  "author": "doc.ai",
  "license": "Apache 2",
  "model": {
    "file": "model.tflite",
    "quantized": false
  },
  "inputs": [
    {
      "name": "foo-features",
      "type": "array",
      "shape": [4]
    },
    {
      "name": "bar-features",
      "type": "array",
      "shape": [8]
    }
  ],
  "outputs": [
    {
      "name": "baz-outputs",
      "type": "array",
      "shape": [3]
    },
    {
      "name": "qux-outputs",
      "type": "array",
      "shape": [6]
    }
  ]
}
```

And we can perform inference with this model as follows:

```objc
NSArray *fooFeatures = @[ @(1), @(2), @(3), @(4) ]; 
NSArray *barFeatures = @[ @(1), @(2), @(3), (@4), @(5), @(6), @(7), @(8) ]; 

NSDictionary *features = @{
  @"foo-features": fooFeatures,
  @"bar-features": barFeatures
};

NSDictionary *inference = (NSDictionary*)[model runOn:features];

NSArray *bazOutputs = inference[@"baz-outputs"]; // length 3
NSArray *quxOutputs = inference[@"qux-outputs"]; // length 6
```

<a name="quantization"></a>
### Quantization and Dequantization

Quantization is a technique for reducing model sizes by representing weights with fewer bytes. Operations are then performed on these shorter byte representations. Quantized models trade accuracy for size. A full account of quantization is beyond the scope of this README, but more information may be found at https://www.tensorflow.org/performance/quantization.

In TF Lite, models represent weights with and perform operations on four byte floating point representations of data (`float_t`). These models receive floating point inputs and produce floating point outputs. Floating point models can represent numeric values in the range -3.4E+38 to +3.4E+38. Pretty sweet.

A quantized TF Lite model works with single byte representations `(uint8_t)`. It expects single byte inputs and it produces single byte outputs. A single unsigned byte can represent numbers in the range of 0 to 255. Still pretty cool.

When you use a quantized model but start with floating point data, you must first transform that four byte representation into one byte. This is called *quantization*. The model's single byte output must also be transformed back into a floating point representation, an inverse process called *dequantization*. TensorIO can do both for you.

Let's see what a basic quantization and dequantization look like.

<a name="quantization-basic-example"></a>
#### A basic example

First, when working with a quantized TF Lite model, change the *model.quantized* field in the *model.json* file to `true`:

```json
"model": {
  "file": "model.tflite",
  "quantized": true
},
```

For this example, let's say the input data coming from application space will always be in a floating point range from 0 to 1. Our quantized model requires those values to be in the range from 0 to 255. Quantization in TF Lite uniformly distributes a floating point range over a single byte range, so all we need to do here is apply a scaling factor of 255:

```
quantized_value = unquantized_value * 255
```

We can perform a sanity check with a few values:

```
Unquantized Value -> Quantized Value

0	->	0
0.5	->	127
1	->	255
```

Similarly, for this example let's say the output values produced by inference are a softmax probability distribution. The quantized model necessarily produces outputs in a range from 0 to 255, and we want to convert those back to a valid probability distribution. This will again be a uniform redistribution of values, and all we need to do is apply a scaling factor of 1.0/255.0:

```
unquantized_value = quantized_value * 1.0/255.0
```

Note that the transformations are inverses of one anther, and a sanity check produces the values we expect.

<a name="quantize-field"></a>
#### The Quantize Field

Instruct TensorIO to perform quantization by adding a *quantize* field to an input layer's description:

```json
"inputs": [
  {
    "name": "vector-input",
    "type": "array",
    "shape": [4],
    "quantize": {
      "scale": 255,
      "bias": 0
    }
  },
``` 

The *quantize* field is a dictionary value that may appear on *array* inputs only (*image* inputs use pixel normalization, more below). It contains either one or two fields: either both *scale* and *bias*, or *standard*.

*scale*

The *scale* field is a numeric value that specifies the scaling factor to apply to unquantized, incoming data.

*bias*

The *bias* field is a numeric value that specifies the bias to apply to unquantized, incoming data.

Together, TensorIO applies the following equation to any data sent to this layer:

```
quantized_value = (unquantized_value + bias) * scale
``` 

*standard*

The *standard* field is a string value corresponding to one of a number of commonly used quantization functions. Its presence overrides the *scale* and *bias* fields.

TensorIO currently has support for two standard quantizations. The ranges tell TensorIO *what range of values you are quantizing from*:

```json
"quantize": {
  "standard": "[0,1]"
}

"quantize": {
  "standard": "[-1,1]"
}
```

<a name="dequantize-field"></a>
#### The Dequantize Field

Dequantization is the inverse of quantization and is specified for an output layer with the *dequantize* field. The same *scale* and *bias* or *standard* fields are used.

For dequantization, scale and bias are applied in inverse order, where the bias value will be the negative equivalent of a quantization bias, and the scale will be the inverse of a quantization scale.

```
unquantized_value = quantized_value * scale + bias
```

For example, to dequantize from a range of 0 to 255 back to a range of 0 to 1, use a bias of 0 and a scale of 1.0/255.0:

```json
"outputs": [
  {
    "name": "vector-output",
    "type": "array",
    "shape": [4],
    "dequantize": {
      "scale": 0.004,
      "bias": 0
    }
  }
]
```

A standard set of dequantization functions is supported and describes *the range of values you want to dequantize back to*:

```json
"dequantize": {
  "standard": "[0,1]"
}

"dequantize": {
  "standard": "[-1,1]"
}
```

The *[0,1]* standard dequantization is particularly useful for softmax proability outputs with quantized models, when you must convert from a quantized range of [0,255] back to a valid probability distribution in the range of [0,1].

**Using Quantization and Dequantization**

Once these fields have been specified in a *model.json* file, no additional change is required in the Objective-C code. Simply send floating point values in and get floating point values back:

```objc
NSArray *vectorInput = @[ @(0.1f), @(0.2f), @(0.3f), @(0.4f) ]; // range in [0,1]

NSDictionary *features = @{
  @"vector-input": vectorInput
};

NSDictionary *inference = (NSDictionary*)[model runOn:features];

NSArray *vectorOutput = inference[@"vector-output"];

// vectorOutput[0] == 0.xx...
// vectorOutput[1] == 0.xx...
// vectorOutput[2] == 0.xx...
// vectorOutput[3] == 0.xx...

```

<a name="selecting-scale-bias"></a>
#### Selecting the Scale and Bias Terms

Selecting the scale and bias terms for either quantization or dequantization is a matter of solving a system of linear equations. 

**Quantization Scale and Bias**

For quantization, for example, you must know the range of values that are being quantized and the range of values you are quantizing to. The latter is always [0,255], while the former is up to you.

Then, given that the equation for quantizing a value is 

```
quantized_value = (unquantized_value + bias) * scale
```

You can form two equations:

```
(min + bias) * scale = 0
(max + bias) * scale = 255
```

And solve for scale and bias. Because the first equation is always set equal to zero, it is trivial to solve for bias. Use that result to solve for scale in the second equation:

```
bias  = -min
scale = 255 / (max - min)
```

For example, if you are quantizing from a range of values in [-1,1], then the scale and bias terms are:

```
bias  = -(-1) 
      = 1
      
scale = 255 / (1-(-1)) 
      = 255/2
      = 127.5
```

Which are exactly the values TensorIO uses when you specify a standard quantize string *"[-1,1]"*.

**Dequantization Scale and Bias**

For dequantization we do the same, using the equation:

```
unquantized_value = quantized_value * scale + bias
```

Form two equations:

```
min = 0 * scale   + bias
max = 255 * scale + bias
```

And solve for scale and bias:

```
bias  = min
scale = (max - bias) / 255
```

For example, if you are dequantizing from a range of values in [-1,1], then the scale and bias terms are:

```
bias  = -1

scale = (1-(-1)) / 255
      = 2/255
      = 0.0078
```

Which once again are the values TensorIO uses when you specify the standard dequantize string *"[-1,1]"*.

In both cases, you will need to know what the maximum and minimum values are that you are quantizing from and dequantizing to, and these must match the values you have used for your model.

<a name="quantization-complete-example"></a>
#### A Complete Example

Let's look at a complete example. This model is quantized and has two input layers and two output layers, with standard but different quantizations and dequantizations.

The model bundle will again have two files in it:

```
myquantizedmodel.tfbundle
  - model.json
  - model.tflite
```

Noting the value of the *model.quantized* field and the presence of *quantize* and *dequantize* fields in the input and output descriptions, the *model.json* file might look like: 

```json
{
  "name": "Example Quantized Model",
  "details": "This model takes two vector valued inputs and produces two vector valued outputs",
  "id": "my-awesome-quantized-model",
  "version": "1",
  "author": "doc.ai",
  "license": "Apache 2",
  "model": {
    "file": "model.tflite",
    "quantized": true
  },
  "inputs": [
    {
      "name": "foo-features",
      "type": "array",
      "shape": [4],
      "quantize": {
        "standard": "[0,1]"
      }
    },
    {
      "name": "bar-features",
      "type": "array",
      "shape": [8],
      "quantize": {
        "standard": "[-1,1]"
      }
    }
  ],
  "outputs": [
    {
      "name": "baz-outputs",
      "type": "array",
      "shape": [3],
      "dequantize": {
        "standard": "[0,1]"
      }
    },
    {
      "name": "qux-outputs",
      "type": "array",
      "shape": [6],
      "dequantize": {
        "standard": "[-1,1]"
      }
    }
  ]
}
```

Perform inference with this model as before:

```objc
NSArray *fooFeatures = @[ @(0.1f), @(0.2f), @(0.3f), @(0.4f) ]; // range in [0,1] 
NSArray *barFeatures = @[ @(-0.1f), @(0.2f), @(0.3f), (@0.4f), @(-0.5f), @(0.6f), @(-0.7f), @(0.8f) ]; // range in [-1,1] 

NSDictionary *features = @{
  @"foo-features": fooFeatures,
  @"bar-features": barFeatures
};

NSDictionary *inference = (NSDictionary*)[model runOn:features];

NSArray *bazOutputs = inference[@"baz-outputs"]; // length 3 in range [0,1]
NSArray *quxOutputs = inference[@"qux-outputs"]; // length 6 in range [-1,1]
```


<a name="quantization-without-quantization"></a>
#### Quantized Models without Quantization

The *quantize* field is optional for *array* input layers, even when the model is quantized. When you use a quantized model without including a *quantize* field, it is up to you to ensure that the data you send to TensorIO for inference is already quantized and that you treat output data as still quantized. 

This may be the case when your input and output data is only ever in the range of [0,255], for example pixel data, or when you are quantizing the floating point inputs yourself before sending them to the model.

For example:

```objc
NSArray<NSNumber*> *unquantizedInput = @[ @(0.1f), @(0.2f), @(0.3f), @(0.4f) ]; // range in [0,1] 
NSArray<NSNumber*> *quantizedInput = [unquantizedInput map:^NSNumber * _Nonnull(NSNumber *  _Nonnull obj) {
  return @(obj.floatValue * 255); // convert from [0,1] to [0,255]
}];

NSDictionary *features = @{
  @"quantized-input": quantizedInput
};

NSDictionary *inference = (NSDictionary*)[model runOn:features];

NSArray *quantizedOutput = inference[@"quantized-output"]; // in range [0,255]
NSArray *dequantizedOutput = [quantizedOutput map:^NSNumber * _Nonnull(NSNumber *  _Nonnull obj) {
  return @(obj.unsignedCharValue * 1.0/255.); // convert from [0,255] to [0,1]]
}];
```

<a name="images"></a>
### Working with Image Data

TensorIO has built-in support for  image data and can perform inference on image data as well as return image data as an output. A key concept when working with image data is the *pixel buffer*, which is a pixel by pixel representation of an image in memory. 

TensorIO works with pixel buffers and includes a wrapper for the native `CVPixelBufferRef`. It also provides utility functions for converting instances of `UIImage` to and from pixel buffers.

<a name="images-basic-example"></a>
#### A Basic Example

As always, inform TensorIO that an input layer expects pixel buffer data by modifying that layer's description in *model.json*. Set its *type* to *image*. You must specify the *shape* as an array of *[height, width, channels]* and the *format* of the image as either *RGB* or *BGR*. More on image formats below. 

For now let's assume the tensor takes image volumes of size 224x224x3 with RGB byte ordering:

```json
"inputs": [
  {
    "name": "image-input",
    "type": "image",
    "shape": [224,224,3],
    "format": "RGB"
  }
]
```

We can then pass image data to this model by wrapping an image's pixel buffer in a `TIOPixelBuffer`, which knows how to copy pixel data to the tensor given the format:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
CVPixelBufferRef pixelBuffer = image.pixelBuffer;
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];

NSDictionary *inference = (NSDictionary*)[model runOn:buffer];
```

<a name="pixel-buffer"></a>
#### Pixel Buffers

A pixel buffer is a pixel by pixel representation of image data laid out in a contiguous block of memory. On iOS some APIs provide raw pixel buffers by default, such the AVFoundation APIs, while in other cases we must construct pixel buffers ourselves.

A pixel buffer always has a size, which includes the width and height, as well as a format, such as ARGB or BGRA, which lets the buffer know how many *channels* of data there are for each pixel and in what order those bytes appear. In the case of ARGB and BGRA, there are four channels of data arranged in alpha-red-green-blue or blue-green-red-alpha order respectively.

The ARGB and BGRA pixel buffers on iOS represent each pixel using four bytes of memory, with a single byte allocated to each channel. Each color in the pixel is represented by a range of values from 0 to 255, and the alpha channel also, allowing a pixel to represent over 16 million colors with 256 alpha values.

<a name="pixel-format"></a>
#### The Format Field

Tensors operate on pixel buffers with specific byte orderings. Imagine the memory for a pixel buffer in ARGB format. The top left pixel at (0,0) will appear first, then the pixel to its right at (1,0), and to its right at (2,0) and so on, for each column and each row in the image, with the bytes appearing in alpha-red-green-blue order:

```
[ARGB][ARGB][ARGB][ARGB][ARGB]...
```

Now imagine what that same image looks like to the tensor in BGRA format:

```
[BGRA][BGRA][BGRA][BGRA][BGRA]...
```

The byte ordering, which is to say, the format of the pixel buffer, definitely matters! 

You must let TensorIO know what byte ordering an input layer expects via the *format* field. Consequently you must know what byte ordering your model expects.

TensorIO supports two byte orderings, *RGB* and *BGR*. Models ignore the alpha channel and don't expect it to be present, so TensorIO internally skips it when copying ARGB or BGRA pixel buffer bytes into tensors.

```json
{
  "format": "RGB"
}

{
  "format": "BGR"
}
```

<a name="pixel-normalization"></a>
#### Pixel Normalization

Notice that pixels are represented using a single byte of data for each color channel, a `uint8_t`. Recall what we know about quantized models. By default, TF Lite works with four byte floating point representations of data, `float_t`, but when the model is quantized it uses single byte `uint8_t` representations of data. 

Hm. It looks like pixel buffer data is already "quantized"! 

In fact, when working with quantized models, you may pass pixel buffer data directly to input layers and read it directly from output layers without needing to transform the data (other than skipping the alpha channel). Quantized models already work on values in a range from 0 to 255, and pixel buffer data is exactly in this range.

Models that are not quantized, however, expect pixel buffer data in a floating point representation, and they will typically want it in a *normalized* range of values, usually from 0 to 1 or from -1 to 1. The process of converting pixel values from a single byte representation to a floating point representation is called *normalization*, and TensorIO includes built-in support for it.

**The Normalize Field**

As always, you will need to update the description of an input layer to indicate what kind of normalization you want. Include the *normalize* field in the layer's entry. Like the *quantize* field it takes either two entries or a single entry: either *scale* and *bias*, or a *standard* field, with the difference that bias may be applied on a per channel basis.

*scale*

The *scale* field is a numeric value that specifies the scaling factor to apply to incoming pixel data.

*bias*

The *bias* field is a dictionary value that specifies the bias to apply to incoming pixel data, on a *per channel* basis, and itself includes three entries, *r*, *g*, and *b*.

Together, a *scale* and *bias* entry might look like:

```json
"normalize": {
  "scale": 0.004,
  "bias": {
    "r": -0.485,
    "g": -0.457,
    "b": -0.408
  }
}
```

And together, TensorIO applies the following equation to any pixel data sent to this layer:

```
normalized_red_value   = scale * red_value   + red_bias
normalized_green_value = scale * green_value + green_bias
normalized_blue_value  = scale * blue_value  + blue_bias
``` 

*standard*

The *standard* field is a string value corresponding to one of a number of commonly used normalizations. Its presence overrides the *scale* and *bias* fields.

TensorIO currently supports two standard normalizations. The ranges tell TensorIO *what values you are normalizing to*:

```json
"normalize": {
  "standard": "[0,1]"
}

"normalize": {
  "standard": "[-1,1]"
}
```

<a name="pixel-normalization"></a>
#### Pixel Denormalization

TensorIO can also read pixel data from output tensors and reconstruct pixel buffers from them. When reading pixel data from an unquantized model it will usually be necessary to convert the values from a normalized floating point representation back to `uint8_t` values in the range of 0 to 255. This process is called *denormalization*, and once again TensorIO has built in support for it.

To denormalize pixel data add a *denormalize* field to an output layer's description. Like the *normalize* field this field takes either *scale* and *bias* entries or a *standard* entry. The fields work as they do for normalization but as their inverses.

For bias and scale, the following equation will be applied:

```
red_value   = (normalized_red_value   + red_bias)   * scale
green_value = (normalized_green_value + green_bias) * scale
blue_value  = (normalized_blue_value  + blue_bias)  * scale
```

Similarly, TensorIO supports two standard denormalizations. The ranges tell TensorIO *what values you are denormalizing from*:

```json
"denormalize": {
  "standard": "[0,1]"
}

"denormalize": {
  "standard": "[-1,1]"
}
```

<a name="pixel-buffer-complete-example"></a>
#### A Complete Example

Let's look at a complete example. This is the unquantized MobileNetV2 image classification model provided by TensorFlow. It takes a single input, image data of size 224x224x3 in RGB format, and produces a single output, a vector of 1000 softmax probabilities identifying the object in the image. It expects image data to be normalized to a range from -1 to 1, and we would like to label the output data.

The model bundle folder might look something like:

```
mobilenet-model.tfbundle
  - model.json
  - model.tflite
  - assets
    - labels.txt
```

The *model.json* file might look like:

```json
{
  "name": "MobileNet V2 1.0 224",
  "details": "MobileNet V2 with a width multiplier of 1.0 and an input resolution of 224x224. \n\nMobileNets are based on a streamlined architecture that have depth-wise separable convolutions to build light weight deep neural networks. Trained on ImageNet with categories such as trees, animals, food, vehicles, person etc. MobileNets: Efficient Convolutional Neural Networks for Mobile Vision Applications.",
  "id": "mobilenet-v2-100-224-unquantized",
  "version": "1",
  "author": "Andrew G. Howard, Menglong Zhu, Bo Chen, Dmitry Kalenichenko, Weijun Wang, Tobias Weyand, Marco Andreetto, Hartwig Adam",
  "license": "Apache License. Version 2.0 http://www.apache.org/licenses/LICENSE-2.0",
  "model": {
    "file": "model.tflite",
    "quantized": false,
  },
  "inputs": [
    {
      "name": "image",
      "type": "image",
      "shape": [224,224,3],
      "format": "RGB",
      "normalize": {
        "standard": "[-1,1]"
      }
    },
  ],
  "outputs": [
    {
      "name": "classification",
      "type": "array",
      "shape": [1,1000],
      "labels": "labels.txt"
    },
  ]
}
```

And we can use this model as follows:

```objc
UIImage *image = [UIImage imageNamed:@"example-image"];
TIOPixelBuffer *buffer = [[TIOPixelBuffer alloc] initWithPixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];

NSDictionary *inference = (NSDictionary*)[model runOn:buffer];
NSDictionary<NSString*,NSNumber*> *classification = inference[@"classification"];

```

<a name="advanced-usage"></a>
### Advanced Usage

TensorIO includes a number of additional utilities, especially for working with image data. Until this section is completed, refer to the following files:

- TIOCVPixelBufferHelpers
- UIImage+TIOCVPixelBufferExtensions
- TIOModelOptions
- TIOVisionPipeline

<a name="netrunner"></a>
### Net Runner

For an example of TensorIO in action check out [Net Runner](https://github.com/doc-ai/net-runner-ios), our iOS environment for evaluating computer vision machine learning models.

<a name="faq"></a>
### FAQ

The FAQ is forthcoming.