// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';

class _PicPicker extends StatefulWidget {
  _PicPicker({Key? key, this.width, this.height, this.quality, required this.setPic, this.initialImageURL})
      : super(key: key);

  final double? width;
  final double? height;
  final int? quality;
  final Function setPic; // set state in profile form
  final String? initialImageURL;

  @override
  _PicPickerState createState() => _PicPickerState();
}

class _PicPickerState extends State<_PicPicker> {
  XFile? _imageFile;

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source, {BuildContext? context}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: widget.width,
        maxHeight: widget.height,
        imageQuality: widget.quality,
      );
      if (mounted) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
      if (_imageFile != null) {
        widget.setPic(File(_imageFile!.path));
      } else {
        widget.setPic(null);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Semantics(
        label: 'new_profile_pic_picked_image',
        child: kIsWeb ? Image.network(_imageFile!.path) : Image.file(File(_imageFile!.path)),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else if (widget.initialImageURL != null) {
      return Image.network(widget.initialImageURL!);
    } else {
      return const Text(
        'Pick an image?',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  // in effect for Android only
  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (mounted) {
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Loading();
                    case ConnectionState.done:
                      return _handlePreview();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _handlePreview(),
      ),
      Semantics(
        label: 'image_picker_example_from_gallery',
        child: FloatingActionButton(
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery, context: context);
          },
          heroTag: 'image0',
          tooltip: 'Pick Image from gallery',
          child: const Icon(Icons.photo),
        ),
      ),
    ]);
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

typedef void OnPickImageCallback(double? maxWidth, double? maxHeight, int? quality);
