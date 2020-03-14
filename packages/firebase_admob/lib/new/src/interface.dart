import 'dart:async';

import 'package:firebase_admob/new/src/platform_interface.dart';
import 'package:flutter/widgets.dart';

typedef AdEventCallback = void Function(AdEvent event);
typedef RewardedAdEventCallback = void Function(
  RewardedAdEvent event, {
  String rewardType,
  int rewardAmount,
});

class FirebaseAdMob {
  FirebaseAdMob._();

  static final FirebaseAdMob instance = FirebaseAdMob._();

  Future<void> initialize({String appId}) {
    return FirebaseAdmobPlatform.instance.initialize(appId: appId);
  }
}

enum AdEvent {
  loaded,
  failedToLoad,
  clicked,
  impression,
  opened,
  leftApplication,
  closed,
}

enum RewardedAdEvent {
  loaded,
  failedToLoad,
  opened,
  leftApplication,
  closed,
  rewarded,
  started,
  completed,
}

class RewardedAd extends FullscreenAd {
  RewardedAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
    this.userId,
    this.customData,
    this.onAdEvent,
  }) : super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  final String userId;
  final String customData;
  final RewardedAdEventCallback onAdEvent;
}

class InterstitialAd extends FullscreenAd {
  InterstitialAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
    this.onAdEvent,
  }) : super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  final AdEventCallback onAdEvent;
}

abstract class BannerAd extends WidgetAd {
  BannerAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
    this.adSize,
    this.onAdEvent,
  })  : assert(adSize != null),
        super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  final AdSize adSize;
  final AdEventCallback onAdEvent;
}

abstract class NativeAd extends WidgetAd {
  NativeAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
    @required this.factoryId,
    this.customOptions,
    this.onAdEvent,
  })  : assert(factoryId != null),
        super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  final String factoryId;
  final Map<String, dynamic> customOptions;
  final AdEventCallback onAdEvent;
}

abstract class BaseAd {
  BaseAd({@required this.adUnitId, this.adTargetingInfo})
      : assert(adUnitId != null);

  final String adUnitId;
  final AdTargetingInfo adTargetingInfo;

  Future<bool> isLoaded() {
    return FirebaseAdmobPlatform.instance.isAdLoaded(this);
  }
}

abstract class WidgetAd extends BaseAd {
  WidgetAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
  }) : super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  Future<Widget> load() {
    return FirebaseAdmobPlatform.instance.loadWidgetAd(this);
  }
}

abstract class FullscreenAd extends BaseAd {
  FullscreenAd({
    @required String adUnitId,
    AdTargetingInfo adTargetingInfo,
  }) : super(
          adUnitId: adUnitId,
          adTargetingInfo: adTargetingInfo,
        );

  Future<void> load() {
    return FirebaseAdmobPlatform.instance.loadFullscreenAd(this);
  }

  Future<void> show() {
    return FirebaseAdmobPlatform.instance.showFullscreenAd(this);
  }

  Future<void> dispose() {
    return FirebaseAdmobPlatform.instance.disposeFullscreenAd(this);
  }
}

class AdTargetingInfo {
  AdTargetingInfo({
    this.childDirected,
    this.contentUrl,
    this.keywords,
    this.nonPersonalizedAds,
    this.testDevices,
  });

  final bool childDirected;
  final String contentUrl;
  final List<String> keywords;
  final bool nonPersonalizedAds;
  final List<String> testDevices;
}

class AdSize {
  AdSize._(this.width, this.height);

  final int width;
  final int height;

  static final AdSize banner = AdSize._(320, 50);
}
