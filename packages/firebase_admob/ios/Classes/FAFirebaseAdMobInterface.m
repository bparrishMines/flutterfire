#import <Foundation/Foundation.h>
#import "FAFirebaseAdMobInterface.h"

@implementation FAAdEvent : NSObject
- (instancetype)initWithName:(NSString *)name {
  self = [super init];
  if (self) {
    _name = name;
  }
  return self;
}

+ (FAAdEvent *)loaded {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.loaded"];
}

+ (FAAdEvent *)failedToLoad {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.failedToLoad"];
}

+ (FAAdEvent *)clicked {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.clicked"];
}

+ (FAAdEvent *)impression {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.impression"];
}

+ (FAAdEvent *)opened {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.opened"];
}

+ (FAAdEvent *)leftApplication {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.leftApplication"];
}

+ (FAAdEvent *)closed {
  return [[FAAdEvent alloc] initWithName:@"AdEvent.closed"];
}
@end

@implementation FAAdEventCallback
- (instancetype)initWithReferenceId:(NSNumber *)referenceId adEvent:(FAAdEvent *)adEvent {
  self = [super self];
  if (self) {
    _referenceId = referenceId;
    _adEvent = adEvent;
  }
  return self;
}
@end

@implementation FAAdEventCallbackHandler
- (instancetype)initWithCallbackChannel:(FlutterMethodChannel *)callbackChannel {
  self = [super self];
  if (self) {
    _callbackChannel = callbackChannel;
  }
  return self;
}

- (void)onLoaded:(NSNumber *)referenceId {
  [self invokeMethodWithReferenceId:referenceId adEvent:FAAdEvent.loaded];
}

- (void)onFailedToLoad:(NSNumber *)referenceId {
  [self invokeMethodWithReferenceId:referenceId adEvent:FAAdEvent.failedToLoad];
}

- (void)invokeMethodWithReferenceId:(NSNumber *)referenceId adEvent:(FAAdEvent *)adEvent {
  [_callbackChannel invokeMethod:adEvent.name
                       arguments:[[FAAdEventCallback alloc] initWithReferenceId:referenceId
                                                                        adEvent:adEvent]];
}
@end

@implementation FAAdTargetingInfo
- (instancetype)initWithChildDirected:(BOOL)childDirected
                           contentUrl:(NSString *)contentUrl
                             keywords:(NSArray<NSString *> *)keywords
                   nonPersonalizedAds:(BOOL)nonPersonalizedAds
                          testDevices:(NSArray<NSString *> *)testDevices {
  self = [super init];
  if (self) {
    _childDirected = childDirected;
    _contentUrl = contentUrl;
    _keywords = keywords;
    _nonPersonalizedAds = nonPersonalizedAds;
    _testDevices = testDevices;
  }
  return self;
}
@end

@implementation FAAdSize
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height {
  self = [super init];
  if (self) {
    _width = width;
    _height = height;
    _adSize = GADAdSizeFromCGSize(CGSizeMake(width.floatValue, height.floatValue));
  }
  return self;
}
@end

@implementation FABannerAd {
  BOOL isLoaded;
}

@synthesize adUnitId;
@synthesize targetingInfo;
@synthesize referenceId;
- (instancetype)initWithReferenceId:(NSNumber *)referenceId
                             adSize:(FAAdSize *)adSize
                           adUnitId:(NSString *)adUnitId
                      targetingInfo:(FAAdTargetingInfo *)targetingInfo
             adEventCallbackHandler:(FAAdEventCallbackHandler *)adEventCallbackHandler {
  self = [super init];
  if (self) {
    self.referenceId = referenceId;
    self.adUnitId = adUnitId;
    self.targetingInfo = targetingInfo;
    _adSize = adSize;
    _adEventHandler = adEventCallbackHandler;
    self->isLoaded = NO;
  }
  return self;
}

- (void)load {
  _bannerView = [[GADBannerView alloc] initWithAdSize:_adSize.adSize];
  _bannerView.delegate = self;
  _bannerView.adUnitID = adUnitId;
  _bannerView.rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  [_bannerView loadRequest:[GADRequest request]];
}

- (BOOL)isLoaded {
  return isLoaded;
}

- (UIView*)view {
  return _bannerView;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  isLoaded = YES;
  [_adEventHandler onLoaded:referenceId];
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
  [_adEventHandler onFailedToLoad:referenceId];
  NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
  NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
  NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
  NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
  NSLog(@"adViewWillLeaveApplication");
}
@end
