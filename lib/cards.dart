import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttery_dart2/layout.dart';
import 'imageBrowser.dart';
import 'matches.dart';

class DraggableCard extends StatefulWidget {

  TinderMatch tinderMatch;

  DraggableCard({
    this.tinderMatch
  });

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with TickerProviderStateMixin{

  Offset cardOffset = const Offset(0.0,0.0);
  Offset dragStart;
  Offset dragPosition;
  Offset slideBackStart;
  AnimationController slideBackAnimation;
  Tween<Offset> slideOutTween;
  AnimationController slideOutAnimation;

  Decision decision;
  GlobalKey profileCardKey = new GlobalKey(debugLabel: 'profile_card_key'); // to get context of another widget

  @override
  void initState() {
    super.initState();
    slideBackAnimation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(()=> setState((){
      cardOffset = Offset.lerp( //linearInterpolation
          slideBackStart,
          const Offset(0.0, 0.0),
        Curves.elasticOut.transform(slideBackAnimation.value)
      );
    }))
    ..addStatusListener((AnimationStatus status){
      if(status == AnimationStatus.completed){
        setState(() {
          dragStart = null;
          slideBackStart = null;
          dragPosition = null;
        });
      }
    });

    slideOutAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener((){
      setState(() {
        cardOffset = slideOutTween.evaluate(slideOutAnimation);
      });
    })..addStatusListener((AnimationStatus status){
      if(status == AnimationStatus.completed){
        setState(() {
          dragStart = null;
          dragPosition = null;
          slideOutTween = null;
          cardOffset = const Offset(0.0,0.0);

          widget.tinderMatch.reset();
        });
      }
    });
    
    widget.tinderMatch.addListener(_onTinderMatchChange);
    decision = widget.tinderMatch.decision;
  }

  @override
  void dispose() {
    widget.tinderMatch.removeListener(_onTinderMatchChange);
    slideBackAnimation.dispose();
    super.dispose();
  }

  // housekeeping stuff, just in case of any memory leak
  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.tinderMatch != oldWidget.tinderMatch){
      oldWidget.tinderMatch.removeListener(_onTinderMatchChange);
      widget.tinderMatch.addListener(_onTinderMatchChange);
    }
  }

  void _onTinderMatchChange(){
    if(widget.tinderMatch.decision != decision){
      switch(widget.tinderMatch.decision){
        case Decision.like:
          _slideRight();
          break;
        case Decision.superlike:
          _slideUp();
          break;
        case Decision.dislike:
          _slideLeft();
          break;
        case Decision.undecided:
          break;
      }
    }
    decision = widget.tinderMatch.decision;
  }


  void _slideLeft(){
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(-2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideRight(){
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideUp(){
    final screenHeight = context.size.height;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(0.0,-2 * screenHeight));
    slideOutAnimation.forward(from: 0.0);
  }


  Offset _chooseRandomDragStart(){
    // get the cardTopleft cordinate in Draggable card wrt the (0.0, 0.0) point in profileCard
    final profileCardContext = profileCardKey.currentContext;
    final cardTopLeft = (profileCardContext.findRenderObject() as RenderBox).localToGlobal(const Offset(0.0,0.0));

    final dragStartY = profileCardContext.size.height * (Random().nextDouble() < 0.5 ? 0.25: 0.75);

    return Offset(profileCardContext.size.width/2 + cardTopLeft.dx, dragStartY + cardTopLeft.dy);
  }

  void _onPanStart(DragStartDetails details){
    dragStart = details.globalPosition;
    if(slideBackAnimation.isAnimating){
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details){
    setState(() {
      dragPosition = details.globalPosition;
      cardOffset = dragPosition - dragStart;
    });
  }

  void _onPanEnd(DragEndDetails details){

    final dragVector = cardOffset / cardOffset.distance; //Unit vector
    final isInNopeRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInLikeRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInSuperLikeRegion = (cardOffset.dy / context.size.height) < -0.40;

    setState(() {
      if(isInLikeRegion || isInNopeRegion){
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * ( 2* context.size.width));
        slideOutAnimation.forward(from: 0.0);
      } else if(isInSuperLikeRegion){
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * ( 2* context.size.height));
        slideOutAnimation.forward(from: 0.0);

      } else{
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }
    });
  }

  double _rotation(Rect dragBounds){
    if(dragStart == null ){
      return 0.0;
    }
    final rotationCornerMultiplier = dragStart.dy >= dragBounds.top + (dragBounds.height / 2)? 1: -1;
    return (pi / 8) * (cardOffset.dx / dragBounds.width) * rotationCornerMultiplier;
  }

  Offset _rotationOrigin(Rect dragBounds){
    if(dragStart == null){
      return const Offset(0.0,0.0);
    }
    return dragStart - dragBounds.topLeft;
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
        showOverlay: true,
        child: Center(),
        overlayBuilder: (BuildContext context, Rect anchorBounds, Offset anchor){
          return CenterAbout(
              position: anchor,
              child: Transform(
                transform: Matrix4.translationValues(cardOffset.dx, cardOffset.dy, 0.0)
                ..rotateZ(_rotation(anchorBounds)),
                origin: _rotationOrigin(anchorBounds),
                child: Container(
                  key: profileCardKey,
                  width: anchorBounds.width,
                  height: anchorBounds.height,
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: ProfileCard(),
                  )
                ),
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
        'assets/images/image_03.jpg',
        'assets/images/image_04.jpg'

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