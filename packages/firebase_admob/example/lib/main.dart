// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:firebase_admob/new/firebase_admob.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget bannerWidget;

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize();
    BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        adSize: AdSize.banner,
        onAdEvent: (AdEvent event) {
          print(event);
          if (event == AdEvent.loaded) setState(() {});
        }).load().then((widget) => bannerWidget = widget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admob example'),
      ),
      body: Container(
        color: Colors.green,
        constraints: BoxConstraints.expand(),
        alignment: Alignment.topCenter,
        child: bannerWidget == null ? Container() : bannerWidget,
      ),
    );
  }
}
