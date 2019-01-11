//
//  ImageInputPreviewView.mm
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
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

#import "ImageInputPreviewView.h"

@import TensorIO;

static float kViewDim = UIScreen.mainScreen.bounds.size.width <= 320 ? 54.0 : 64.0;
static float kDotViewOffset = 0.0;
static float kDotViewDim = 5.0;

@interface ImageInputPreviewView() {
    UIStackView *stackView;
    UIImageView *bufferImageView;
    UIImageView *bufferChannel0ImageView;
    UIImageView *bufferChannel1ImageView;
    UIImageView *bufferChannel2ImageView;
    UIImageView *bufferChannel3ImageView;
    
    UIView *redDot;
    UIView *greenDot;
    UIView *blueDot;
}

@property (readonly) UIImageView *alphaImageView;
@property (readonly) UIImageView *redImageView;
@property (readonly) UIImageView *greenImageView;
@property (readonly) UIImageView *blueImageView;

@end

@implementation ImageInputPreviewView

- (UIImageView*)alphaImageView {
    return self.pixelFormat == kCVPixelFormatType_32ARGB
        ? bufferChannel0ImageView
        : bufferChannel3ImageView;
}

- (UIImageView*)redImageView {
    return self.pixelFormat == kCVPixelFormatType_32ARGB
        ? bufferChannel1ImageView
        : bufferChannel2ImageView;
}

- (UIImageView*)greenImageView {
    return self.pixelFormat == kCVPixelFormatType_32ARGB
        ? bufferChannel2ImageView
        : bufferChannel1ImageView;
}

- (UIImageView*)blueImageView {
    return self.pixelFormat == kCVPixelFormatType_32ARGB
        ? bufferChannel3ImageView
        : bufferChannel0ImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    
    self.pixelFormat = kCVPixelFormatType_32ARGB;
    self.showsAlphaChannel = YES;
    
    // View Properties
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    
    // Stack View
    
    stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 0;
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [stackView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0],
        [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [stackView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0]
    ]];
    
    // Image Views
    
    bufferChannel0ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setProperties:bufferChannel0ImageView];
    
    bufferChannel1ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setProperties:bufferChannel1ImageView];
    
    bufferChannel2ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setProperties:bufferChannel2ImageView];
    
    bufferChannel3ImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setProperties:bufferChannel3ImageView];
    
    bufferImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setProperties:bufferImageView];
    
    // Add Em
    
    [stackView addArrangedSubview:bufferChannel0ImageView];
    [stackView addArrangedSubview:bufferChannel1ImageView];
    [stackView addArrangedSubview:bufferChannel2ImageView];
    [stackView addArrangedSubview:bufferChannel3ImageView];
    [stackView addArrangedSubview:bufferImageView];
    
    // Dot Image Views
    
    redDot = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setDotProperties:redDot color:UIColor.redColor];
    
    greenDot = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setDotProperties:greenDot color:UIColor.greenColor];
    
    blueDot = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self setDotProperties:blueDot color:UIColor.blueColor];
    
    [self.redImageView addSubview:redDot];
    [self.blueImageView addSubview:blueDot];
    [self.greenImageView addSubview:greenDot];
}

- (void)setProperties:(UIImageView*)imageView {
    imageView.translatesAutoresizingMaskIntoConstraints = false;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1;
    
    [imageView.heightAnchor constraintEqualToConstant:kViewDim].active = YES;
    [imageView.widthAnchor constraintEqualToConstant:kViewDim].active = YES;
}

- (void)setDotProperties:(UIView*)view color:(UIColor*)color {
    view.frame = CGRectMake(kDotViewOffset, kDotViewOffset, kDotViewDim, kDotViewDim);
    view.backgroundColor = color;
    view.clipsToBounds = YES;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    // view.layer.cornerRadius = kDotViewDim / 2;
    view.layer.borderWidth = 1;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, kViewDim);
}

// MARK: -

- (void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = pixelBuffer;
    CVPixelBufferRetain(_pixelBuffer);
    
    // Update main buffer view
    
    UIImage *inputImage = [[UIImage alloc] initWithPixelBuffer:pixelBuffer scale:1.0 orientation: UIImageOrientationUp];
    
    // Channel views
    
    CVPixelBufferRef channel0Buffer = NULL,
                     channel1Buffer = NULL,
                     channel2Buffer = NULL,
                     channel3Buffer = NULL;
    
    CVReturn status = TIOCVPixelBufferCopySeparateChannels(pixelBuffer,
        &channel0Buffer,
        &channel1Buffer,
        &channel2Buffer,
        &channel3Buffer
    );

    if ( status != kCVReturnSuccess ) {
        NSLog(@"Unable to generate channel previews, error: %d", status);
        return;
    }
    
    tio_defer_block {
        CVPixelBufferRelease(channel0Buffer);
        CVPixelBufferRelease(channel1Buffer);
        CVPixelBufferRelease(channel2Buffer);
        CVPixelBufferRelease(channel3Buffer);
    };

    UIImage *channel0Image = [[UIImage alloc] initWithPixelBuffer:channel0Buffer];
    UIImage *channel1Image = [[UIImage alloc] initWithPixelBuffer:channel1Buffer];
    UIImage *channel2Image = [[UIImage alloc] initWithPixelBuffer:channel2Buffer];
    UIImage *channel3Image = [[UIImage alloc] initWithPixelBuffer:channel3Buffer];
    
    UIImage *alphaImage = self.pixelFormat == kCVPixelFormatType_32ARGB
        ? channel0Image
        : channel3Image;
    
    UIImage *redImage = self.pixelFormat == kCVPixelFormatType_32ARGB
        ? channel1Image
        : channel2Image;
    
    UIImage *greenImage = self.pixelFormat == kCVPixelFormatType_32ARGB
        ? channel2Image
        : channel1Image;
    
    UIImage *blueImage = self.pixelFormat == kCVPixelFormatType_32ARGB
        ? channel3Image
        : channel0Image;
    
    // Update everything on the main thread
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self->bufferImageView.image = inputImage;

        self.alphaImageView.image = alphaImage;
        self.redImageView.image = redImage;
        self.blueImageView.image = blueImage;
        self.greenImageView.image = greenImage;

        if ( !self.showsAlphaChannel ) {
            self.alphaImageView.image = nil;
        }
    });
}

- (void)setShowsAlphaChannel:(BOOL)showsAlphaChannel {
    if ( _showsAlphaChannel == showsAlphaChannel ) {
        return;
    }
    
    _showsAlphaChannel = showsAlphaChannel;
    [self rearrangeImageViews];
}

- (void)setPixelFormat:(OSType)pixelFormat {
    assert(pixelFormat == kCVPixelFormatType_32BGRA || pixelFormat == kCVPixelFormatType_32ARGB);
    
    if ( _pixelFormat == pixelFormat ) {
        return;
    }
    
    _pixelFormat = pixelFormat;
    [self rearrangeImageViews];
}

- (void)rearrangeImageViews {
    
    // Alpha placeholder if alpha is hidden
    
    UIImageView *placeholder = [[UIImageView alloc] init];
    [self setProperties:placeholder];
    
    placeholder.layer.borderColor = UIColor.clearColor.CGColor;
    placeholder.layer.borderWidth = 0;
    
    for ( UIView *subview in stackView.arrangedSubviews ) {
        [stackView removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    
    // Arranged views
    
    if ( _pixelFormat == kCVPixelFormatType_32BGRA ) {
        if ( _showsAlphaChannel ) {
            [stackView addArrangedSubview:bufferChannel0ImageView]; // B
            [stackView addArrangedSubview:bufferChannel1ImageView]; // G
            [stackView addArrangedSubview:bufferChannel2ImageView]; // R
            [stackView addArrangedSubview:bufferChannel3ImageView]; // A
            [stackView addArrangedSubview:bufferImageView];         // •
        } else {
            [stackView addArrangedSubview:bufferChannel0ImageView]; // B
            [stackView addArrangedSubview:bufferChannel1ImageView]; // G
            [stackView addArrangedSubview:bufferChannel2ImageView]; // R
            [stackView addArrangedSubview:placeholder];             // -
            [stackView addArrangedSubview:bufferImageView];         // •
        }
    } else if ( _pixelFormat == kCVPixelFormatType_32ARGB ) {
        if ( _showsAlphaChannel ) {
            [stackView addArrangedSubview:bufferChannel0ImageView]; // A
            [stackView addArrangedSubview:bufferChannel1ImageView]; // R
            [stackView addArrangedSubview:bufferChannel2ImageView]; // G
            [stackView addArrangedSubview:bufferChannel3ImageView]; // B
            [stackView addArrangedSubview:bufferImageView];         // •
        } else {
            [stackView addArrangedSubview:bufferChannel1ImageView]; // R
            [stackView addArrangedSubview:bufferChannel2ImageView]; // G
            [stackView addArrangedSubview:bufferChannel3ImageView]; // B
            [stackView addArrangedSubview:placeholder];             // -
            [stackView addArrangedSubview:bufferImageView];         // •
        }
    }
    
    // Color dots
    
    [redDot removeFromSuperview];
    [greenDot removeFromSuperview];
    [blueDot removeFromSuperview];
    
    [self.redImageView addSubview:redDot];
    [self.blueImageView addSubview:blueDot];
    [self.greenImageView addSubview:greenDot];
}

@end
