#import <Foundation/Foundation.h>
#import "FAMethodCallHandler.h"

@interface FAPlatform ()
@property NSMutableDictionary<NSNumber *, id<FABaseAd>> *loadedAds;
- (BOOL)addLoadedAd:(id<FABaseAd>)ad;
- (id<FABaseAd>)removeLoadedAd:(NSNumber *)referenceId;
@end

@interface FAReaderWriter : FlutterStandardReaderWriter
@property FAAdEventCallbackHandler *adEventHandler;
@end

@interface FAReader : FlutterStandardReader
@property FAAdEventCallbackHandler *adEventHandler;
- (instancetype)initWithData:(NSData *)data
              adEventHandler:(FAAdEventCallbackHandler *)adEventHandler;
@end

@interface FAWriter : FlutterStandardWriter
@end

@implementation FAPlatform
- (instancetype)initWithCallbackChannel:(FAMethodChannel *)callbackChannel {
  self = [super init];
  if (self) {
    _loadedAds = [NSMutableDictionary dictionary];
    _callbackChannel = callbackChannel;
  }
  return self;
}

- (BOOL)addLoadedAd:(id<FABaseAd>)ad {
  if (_loadedAds[ad.referenceId]) return NO;
  _loadedAds[ad.referenceId] = ad;
  return YES;
}

- (id<FABaseAd>)removeLoadedAd:(NSNumber *)referenceId {
  NSObject<FABaseAd> *removedAd = _loadedAds[referenceId];
  [_loadedAds removeObjectForKey:referenceId];
  return removedAd;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initialize" isEqualToString:call.method]) {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    result(nil);
  } else if ([@"loadWidgetAd" isEqualToString:call.method]) {
    id<FABaseAd> ad = call.arguments;
    [ad load];
    result(nil);
  } else if ([@"isAdLoaded" isEqualToString:call.method]) {
    id<FABaseAd> ad = _loadedAds[call.arguments];
    BOOL isAdLoaded = ad && ad.isLoaded;
    result(@(isAdLoaded));
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end

@implementation FAMethodChannel
- (instancetype)initWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  FAReaderWriter *readerWriter = [[FAReaderWriter alloc] init];
  self = [self initWithName:name
            binaryMessenger:messenger
                      codec:[FlutterStandardMethodCodec codecWithReaderWriter:readerWriter]];
  
  FAAdEventCallbackHandler *adEventHandler = [[FAAdEventCallbackHandler alloc]
                                              initWithCallbackChannel:self];
  readerWriter.adEventHandler = adEventHandler;
  
  return self;
}
@end

const UInt8 AD_EVENT = 128;
const UInt8 REWARDED_AD_EVENT = 129;
const UInt8 AD_TARGETING_INFO = 130;
const UInt8 AD_SIZE = 131;
const UInt8 BANNER_AD = 132;
const UInt8 INTERSTITIAL_AD = 133;
const UInt8 NATIVE_AD = 134;
const UInt8 REWARDED_AD = 135;
const UInt8 AD_EVENT_CALLBACK = 136;

@implementation FAReaderWriter
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FAReader alloc] initWithData:data adEventHandler:_adEventHandler];
}

- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FAWriter alloc] initWithData:data];
}
@end

@implementation FAReader
- (instancetype)initWithData:(NSData *)data
              adEventHandler:(FAAdEventCallbackHandler *)adEventHandler {
  self = [self initWithData:data];
  if (self) {
    _adEventHandler = adEventHandler;
  }
  return self;
}

- (id)readValueOfType:(UInt8)type {
  switch(type) {
    case AD_TARGETING_INFO:
      return nil;
    case AD_SIZE:
      return [[FAAdSize alloc] initWithWidth:[self readValueOfType:type]
                                      height:[self readValueOfType:type]];
    case BANNER_AD:
      return [[FABannerAd alloc] initWithReferenceId:[self readValueOfType:type]
                                              adSize:[self readValueOfType:type]
                                            adUnitId:[self readValueOfType:type]
                                       targetingInfo:[self readValueOfType:type]
                              adEventCallbackHandler:_adEventHandler];
    case NATIVE_AD:
      return nil;
    case REWARDED_AD:
      return nil;
  }
  
  return [super readValueOfType:type];
}
@end

@implementation FAWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[FAAdEvent class]]) {
    [self writeByte:AD_EVENT];
    [self writeValue:[value name]];
  } else if ([value isKindOfClass:[FAAdEventCallback class]]) {
    [self writeByte:AD_EVENT_CALLBACK];
    [self writeValue:[value referenceId]];
    [self writeValue:[value adEvent]];
  }  else {
    [super writeValue:value];
  }
}
@end
