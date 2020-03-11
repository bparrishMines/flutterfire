import 'dart:async';

import 'package:firebase_admob/new/src/method_channel_platform.dart'
    as mc_platform;
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'interface.dart';

class FirebaseAdmobPlatform extends PlatformInterface {
  FirebaseAdmobPlatform() : super(token: _token);

  static FirebaseAdmobPlatform _instance = mc_platform.MethodChannelPlatform();

  static final Object _token = Object();

  static FirebaseAdmobPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FirebaseAdmobPlatform] when they register themselves.
  static set instance(FirebaseAdmobPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  FutureOr<void> initialize({String appId}) {
    throw UnimplementedError();
  }

  FutureOr<void> loadFullscreenAd(FullscreenAd ad) {
    throw UnimplementedError();
  }

  FutureOr<Widget> loadWidgetAd(WidgetAd ad) {
    throw UnimplementedError();
  }

  FutureOr<void> showFullscreenAd(FullscreenAd ad) {
    throw UnimplementedError();
  }

  FutureOr<void> disposeFullscreenAd(FullscreenAd ad) {
    throw UnimplementedError();
  }

  FutureOr<bool> isAdLoaded(BaseAd ad) {
    throw UnimplementedError();
  }

  @mustCallSuper
  void onAdEvent(BaseAd ad, AdEvent event) {
    assert(ad is BannerAd || ad is InterstitialAd || ad is NativeAd);
    final AdEventCallback callback = (ad as dynamic).onAdEvent;
    if (callback != null) callback(event);
  }

  @mustCallSuper
  void onRewardedAdEvent(RewardedAd ad, RewardedAdEvent event) {
    final RewardedAdEventCallback callback = ad.onAdEvent;
    if (callback != null) callback(event);
  }
}
