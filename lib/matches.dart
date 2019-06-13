import 'package:flutter/widgets.dart';
import 'profiles.dart';

class MatchEngine extends ChangeNotifier{
  final List<TinderMatch> _matches;
  int _currentMatchIndex;
  int _nextMatchIndex;

  MatchEngine({
    List<TinderMatch> matches,
  }): _matches = matches {
    _currentMatchIndex = 0;
    _nextMatchIndex = 1;
  }

  TinderMatch get currentMatch => _matches[_currentMatchIndex];

  TinderMatch get nextMatch => _matches[_nextMatchIndex];

  void goToNext(){
    if(currentMatch.decision != Decision.undecided){
      currentMatch.reset();
      _currentMatchIndex = _nextMatchIndex;
      _nextMatchIndex = (_nextMatchIndex+1) % _matches.length;
      notifyListeners();
    }
  }

}

class TinderMatch extends ChangeNotifier{

  Decision decision = Decision.undecided;
  final Profile profile;

  TinderMatch({
    this.profile,
  });

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