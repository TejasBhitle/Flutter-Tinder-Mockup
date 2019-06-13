import 'package:flutter/widgets.dart';

class TinderMatch extends ChangeNotifier{

  Decision decision = Decision.undecided;

  void like(){
    if(decision == Decision.undecided){
      decision = Decision.like;
      notifyListeners();
    }
  }

  void dislike(){
    if(decision == Decision.undecided){
      decision = Decision.dislike;
      notifyListeners();
    }
  }

  void superlike(){
    if(decision == Decision.undecided){
      decision = Decision.superlike;
      notifyListeners();
    }
  }

  void reset(){
    if(decision != Decision.undecided){
      decision = Decision.undecided;
      notifyListeners();
    }
  }

}

enum Decision{
  undecided,
  like,
  dislike,
  superlike
}