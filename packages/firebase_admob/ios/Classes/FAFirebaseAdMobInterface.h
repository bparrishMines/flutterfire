#import <Flutter/Flutter.h>
#import "Firebase/Firebase.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@interface FAAdEvent : NSObject
@property NSString *name;
+ (FAAdEvent *)loaded;
+ (FAAdEvent *)failedToLoad;
+ (FAAdEvent *)clicked;
+ (FAAdEvent *)impression;
+ (FAAdEvent *)opened;
+ (FAAdEvent *)leftApplication;
+ (FAAdEvent *)closed;
@end

@interface FAAdEventCallback : NSObject
@property NSNumber *referenceId;
@property FAAdEvent *adEvent;
- (instancetype)initWithReferenceId:(NSNumber *)referenceId adEvent:(FAAdEvent *)adEvent;
@end

@interface FAAdEventCallbackHandler : NSObject
@property FlutterMethodChannel *callbackChannel;
- (instancetype)initWithCallbackChannel:(FlutterMethodChannel *)callbackChannel;
@end

@interface FAAdTargetingInfo : NSObject
@property BOOL childDirected;
@property NSString *contentUrl;
@property NSArray<NSString *> *keywords;
@property BOOL nonPersonalizedAds;
@property NSArray<NSString *> *testDevices;
- (instancetype)initWithChildDirected:(BOOL)childDirected
                           contentUrl:(NSString *)contentUrl
                             keywords:(NSArray<NSString *> *)keywords
                   nonPersonalizedAds:(BOOL)nonPersonalizedAds
                          testDevices:(NSArray<NSString *> *)testDevices;
@end

@interface FAAdSize : NSObject
@property NSNumber *width;
@property NSNumber *height;
@property GADAdSize adSize;
- (instancetype)initWithWidth:(NSNumber *)width height:(NSNumber *)height;
@end

@protocol FABaseAd <NSObject>
@property NSNumber *referenceId;
@property NSString *adUnitId;
@property FAAdTargetingInfo *targetingInfo;
@required
- (void)load;
- (BOOL)isLoaded;
@end

@interface FABannerAd : NSObject<FABaseAd, GADBannerViewDelegate>
@property FAAdSize *adSize;
@property GADBannerView *bannerView;
@property FAAdEventCallbackHandler adEventHandler;
- (instancetype)initWithReferenceId:(NSNumber *)referenceId
                             adSize:(FAAdSize *)adSize
                           adUnitId:(NSString *)adUnitId
                      targetingInfo:(FAAdTargetingInfo *)targetingInfo
             adEventCallbackHandler:(FAAdEventCallbackHandler *)adEventCallbackHandler;
@end
