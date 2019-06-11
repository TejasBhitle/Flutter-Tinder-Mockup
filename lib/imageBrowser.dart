import 'package:flutter/material.dart';

class ImageBrowser extends StatefulWidget {

  final List<String> imageAssetPaths;
  final int visibleImageIndex;

  ImageBrowser({
    this.imageAssetPaths,
    this.visibleImageIndex,
  });


  @override
  _ImageBrowserState createState() => _ImageBrowserState();
}

class _ImageBrowserState extends State<ImageBrowser> {

  int visibleImageIndex;

  @override
  void initState() {
    super.initState();
    visibleImageIndex = widget.visibleImageIndex;
  }

  @override
  void didUpdateWidget(ImageBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.visibleImageIndex != oldWidget.visibleImageIndex){
      setState(() {
        visibleImageIndex = widget.visibleImageIndex;
      });
    }
  }

  void _prevImage(){
    setState(() {
      visibleImageIndex = (visibleImageIndex > 0)? visibleImageIndex-1: visibleImageIndex;
    });
  }

  void _nextImage(){
    setState(() {
      visibleImageIndex = (visibleImageIndex < widget.imageAssetPaths.length -1 )
          ? visibleImageIndex+1
          : visibleImageIndex;
    });
  }

  Widget _buildImageControls(){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: _prevImage,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topLeft,
            child: Container(
                color: Colors.transparent
            ),
          ),
        ),
        GestureDetector(
          onTap: _nextImage,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: Alignment.topRight,
            child: Container(
                color: Colors.transparent
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Image
        Image.asset(
          widget.imageAssetPaths[visibleImageIndex],
          fit: BoxFit.cover,
        ),

        // Image Indicator
        Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: SelectedImageIndicator(
              imageCount: widget.imageAssetPaths.length,
              visibleImageIndex: visibleImageIndex,
            )
        ),

        // Image Controls
        _buildImageControls(),

      ],
    );
  }
}

class SelectedImageIndicator extends StatelessWidget {

  final int imageCount;
  final int visibleImageIndex;

  SelectedImageIndicator({ this.imageCount, this.visibleImageIndex});

  Widget _buildInActiveIndicator(){
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Container(
            height: 3.0,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.5),
            ),
          )
      ),
    );
  }

  Widget _buildActiveIndicator(){
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Container(
            height: 3.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.5),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x22000000),
                      spreadRadius: 0.0,
                      blurRadius: 2.0,
                      offset: const Offset(0.0, 1.0)
                  )
                ]
            ),
          )
      ),
    );
  }

  List<Widget> _buildIndicators(){
    List<Widget> indicators = [];
    for(int i=0;i<imageCount;i++){
      indicators.add(
          i==visibleImageIndex ? _buildActiveIndicator(): _buildInActiveIndicator()
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: _buildIndicators(),
      ),
    );
  }

}