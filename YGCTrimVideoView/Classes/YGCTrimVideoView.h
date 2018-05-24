//
//  YGCTrimVideoView.h
//  VideoTrimView
//
//  Created by Qilong Zang on 30/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^YGCExportFinished)(BOOL success, NSURL *outputURL);

@protocol YGCTrimVideoViewDelegate <NSObject>

- (void)videoBeginTimeChanged:(CMTime)begin;

- (void)videoEndTimeChanged:(CMTime)end;

- (void)dragActionEnded:(AVMutableComposition *)asset;

@optional

- (void)videoExportProgressChanged: (float) percent;
- (void)videoExportStarted; //TODO: Renamed?
- (void)videoExportFinished: (BOOL) success url: (NSURL *) url;
@end

@interface YGCTrimVideoView : UIView

@property (nonatomic, weak) id<YGCTrimVideoViewDelegate> delegate;

@property (nonatomic, strong, readonly) AVMutableComposition *currentAsset;

/*
 * change the left sidebar Image
 */
@property (nonatomic, strong) UIImage *leftSidebarImage;

/*
 * change the right sidebar Image
 */
@property (nonatomic, strong) UIImage *rightSidebarImage;

/*
 * change the center range Image
 */
@property (nonatomic, strong) UIImage *centerRangeImage;

/*
 * change the maximum duration of video
 */
@property (nonatomic, assign) NSTimeInterval maxSeconds;

/*
 * change the minimum duration of video
 */
@property (nonatomic, assign) NSTimeInterval minSeconds;

/*
 * change the left and right side maskView when slider range decrease
 */
@property (nonatomic, strong) UIColor *maskColor;



- (id)initWithFrame:(CGRect)frame
            assetURL:(NSURL *)url ;// NS_SWIFT_NAME(exportVideo(completion:));

- (id)initWithFrame:(CGRect)frame
            assetURL:(NSURL *)url
   leftSidebarImage:(UIImage *)leftImage
  rightSidebarImage:(UIImage *)rightImage
   centerRangeImage:(UIImage *)centerImage
       sidebarWidth:(CGFloat)width
   controlViewInset:(CGFloat)inset;

- ( AVAssetExportSession * _Nonnull )exportVideo:(YGCExportFinished)finishedBlock NS_SWIFT_NAME(exportVideo(completion:));
- ( AVAssetExportSession * _Nonnull )exportVideoType: (AVFileType) videoType
                   name:(NSString *)name  completion: (YGCExportFinished)finishedBlock NS_SWIFT_NAME(exportVideo(as:named:completion:));

@end
