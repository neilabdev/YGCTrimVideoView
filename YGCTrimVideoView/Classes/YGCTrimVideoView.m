//
//  YGCTrimVideoView.m
//  VideoTrimView
//
//  Created by Qilong Zang on 30/01/2018.
//  Copyright © 2018 Qilong Zang. All rights reserved.
//

#import "YGCTrimVideoView.h"
#import "YGCTrimVideoControlView.h"
#import "YGCThumbCollectionViewCell.h"
#import "UIView+YGCFrameUtil.h"

//static NSInteger const kMaxThumbCount = 30;
static CGFloat const kDefaultSidebarWidth = 12;
static CGFloat const kDefaultMaxSeconds = 10;
static CGFloat const kDefaultMinSeconds = 2;
static NSString * const kCellIdentifier = @"YGCThumbCollectionViewCell";

@interface YGCTrimVideoView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, YGCTrimVideoControlViewDelegate>
{
    CMTime _startTime;
    CMTime _endTime;
}

@property (nonatomic, strong) UICollectionView *thumbCollectionView;
@property (nonatomic, strong) YGCTrimVideoControlView *controlView;
@property (nonatomic, assign) CGFloat controlInset;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray<UIImage *> *thumbImageArray;
@property (nonatomic, strong) NSMutableArray<NSValue *> *timeArray;
@property (nonatomic, assign) CGFloat sidebarWidth;

@end

@implementation YGCTrimVideoView

- (id)initWithFrame:(CGRect)frame
            assetURL:(NSURL *)url
{
    return [self initWithFrame:frame
                       assetURL:url
              leftSidebarImage:nil
             rightSidebarImage:nil
              centerRangeImage:nil
                  sidebarWidth:kDefaultSidebarWidth
              controlViewInset:20];
}


- (id)initWithFrame:(CGRect)frame
            assetURL:(NSURL *)url
   leftSidebarImage:(UIImage *)leftImage
  rightSidebarImage:(UIImage *)rightImage
   centerRangeImage:(UIImage *)centerImage
       sidebarWidth:(CGFloat)width
   controlViewInset:(CGFloat)inset
{
    if (self = [super initWithFrame:frame]) {
        _startTime = kCMTimeZero;
        _endTime = kCMTimeZero;
        _asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        _currentAsset = self.asset;
        _controlInset = inset;
        _leftSidebarImage = leftImage;
        _rightSidebarImage = rightImage;
        _centerRangeImage = centerImage;
        _sidebarWidth = width;
        _exportType = AVFileTypeQuickTimeMovie;
        self.thumbImageArray = [NSMutableArray array];
        self.timeArray = [NSMutableArray array];
        _maxSeconds = kDefaultMaxSeconds;
        _minSeconds = kDefaultMinSeconds;
        [self commonInit];
        [self generateVideoThumb];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(!CGRectEqualToRect(self.thumbCollectionView.frame, self.bounds)) {
        self.thumbCollectionView.frame = self.bounds;
        self.controlView.frame = CGRectInset(self.bounds, self.controlInset, 0);
        [self generateVideoThumb];
    }
}


- (void)commonInit {
    [self addSubview:self.thumbCollectionView];
    [self addSubview:self.controlView];
    [self.thumbCollectionView registerClass:[YGCThumbCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self setNeedsLayout];
}

- (NSTimeInterval)pixelSeconds {
    return [self acturalMaxSecons]/self.controlView.ygc_width;
}

- (NSTimeInterval)cellTime {
    return [self pixelSeconds] * [self cellWidth];
}

- (CGFloat)cellWidth {
    return self.controlView.ygc_width/10;
}

- (CGFloat)acturalMaxSecons {
    NSTimeInterval duration = CMTimeGetSeconds(self.asset.duration);
    if (duration < self.maxSeconds) {
        return duration;
    }else {
        return self.maxSeconds;
    }
    
}

#pragma mark - Getter

- (YGCTrimVideoControlView *)controlView {
    if (_controlView == nil) {
        _controlView = [[YGCTrimVideoControlView alloc] initWithFrame:CGRectInset(self.bounds, self.controlInset, 0) leftControlImage:self.leftSidebarImage rightControlImage:self.rightSidebarImage centerRangeImage:self.centerRangeImage sideBarWidth:self.sidebarWidth];
        _controlView.delegate = self;
        _controlView.tag = 42;
        //_controlView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _controlView;
}

- (UICollectionView *)thumbCollectionView {
    if (_thumbCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _thumbCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _thumbCollectionView.delegate = self;
        _thumbCollectionView.dataSource = self;
        //_thumbCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _thumbCollectionView.tag = 77;
    }
    return _thumbCollectionView;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (_imageGenerator == nil) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        _imageGenerator.maximumSize = CGSizeMake(80, 80);
        _imageGenerator.appliesPreferredTrackTransform = YES;
    }
    return _imageGenerator;
}

#pragma mark - Setter

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    self.controlView.maskColor = _maskColor;
}

- (void)setMinSeconds:(NSTimeInterval)minSeconds {

    if(minSeconds!= _minSeconds) {
        _minSeconds = minSeconds;
        self.controlView.mininumTimeWidth = _minSeconds / [self pixelSeconds];
        [self setNeedsLayout];
    }
}

- (void)setMaxSeconds:(NSTimeInterval)maxSeconds {
    if(_maxSeconds != maxSeconds) {
        _maxSeconds = maxSeconds;
        [self setNeedsLayout];
    }
}


- (void)setSidebarWidth:(CGFloat)sidebarWidth {
    _sidebarWidth = sidebarWidth;
    [self setNeedsLayout];
}

- (void)setLeftSidebarImage:(UIImage *)leftSidebarImage {
    _leftSidebarImage = leftSidebarImage;
    [self.controlView resetLeftSideBarImage:leftSidebarImage];
}

- (void)setRightSidebarImage:(UIImage *)rightSidebarImage {
    _rightSidebarImage = rightSidebarImage;
    [self.controlView resetRightSideBarImage:rightSidebarImage];
}

- (void)setCenterRangeImage:(UIImage *)centerRangeImage {
    _centerRangeImage = centerRangeImage;
    [self.controlView resetCenterRangeImage:centerRangeImage];
}

#pragma mark - CollectionView DataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YGCThumbCollectionViewCell *thumbCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    thumbCell.thumbImageView.image = self.thumbImageArray[indexPath.row];
    return thumbCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbImageArray.count;
}

#pragma mark - CollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.cellWidth, self.ygc_height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, self.controlInset, 0, self.controlInset);
}

#pragma mark - ScrollView Delegate

// stackoverflow:https://stackoverflow.com/questions/993280/how-to-detect-when-a-uiscrollview-has-finished-scrolling
-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:sender afterDelay:0.3];
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self refreshVideoTime:[self.controlView leftBarFrame] rightFrmae:[self.controlView rightBarFrame]];
    _currentAsset = [self trimVideo];
    if ([self.delegate respondsToSelector:@selector(dragActionEnded:)]) {
        [self.delegate dragActionEnded:self.currentAsset];
    }
}

#pragma mark - Trim ControlView Delegate

- (void)leftSideBarChangedFrame:(CGRect)leftFrame rightBarCurrentFrame:(CGRect)rightFrame {

    [self refreshVideoTime:leftFrame rightFrmae:rightFrame];
    if ([self.delegate respondsToSelector:@selector(videoBeginTimeChanged:)]) {
        [self.delegate videoBeginTimeChanged:_startTime];
    }
}

- (void)rightSideBarChangedFrame:(CGRect)rightFrame leftBarCurrentFrame:(CGRect)leftFrame {
    [self refreshVideoTime:leftFrame rightFrmae:rightFrame];
    if ([self.delegate respondsToSelector:@selector(videoEndTimeChanged:)]) {
        [self.delegate videoEndTimeChanged:_endTime];
    }
}

- (void)panGestureEnded:(CGRect)leftFrame rightFrame:(CGRect)rightFrame {
    [self refreshVideoTime:leftFrame rightFrmae:rightFrame];
    _currentAsset = [self trimVideo];
    if ([self.delegate respondsToSelector:@selector(dragActionEnded:)]) {
        [self.delegate dragActionEnded:self.currentAsset];
    }
}

#pragma mark - Private Method

- (void)refreshVideoTime:(CGRect)leftFrame rightFrmae:(CGRect)rightFrame {
    CGRect convertLeftBarRect = [self.controlView convertRect:leftFrame toView:self];
    CGRect convertRightBarRect = [self.controlView convertRect:rightFrame toView:self];
    CGFloat leftPosition = self.thumbCollectionView.contentOffset.x + convertLeftBarRect.origin.x - self.controlInset;
    CGFloat rightPosition = self.thumbCollectionView.contentOffset.x + CGRectGetMaxX(convertRightBarRect) - self.controlInset;
    CGFloat startSec = leftPosition * [self pixelSeconds];
    CGFloat endSec = rightPosition * [self pixelSeconds];
    _startTime = CMTimeMakeWithSeconds(startSec, self.asset.duration.timescale);
    _endTime = CMTimeMakeWithSeconds(endSec, self.asset.duration.timescale);
}

- (void)generateVideoThumb {
    CMTimeScale timeScale = self.asset.duration.timescale;

    self.controlView.mininumTimeWidth = self.minSeconds/[self pixelSeconds];
    NSInteger thumbNumber = CMTimeGetSeconds(self.asset.duration)/[self cellTime];

    [self.timeArray removeAllObjects];

    for (int i = 0; i<thumbNumber; i++) {
        CMTime time = CMTimeMakeWithSeconds([self cellTime] * i, timeScale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [self.timeArray addObject:value];
    }

    if([self.thumbImageArray count] > 0) { //If called to re-layout, just adjust cells widths via time
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.thumbCollectionView reloadData];
        });
    } else { // initial load
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:self.timeArray completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            if (error == nil && result == AVAssetImageGeneratorSucceeded) {
                [self.thumbImageArray addObject:[UIImage imageWithCGImage:image]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.thumbCollectionView reloadData];
                });
            }
        }];
    }
}

- (AVMutableComposition *)trimVideo {
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    AVURLAsset *asset = self.asset;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }

    // avoid user doesn't drag control bar
    if (CMTimeCompare(_startTime, kCMTimeZero) == 0 &&
        CMTimeCompare(_startTime, kCMTimeZero) == 0)
    {
        _endTime = CMTimeMakeWithSeconds([self acturalMaxSecons], self.asset.duration.timescale);
    }
    
    CMTimeRange cutRange = CMTimeRangeMake(_startTime, _endTime);
    NSError *error = nil;

    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    // Insert half time range of the video and audio tracks from AVAsset
    if(assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:cutRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
        [compositionVideoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    }
    if(assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:cutRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    }

    CMTime acturalDuraton = CMTimeSubtract(_endTime, _startTime);
    [mutableComposition removeTimeRange:CMTimeRangeMake(acturalDuraton, mutableComposition.duration)];
    return mutableComposition;
}

#pragma mark - Export



- ( AVAssetExportSession * _Nonnull )exportVideoType: (AVFileType) videoType name:(NSString *)name  completion: (YGCExportFinished)finishedBlock {
    AVMutableComposition *asset = [self trimVideo];
    NSString *tmpFile = [NSString stringWithFormat:@"%@_%@", [self pathForTemporaryFileWithPrefix:@"trim"], name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpFile error:nil];
    }
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    session.outputURL = [NSURL fileURLWithPath:tmpFile];
    session.outputFileType =  videoType ;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            finishedBlock(YES, session.outputURL);
        }else {
            finishedBlock(NO, nil);
        }
    }];

    return session;
}



- ( AVAssetExportSession * _Nonnull )exportVideo:(YGCExportFinished)finishedBlock {
    return [self exportVideoType:AVFileTypeQuickTimeMovie name:@"output.mov" completion:finishedBlock];
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;

    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);

    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);

    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);

    CFRelease(uuidStr);
    CFRelease(uuid);

    return result;
}
@end
