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
typedef void(^YGCExportThumbnailFinished)(BOOL success, UIImage *image);
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

- (AVAssetExportSession * _Nonnull )exportVideo:(YGCExportFinished)finishedBlock NS_SWIFT_NAME(exportVideo(completion:));
- (AVAssetExportSession * _Nonnull )exportVideoType: (AVFileType) videoType
                   name:(NSString *)name  completion: (YGCExportFinished)finishedBlock NS_SWIFT_NAME(exportVideo(as:name:completion:));

- ( AVAssetExportSession * _Nonnull )exportVideoType: (AVFileType) videoType name:(NSString *)name
                                                path:(NSString*)path completion: (YGCExportFinished)finishedBlock NS_SWIFT_NAME(exportVideo(as:name:path:completion:));


-(void)previewVideoImageWithURL: (NSURL *) url maxSize:(CGSize) maxSize
                     completion: (YGCExportThumbnailFinished)finishedBlock NS_SWIFT_NAME(previews(url:size:completion:));
-(void)previewVideoImageWithURL: (NSURL *) url
                     completion: (YGCExportThumbnailFinished)finishedBlock NS_SWIFT_NAME(previews(url:completion:));

-(UIImage *)previewVideoImageWithURL: (NSURL *) url time: (CMTime) timeFrame  maxSize:(CGSize) maxSize
                               error:(NSError * _Nullable * _Nullable)outError NS_SWIFT_NAME(preview(url:time:size:error:));

-(UIImage *)previewVideoImageWithURL: (NSURL *) url  maxSize:(CGSize) maxSize
                               error:(NSError * _Nullable * _Nullable)outError  NS_SWIFT_NAME(preview(url:size:error:));
-(UIImage *)previewVideoImageWithURL: (NSURL *) url  maxSize:(CGSize) maxSize  NS_SWIFT_NAME(preview(url:size:));
@end
