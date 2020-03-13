#import <Flutter/Flutter.h>
#import "FAFirebaseAdMobInterface.h"
#import "Firebase/Firebase.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@interface FAMethodChannel : FlutterMethodChannel
- (instancetype)initWithName:(NSString *)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;
@end

@interface FAPlatform : NSObject
@property FAMethodChannel *callbackChannel;
- (instancetype)initWithCallbackChannel:(FAMethodChannel *)callbackChannel;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@end

@interface FAViewFactory : NSObject<FlutterPlatformViewFactory>
- (instancetype)initWithPlatform:(FAPlatform *)platform;
@end
