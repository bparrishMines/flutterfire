#import "FLTAd_Internal.h"

@interface ViewHelper : NSObject
@end

@implementation FLTAdSize
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height {
  self = [super init];
  if (self) {
    _adSize = GADAdSizeFromCGSize(CGSizeMake(width.doubleValue, height.doubleValue));
  }
  return self;
}
@end

@implementation FLTAdRequest
- (instancetype)init {
  self = [super init];
  if (self) {
    _request = [GADRequest request];
  }
  return self;
}
@end

@implementation FLTAnchorType {
  NSString *name;
}

- (instancetype)initWithName:(NSString *)name {
  self = [super init];
  if (self) {
    self->name = name;
  }
  return self;
}

+ (FLTAnchorType *)typeWithName:(NSString *)name {
  if ([FLTAnchorType.top->name isEqual:name]) {
    return FLTAnchorType.top;
  } else if ([FLTAnchorType.bottom->name isEqual:name]) {
    return FLTAnchorType.bottom;
  }
  return nil;
}

+ (FLTAnchorType *)top {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.top"];
}

+ (FLTAnchorType *)bottom {
  return [[FLTAnchorType alloc] initWithName:@"AnchorType.bottom"];
}

- (BOOL)isEqualToAnchorType:(FLTAnchorType *)type {
  return [name isEqual:type->name];
}
@end

@implementation ViewHelper
+ (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset
  anchorType:(FLTAnchorType *)anchorType
rootViewController:(UIViewController *)rootViewController
        view:(UIView *)view {
  UIView *parentView = rootViewController.view;
  [parentView addSubview:view];

  view.translatesAutoresizingMaskIntoConstraints = NO;

  if (@available(ios 11.0, *)) {
    [ViewHelper activateConstraintForView:view
                              layoutGuide:parentView.safeAreaLayoutGuide
                             anchorOffset:anchorOffset
                   horizontalCenterOffset:horizontalCenterOffset
                               anchorType:anchorType];
  } else if (@available(ios 9.0, *)) {
    [ViewHelper activateConstraintForView:view
               layoutGuide:parentView.layoutMarginsGuide
              anchorOffset:anchorOffset
    horizontalCenterOffset:horizontalCenterOffset
                anchorType:anchorType];
  } else {
    // TODO: Make work with offsets
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:rootViewController.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
  }
}

+ (void)activateConstraintForView:(UIView *)view
                      layoutGuide:(UILayoutGuide *)layoutGuide
                     anchorOffset:(NSNumber *)anchorOffset
           horizontalCenterOffset:(NSNumber *)horizontalCenterOffset
                       anchorType:(FLTAnchorType *)anchorType API_AVAILABLE(ios(9.0)) {
  view.translatesAutoresizingMaskIntoConstraints = NO;

  NSLayoutConstraint *verticalConstraint = nil;
  if ([anchorType isEqualToAnchorType:FLTAnchorType.bottom]) {
    verticalConstraint = [view.bottomAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor
                                                           constant:-anchorOffset.doubleValue];
  } else if ([anchorType isEqualToAnchorType:FLTAnchorType.top]) {
    verticalConstraint = [view.topAnchor constraintEqualToAnchor:layoutGuide.topAnchor
                                                        constant:anchorOffset.doubleValue];
  }

  [NSLayoutConstraint activateConstraints:@[
    verticalConstraint,
    [view.centerXAnchor constraintEqualToAnchor:layoutGuide.centerXAnchor
                                       constant:horizontalCenterOffset.doubleValue],
  ]];
}

+ (UIViewController *_Nonnull)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}
@end

@implementation FLTBannerAd {
  GADBannerView *_bannerView;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                         request:(FLTAdRequest *)request
                          adSize:(FLTAdSize *)adSize
                 callbackHandler:(id<FLTAdListenerCallbackHandler>)callbackHandler {
  self = [super init];
  if (self) {
    _request = request.request;
    _callbackHandler = callbackHandler;
    _bannerView = [[GADBannerView alloc] initWithAdSize:adSize.adSize];
    _bannerView.adUnitID = adUnitId;
    _bannerView.rootViewController = [ViewHelper rootViewController];
    _bannerView.delegate = self;
  }
  return self;
}

- (void)dispose {
  if (_bannerView.superview) [_bannerView removeFromSuperview];
}

- (void)load {
  [_bannerView loadRequest:_request];
}

- (UIView *)view {
  return _bannerView;
}

- (void)show:(NSNumber *)anchorOffset horizontalCenterOffset:(NSNumber *)horizontalCenterOffset anchorType:(FLTAnchorType *)anchorType {
  [self dispose];
  
  [ViewHelper show:anchorOffset horizontalCenterOffset:horizontalCenterOffset
        anchorType:anchorType rootViewController:[ViewHelper rootViewController]
              view:_bannerView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  [_callbackHandler onAdLoaded:self];
}
@end

@implementation FLTInterstitialAd {
  GADInterstitial *_interstitial;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler {
  self = [super init];
  if (self) {
    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:adUnitId];
    _interstitial.delegate = self;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_interstitial loadRequest:_request];
}

- (void)show {
  [_interstitial presentFromRootViewController:[ViewHelper rootViewController]];
}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  NSLog(@"interstitialDidReceiveAd");
  [_callbackHandler onAdLoaded:self];
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
    didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  NSLog(@"interstitialDidDismissScreen");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  NSLog(@"interstitialWillLeaveApplication");
}
@end

@implementation FLTNativeAd {
  GADAdLoader *_adLoader;
  GADUnifiedNativeAdView *_nativeAdView;
  NSDictionary<NSString *, id> *_customOptions;
  id<FLTNativeAdFactory> _nativeAdFactory;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          nativeAdFactory:(id<FLTNativeAdFactory> _Nonnull)nativeAdFactory
                            customOptions:(NSDictionary<NSString *, id> *_Nonnull)customOptions
                          callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler {
  if (self) {
    _adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                   rootViewController:[ViewHelper rootViewController]
                                              adTypes:@[kGADAdLoaderAdTypeUnifiedNative]
                                              options:@[]];
    _adLoader.delegate = self;
    _request = request.request;
    _nativeAdFactory = nativeAdFactory;
    _customOptions = customOptions;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_adLoader loadRequest:_request];
}

- (void)dispose {
  if ([_nativeAdView superview]) [_nativeAdView removeFromSuperview];
}

- (void)show:(NSNumber * _Nonnull)anchorOffset horizontalCenterOffset:(NSNumber * _Nonnull)horizontalCenterOffset
  anchorType:(FLTAnchorType * _Nonnull)anchorType {
  [self dispose];
  
  [ViewHelper show:anchorOffset horizontalCenterOffset:horizontalCenterOffset
        anchorType:anchorType rootViewController:[ViewHelper rootViewController]
              view:_nativeAdView];
}

- (nonnull UIView *)view {
  return _nativeAdView;
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
   _nativeAdView = [_nativeAdFactory createNativeAd:nativeAd customOptions:_customOptions];
   nativeAd.delegate = self;
   [_callbackHandler onAdLoaded:self];
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
  // The adLoader has finished loading ads, and a new request can be sent.
}
@end

@implementation FLTRewardedAd {
  GADRewardedAd *_rewardedAd;
  GADRequest *_request;
  __weak id<FLTAdListenerCallbackHandler> _callbackHandler;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          callbackHandler:(id<FLTAdListenerCallbackHandler>_Nonnull)callbackHandler {
  self = [super init];
  if (self) {
    _rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:adUnitId];
    _request = request.request;
    _callbackHandler = callbackHandler;
  }
  return self;
}

- (void)load {
  [_rewardedAd loadRequest:_request completionHandler:^(GADRequestError * _Nullable error) {
    if (!error) [self->_callbackHandler onAdLoaded:self];
  }];
}

- (void)show {
  [_rewardedAd presentFromRootViewController:[ViewHelper rootViewController] delegate:self];
}

/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
  // TODO: Reward the user.
  NSLog(@"rewardedAd:userDidEarnReward:");
}

/// Tells the delegate that the rewarded ad was presented.
- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
  NSLog(@"rewardedAdDidPresent:");
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
  NSLog(@"rewardedAd:didFailToPresentWithError");
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
  NSLog(@"rewardedAdDidDismiss:");
}
@end
