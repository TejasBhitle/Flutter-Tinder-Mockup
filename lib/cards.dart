import 'package:flutter/material.dart';
import 'package:fluttery_dart2/layout.dart';
import 'package:tinder_mockup/imageBrowser.dart';

class DraggableCard extends StatefulWidget {
  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
        showOverlay: true,
        child: Center(),
        overlayBuilder: (BuildContext context, Rect anchorBounds, Offset anchor){
          return CenterAbout(
              position: anchor,
              child: Container(
                width: anchorBounds.width,
                height: anchorBounds.height,
                padding: const EdgeInsets.all(16.0),
                child: ProfileCard(),
              )
          );
        }
    );
  }
}


class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {

  Widget _buildBackground(){
    return ImageBrowser(
      imageAssetPaths: [
        'assets/images/image_01.png',
        'assets/images/image_02.jpg',
      ],
      visibleImageIndex: 0,
    );
  }

  Widget _buildProfileData(){
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
          ),
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Tejas Bhitle',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0
                        ),
                      ),
                      Text(
                        'Description',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                        ),
                      ),
                    ],
                  )
              ),
              Icon(
                Icons.info,
                color: Colors.white,
              ),
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0x11000000),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            )
          ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildBackground(),
              _buildProfileData(),
            ],
          ),
        ),
      ),
    );
  }
}