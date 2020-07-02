// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AndroidPlatformView extends StatelessWidget {
  /// Creates a platform view for Android, which is rendered as a
  /// native view.
  const AndroidPlatformView({
    Key key,
    @required this.viewType,
    this.layoutDirection,
    this.creationParams,
    this.creationParamsCodec,
  })  : assert(viewType != null),
        super(key: key);

  /// The unique identifier for the view type to be embedded by this widget.
  ///
  /// A PlatformViewFactory for this type must have been registered.
  final String viewType;

  /// {@template flutter.widgets.platformViews.directionParam}
  /// The text direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead.
  /// {@endtemplate}
  final TextDirection layoutDirection;

  /// Passed as the args argument of [PlatformViewFactory#create](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html#create-android.content.Context-int-java.lang.Object-)
  ///
  /// This can be used by plugins to pass constructor parameters to the embedded Android view.
  final dynamic creationParams;

  /// The codec used to encode `creationParams` before sending it to the
  /// platform side. It should match the codec passed to the constructor of [PlatformViewFactory](/javadoc/io/flutter/plugin/platform/PlatformViewFactory.html#PlatformViewFactory-io.flutter.plugin.common.MessageCodec-).
  ///
  /// This is typically one of: [StandardMessageCodec], [JSONMessageCodec], [StringCodec], or [BinaryCodec].
  ///
  /// This must not be null if [creationParams] is not null.
  final MessageCodec<dynamic> creationParamsCodec;

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller,
          gestureRecognizers: [
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet(),
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: StandardMessageCodec(),
        )..addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
      },
    );
  }
}
