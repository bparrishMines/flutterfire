import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/new/src/platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'interface.dart' as plugin_interface;

mixin ReferenceHolder {
  static int _nextReferenceId = 0;
  int _referenceId = _nextReferenceId++;
}

class BannerAd = plugin_interface.BannerAd with ReferenceHolder;
class InterstitialAd = plugin_interface.InterstitialAd with ReferenceHolder;
class NativeAd = plugin_interface.NativeAd with ReferenceHolder;
class RewardedAd = plugin_interface.RewardedAd with ReferenceHolder;

class MethodChannelPlatform extends FirebaseAdmobPlatform {
  static final MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_admob',
    StandardMethodCodec(FirebaseAdmobMessageCodec()),
  );

  final Map<int, plugin_interface.BaseAd> _loadedAds =
      <int, plugin_interface.BaseAd>{};

  @override
  FutureOr<void> initialize({String appId}) {
    return channel.invokeMethod<void>('initialize', appId);
  }

  @override
  FutureOr<void> loadFullscreenAd(plugin_interface.FullscreenAd ad) {
    final int referenceId = (ad as ReferenceHolder)._referenceId;
    if (_loadedAds.containsKey(referenceId)) return null;

    _loadedAds[referenceId] = ad;
    try {
      return channel.invokeMethod<void>('loadFullscreenAd', ad);
    } on PlatformException {
      _loadedAds.remove(referenceId);
      rethrow;
    }
  }

  @override
  FutureOr<Widget> loadWidgetAd(plugin_interface.WidgetAd ad) async {
    final int referenceId = (ad as ReferenceHolder)._referenceId;
    if (_loadedAds.containsKey(referenceId)) return null;

    _loadedAds[referenceId] = ad;
    try {
      await channel.invokeMethod<void>('loadWidgetAd', ad);
      return AdWidget(ad: ad);
    } on PlatformException {
      _loadedAds.remove(referenceId);
      rethrow;
    }
  }

  @override
  FutureOr<void> showFullscreenAd(plugin_interface.FullscreenAd ad) {
    final int referenceId = (ad as ReferenceHolder)._referenceId;
    assert(_loadedAds.containsKey(referenceId));

    try {
      return channel.invokeMethod<void>('showFullscreenAd', referenceId);
    } on PlatformException {
      _loadedAds.remove(referenceId);
      rethrow;
    }
  }

  @override
  FutureOr<void> disposeFullscreenAd(plugin_interface.FullscreenAd ad) {
    final int referenceId = (ad as ReferenceHolder)._referenceId;
    _loadedAds.remove(referenceId);

    return channel.invokeMethod<void>('disposeFullscreenAd', referenceId);
  }

  @override
  FutureOr<bool> isAdLoaded(plugin_interface.BaseAd ad) async {
    final int referenceId = (ad as ReferenceHolder)._referenceId;

    return _loadedAds.containsKey(referenceId) &&
        await channel.invokeMethod<bool>(
          'isAdLoaded',
          referenceId,
        );
  }
}

class AdWidget extends StatelessWidget {
  const AdWidget({Key key, this.ad}) : super(key: key);

  final plugin_interface.WidgetAd ad;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: 500,
      height: 500,
      child: Platform.isIOS
          ? UiKitView(
              viewType: '$BannerAd',
              creationParams: (ad as ReferenceHolder)._referenceId,
              creationParamsCodec: FirebaseAdmobMessageCodec(),
            )
          : null,
    );
  }
}

class FirebaseAdmobMessageCodec extends StandardMessageCodec {
  const FirebaseAdmobMessageCodec();

  static const int _valueAdEvent = 128;
  static const int _valueRewardedAdEvent = 129;
  static const int _valueAdTargetingInfo = 130;
  static const int _valueAdSize = 131;
  static const int _valueBannerAd = 132;
  static const int _valueInterstitialAd = 133;
  static const int _valueNativeAd = 134;
  static const int _valueRewardedAd = 135;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is plugin_interface.AdEvent) {
      buffer.putUint8(_valueAdEvent);
      writeValue(buffer, value.toString());
    } else if (value is plugin_interface.RewardedAdEvent) {
      buffer.putUint8(_valueRewardedAdEvent);
      writeValue(buffer, value.toString());
    } else if (value is plugin_interface.AdTargetingInfo) {
      buffer.putUint8(_valueAdTargetingInfo);
      writeValue(buffer, value.childDirected);
      writeValue(buffer, value.contentUrl);
      writeValue(buffer, value.keywords);
      writeValue(buffer, value.nonPersonalizedAds);
      writeValue(buffer, value.testDevices);
    } else if (value is plugin_interface.AdSize) {
      buffer.putUint8(_valueAdSize);
      writeValue(buffer, value.width);
      writeValue(buffer, value.height);
    } else if (value is BannerAd) {
      buffer.putUint8(_valueBannerAd);
      writeValue(buffer, value._referenceId);
      writeValue(buffer, value.adSize);
      writeBaseAd(buffer, value);
    } else if (value is InterstitialAd) {
      buffer.putUint8(_valueInterstitialAd);
      writeValue(buffer, value._referenceId);
      writeBaseAd(buffer, value);
    } else if (value is NativeAd) {
      buffer.putUint8(_valueNativeAd);
      writeValue(buffer, value._referenceId);
      writeValue(buffer, value.factoryId);
      writeValue(buffer, value.customOptions);
      writeBaseAd(buffer, value);
    } else if (value is RewardedAd) {
      buffer.putUint8(_valueRewardedAd);
      writeValue(buffer, value._referenceId);
      writeValue(buffer, value.userId);
      writeValue(buffer, value.customData);
      writeBaseAd(buffer, value);
    } else {
      super.writeValue(buffer, value);
    }
  }

  void writeBaseAd(WriteBuffer buffer, plugin_interface.BaseAd ad) {
    writeValue(buffer, ad.adUnitId);
    writeValue(buffer, ad.adTargetingInfo);
  }
}
