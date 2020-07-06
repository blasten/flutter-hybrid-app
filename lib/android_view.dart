// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'dart:typed_data';

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
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return controllerFactory(params, context);
      },
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return PlatformViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
    );
  }

  PlatformViewController controllerFactory(
      PlatformViewCreationParams params, BuildContext context) {
    final _AndroidViewController controller = _AndroidViewController(
      params.id,
      viewType,
      creationParams,
      creationParamsCodec,
      _findLayoutDirection(context),
    );
    controller._initialize().then((_) {
      params.onPlatformViewCreated(params.id);
    });
    return controller;
  }

  TextDirection _findLayoutDirection(BuildContext context) {
    assert(layoutDirection != null || debugCheckHasDirectionality(context));
    return layoutDirection ?? Directionality.of(context);
  }
}

// TODO(egarciad): The Android view controller should be defined in the framework.
// https://github.com/flutter/flutter/issues/55904
class _AndroidViewController extends PlatformViewController {
  _AndroidViewController(
    this.viewId,
    String viewType,
    dynamic creationParams,
    MessageCodec<dynamic> creationParamsCodec,
    TextDirection layoutDirection,
  )   : assert(viewId != null),
        assert(viewType != null),
        _viewType = viewType,
        _creationParams = creationParams,
        _creationParamsCodec = creationParamsCodec,
        _layoutDirection = layoutDirection;

  /// The unique identifier of the Android view controlled by this controller.
  @override
  final int viewId;

  /// The unique identifier for the Android view type to be embedded by this widget.
  ///
  /// A PlatformViewFactory for this type must have been registered.
  final String _viewType;

  /// The creation params can be used to pass values to the native factory.
  final dynamic _creationParams;

  final MessageCodec<dynamic> _creationParamsCodec;

  final TextDirection _layoutDirection;

  Future<void> _initialize() async {
    final Map<String, dynamic> args = <String, dynamic>{
      'id': viewId,
      'viewType': _viewType,
      'direction': _getAndroidDirection(_layoutDirection),
      'hybrid': true,
    };
    if (_creationParams != null) {
      final ByteData paramsByteData =
          _creationParamsCodec.encodeMessage(_creationParams);
      args['params'] = Uint8List.view(
        paramsByteData.buffer,
        0,
        paramsByteData.lengthInBytes,
      );
    }
    await SystemChannels.platform_views.invokeMethod('create', args);
  }

  @override
  Future<void> clearFocus() {
    // TODO: Implement clear focus.
  }

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) {
    // TODO: Implement dispatchPointerEvent
  }

  @override
  Future<void> dispose() {
    final Map<String, dynamic> args = <String, dynamic>{
      'id': viewId,
      'hybrid': true,
    };
    // TODO: dispose should be async.
    SystemChannels.platform_views.invokeMethod<void>('dispose', args);
  }

  /// Android's [View.LAYOUT_DIRECTION_LTR](https://developer.android.com/reference/android/view/View.html#LAYOUT_DIRECTION_LTR) value.
  static const int kAndroidLayoutDirectionLtr = 0;

  /// Android's [View.LAYOUT_DIRECTION_RTL](https://developer.android.com/reference/android/view/View.html#LAYOUT_DIRECTION_RTL) value.
  static const int kAndroidLayoutDirectionRtl = 1;

  static int _getAndroidDirection(TextDirection direction) {
    assert(direction != null);
    switch (direction) {
      case TextDirection.ltr:
        return kAndroidLayoutDirectionLtr;
      case TextDirection.rtl:
        return kAndroidLayoutDirectionRtl;
    }
    return null;
  }
}
