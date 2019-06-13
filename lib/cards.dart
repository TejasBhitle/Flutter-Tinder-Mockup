import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttery_dart2/layout.dart';
import 'imageBrowser.dart';
import 'matches.dart';
import 'profiles.dart';

class CardStack extends StatefulWidget {

  MatchEngine matchEngine;

  CardStack({
    this.matchEngine
  });

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {

  TinderMatch _currentMatch;
  double _nextCardScale = 0.9;

  Key _frontCard;

  @override
  void initState() {
    super.initState();
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentMatch = widget.matchEngine.currentMatch;
    _currentMatch.addListener(_onMatchChange);

    _frontCard = Key(_currentMatch.profile.name);
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.matchEngine != widget.matchEngine){
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }

    if(_currentMatch != null){
      _currentMatch.removeListener(_onMatchChange);
    }
    _currentMatch = widget.matchEngine.currentMatch;
    if(_currentMatch != null){
      _currentMatch.addListener(_onMatchChange);
    }

  }

  @override
  void dispose() {
    if(_currentMatch != null){
      _currentMatch.removeListener(_onMatchChange);
    }
    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  void _onMatchChange(){
    setState(() {
      /* currentMatch may have changed, re-render */
    });
  }

  void _onMatchEngineChange(){
      setState(() {

        if(_currentMatch != null){
          _currentMatch.removeListener(_onMatchChange);
        }
        _currentMatch = widget.matchEngine.currentMatch;
        if(_currentMatch != null){
          _currentMatch.addListener(_onMatchChange);
        }
        _frontCard = Key(_currentMatch.profile.name);

      });
  }

  Widget _buildBackCard(){
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale,_nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        profile: widget.matchEngine.nextMatch.profile,
      ),
    );
  }

  Widget _buildFrontCard(){
    return ProfileCard(
      key: _frontCard,
      profile: widget.matchEngine.currentMatch.profile,
    );
  }

  void _onSlideUpdate(double distance){
    setState(() {
      _nextCardScale = 0.9 + (0.01 * (distance)/100.0).clamp(0.0, 1.0);
    });
  }

  void _onSlideOutComplete(SlideDirection slideDirection){
    TinderMatch currentMatch = widget.matchEngine.currentMatch;

    switch(slideDirection){
      case SlideDirection.up:
        currentMatch.superlike();
        break;
      case SlideDirection.left:
        currentMatch.dislike();
        break;
      case SlideDirection.right:
        currentMatch.like();
        break;
    }
    widget.matchEngine.goToNext();
  }

  SlideDirection _desiredSlideOutDirection(){
    switch(widget.matchEngine.currentMatch.decision){
      case Decision.like:
        return SlideDirection.right;
      case Decision.dislike:
        return SlideDirection.left;
      case Decision.superlike:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DraggableCard(
          isDraggable: false,
          card: _buildBackCard(),
        ),
        DraggableCard(
          card: _buildFrontCard(),
          slideTo: _desiredSlideOutDirection(),
          onSlideUpdate: _onSlideUpdate,
          onSlideOutComplete: _onSlideOutComplete,
        )
      ],
    );
  }
}


enum SlideDirection{
  left,
  right,
  up,
}


class DraggableCard extends StatefulWidget {

  final Widget card;
  final bool isDraggable;
  final Function(double distance) onSlideUpdate;
  final SlideDirection slideTo;
  final Function(SlideDirection direction) onSlideOutComplete;

  DraggableCard({
    this.card,
    this.isDraggable = true,
    this.slideTo,
    this.onSlideUpdate,
    this.onSlideOutComplete,
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
  SlideDirection slideOutDirection;

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

      if(widget.onSlideUpdate != null){
        widget.onSlideUpdate(cardOffset.distance);
      }

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

        if(widget.onSlideUpdate != null){
          widget.onSlideUpdate(cardOffset.distance);
        }

      });
    })..addStatusListener((AnimationStatus status){
      if(status == AnimationStatus.completed){
        setState(() {
          dragStart = null;
          dragPosition = null;
          slideOutTween = null;

          if(widget.onSlideOutComplete != null){
            widget.onSlideOutComplete(slideOutDirection);
          }

        });
      }
    });

  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    super.dispose();
  }

  // housekeeping stuff, just in case of any memory leak
  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.card.key != oldWidget.card.key){
      cardOffset = const Offset(0.0, 0.0);
    }

    if(oldWidget.slideTo == null &&  widget.slideTo != null){
      switch(widget.slideTo){
        case SlideDirection.left:
          _slideLeft();
          break;
        case SlideDirection.right:
          _slideRight();
          break;
        case SlideDirection.up:
          _slideUp();
          break;
      }
    }

  }


  void _slideLeft() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(-2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideRight() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(2 * screenWidth, 0.0));
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideUp() async {
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

      if(widget.onSlideUpdate != null){
        widget.onSlideUpdate(cardOffset.distance);
      }

    });
  }

  void _onPanEnd(DragEndDetails details){

    final dragVector = cardOffset / cardOffset.distance; //Unit vector
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInTopRegion = (cardOffset.dy / context.size.height) < -0.40;

    setState(() {
      if(isInRightRegion || isInLeftRegion){
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * ( 2* context.size.width));
        slideOutAnimation.forward(from: 0.0);
        slideOutDirection = isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else if(isInTopRegion){
        slideOutTween = new Tween(begin: cardOffset, end: dragVector * ( 2* context.size.height));
        slideOutAnimation.forward(from: 0.0);
        slideOutDirection = SlideDirection.up;

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
                    child: widget.card,
                  )
                ),
              )
          );
        }
    );
  }
}


class ProfileCard extends StatefulWidget {

  final Profile profile;

  ProfileCard({
    Key key,
    this.profile,
  }): super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {

  Widget _buildBackground(){
    return ImageBrowser(
      imageAssetPaths: widget.profile.images,
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
                        widget.profile.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0
                        ),
                      ),
                      Text(
                        widget.profile.bio,
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