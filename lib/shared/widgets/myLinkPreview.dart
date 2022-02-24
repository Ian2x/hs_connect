import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that renders text with highlighted links.
/// Eventually unwraps to the full preview of the first found link
/// if the parsing was successful.
@immutable
class MyLinkPreview extends StatefulWidget {
  /// Creates [MyLinkPreview]
  const MyLinkPreview({
    Key? key,
    this.animationDuration,
    this.corsProxy,
    this.enableAnimation = false,
    this.header,
    this.headerStyle,
    this.hideImage,
    this.imageBuilder,
    this.linkStyle,
    this.metadataTextStyle,
    this.metadataTitleStyle,
    this.onLinkPressed,
    required this.onPreviewDataFetched,
    this.padding,
    required this.previewData,
    required this.text,
    this.textStyle,
    required this.width,
  }) : super(key: key);

  /// Expand animation duration
  final Duration? animationDuration;

  /// CORS proxy to make more previews work on web. Not tested.
  final String? corsProxy;

  /// Enables expand animation. Default value is false.
  final bool? enableAnimation;

  /// Custom header above provided text
  final String? header;

  /// Style of the custom header
  final TextStyle? headerStyle;

  /// Hides image data from the preview
  final bool? hideImage;

  /// Function that allows you to build a custom image
  final Widget Function(String)? imageBuilder;

  /// Style of highlighted links in the text
  final TextStyle? linkStyle;

  /// Style of preview's description
  final TextStyle? metadataTextStyle;

  /// Style of preview's title
  final TextStyle? metadataTitleStyle;

  /// Custom link press handler
  final void Function(String)? onLinkPressed;

  /// Callback which is called when [PreviewData] was successfully parsed.
  /// Use it to save [PreviewData] to the state and pass it back
  /// to the [MyLinkPreview.previewData] so the [MyLinkPreview] would not fetch
  /// preview data again.
  final void Function(PreviewData) onPreviewDataFetched;

  /// Padding around initial text widget
  final EdgeInsets? padding;

  /// Pass saved [PreviewData] here so [MyLinkPreview] would not fetch preview
  /// data again
  final PreviewData? previewData;

  /// Text used for parsing
  final String text;

  /// Style of the provided text
  final TextStyle? textStyle;

  /// Width of the [MyLinkPreview] widget
  final double width;

  @override
  _MyLinkPreviewState createState() => _MyLinkPreviewState();
}

class _MyLinkPreviewState extends State<MyLinkPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool isFetchingPreviewData = false;
  bool shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant MyLinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!isFetchingPreviewData && widget.previewData == null) {
      _fetchData(widget.text);
    }

    if (widget.previewData != null && oldWidget.previewData == null && mounted) {
      setState(() {
        shouldAnimate = true;
      });
      _controller.reset();
      _controller.forward();
    } else if (widget.previewData != null && mounted) {
      setState(() {
        shouldAnimate = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<PreviewData> _fetchData(String text) async {
    if (mounted) {
      setState(() {
        isFetchingPreviewData = true;
      });
    }

    final previewData = await getPreviewData(text, proxy: widget.corsProxy);
    _handlePreviewDataFetched(previewData);
    return previewData;
  }

  void _handlePreviewDataFetched(PreviewData previewData) async {
    await Future.delayed(
      widget.animationDuration ?? const Duration(milliseconds: 300),
    );

    if (mounted) {
      widget.onPreviewDataFetched(previewData);
      setState(() {
        isFetchingPreviewData = false;
      });
    }
  }

  bool _hasData(PreviewData? previewData) {
    return previewData?.title != null || previewData?.description != null || previewData?.image?.url != null;
  }

  /*bool _hasOnlyImage() {
    return widget.previewData?.title == null &&
        widget.previewData?.description == null &&
        widget.previewData?.image?.url != null;
  }*/

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    }
  }

  Widget _animated(Widget child) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (_, child) => ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: _animation.value,
                widthFactor: null,
                child: child,
              ),
            ),
        child: child);
  }

  Widget _bodyWidget(PreviewData data, String text, double width) {
    return Column(
      children: <Widget>[
        if (data.title != null) _titleWidget(data.title!),
        if (data.description != null && data.title != data.description) _descriptionWidget(data.description!, true),
        if (data.image?.url != null && widget.hideImage != true) _imageWidget(data.image!.url, width),
        _linkify(true),
      ],
    );
  }

  Widget _containerWidget({
    required bool animate,
    bool isMinimized = false,
    Widget? child,
  }) {
    final shouldAnimate = widget.enableAnimation == true && animate;

    return GestureDetector(
      onTap: () async {
        if (await canLaunch(widget.text)) {
          await launch(widget.text);
        }
      },
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(width: 1, color: Theme.of(context).colorScheme.onError)),
        padding: isMinimized ? null : EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            if (widget.header != null)
              Text(
                widget.header!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.headerStyle,
              ),
            if (child != null) shouldAnimate ? _animated(child) : child,
          ],
        ),
      ),
    );
  }

  Widget _descriptionWidget(String description, bool withBottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, withBottomPadding ? 10 : 3),
      child: Text(
        description + "idk some more text to boost this length to two lines",
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: widget.metadataTextStyle,
      ),
    );
  }

  Widget _imageWidget(String url, double width) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: width,
      ),
      color: Colors.black,
      width: width,
      child: widget.imageBuilder != null
          ? widget.imageBuilder!(url)
          : Image.network(
              url,
              fit: BoxFit.contain,
            ),
    );
  }

  Widget _linkify(bool withTopPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, withTopPadding ? 10 : 0, 10, 0),
      child: !isFetchingPreviewData
          ? SelectableLinkify(
              linkifiers: [const EmailLinkifier(), UrlLinkifier()],
              linkStyle: widget.linkStyle,
              maxLines: 1,
              minLines: 1,
              onOpen: widget.onLinkPressed != null ? (element) => widget.onLinkPressed!(element.url) : _onOpen,
              options: const LinkifyOptions(
                defaultToHttps: true,
                humanize: true,
                looseUrl: true,
              ),
              text: Uri.parse(widget.text).host,
              style: widget.textStyle?.copyWith(overflow: TextOverflow.ellipsis),
              textAlign: TextAlign.center,
            )
          : Text(widget.text, style: widget.textStyle),
    );
  }

  Widget _minimizedBodyWidget(PreviewData data, String text) {
    return Row(
      children: [
        if (data.image?.url != null && widget.hideImage != true)
          Container(height: 120, width: 120, child: _minimizedImageWidget(data.image!.url)),
        Expanded(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (data.title != null) _titleWidget(data.title!),
                if (data.description != null && data.title != data.description)
                  _descriptionWidget(data.description!, false),
                _linkify(false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _minimizedImageWidget(String url) {
    return FittedBox(
      fit: BoxFit.contain,
      child: widget.imageBuilder != null ? widget.imageBuilder!(url) : Image.network(url),
    );
  }

  Widget _titleWidget(String title) {
    final style = widget.metadataTitleStyle ??
        const TextStyle(
          fontWeight: FontWeight.bold,
        );
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _previewData = widget.previewData;

    if (_previewData != null && _hasData(_previewData)) {
      final aspectRatio = widget.previewData!.image == null
          ? null
          : widget.previewData!.image!.width / widget.previewData!.image!.height;

      return _containerWidget(
        animate: shouldAnimate,
        child: aspectRatio == 1
            ? _minimizedBodyWidget(_previewData, widget.text)
            : _bodyWidget(_previewData, widget.text, widget.width),
        isMinimized: aspectRatio == 1,
      );
    } else {
      return _containerWidget(animate: false, child: _linkify(false));
    }
  }
}
