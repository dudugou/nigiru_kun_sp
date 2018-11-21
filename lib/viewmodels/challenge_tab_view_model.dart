import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/rxdart.dart';

import 'package:nigiru_kun/usecases/challenge_use_case.dart';
import 'package:nigiru_kun/entities/hand.dart';
import 'package:nigiru_kun/entities/challenge_data.dart';

enum ChallengeState {
  StandBy,
  Doing,
  Finished,
  Error,
}

enum DialogType {
  Finished,
  Error,
  Close,
}

class ChallengeTabViewModel extends Model {
  final int maxForce = 100;
  final ChallengeUseCase useCase = ChallengeUseCase();
  Hand _currentHand = Hand.Right;
  ChallengeData _rightBest =
      ChallengeData(Hand.Right, 120, DateTime(2018, 10, 14));
  ChallengeData _leftBest =
      ChallengeData(Hand.Left, 60, DateTime(2018, 10, 16));
  PublishSubject<DialogType> _currentDialog = PublishSubject<DialogType>();
  ChallengeState _currentState = ChallengeState.StandBy;
  double _currentForce = 0;

  Hand get currentHand => _currentHand;

  ChallengeData get rightBest => _rightBest;

  ChallengeData get leftBest => _leftBest;

  int get currentForce => _currentForce.toInt();

  double get currentForceRatio => _currentForce / maxForce;

  ChallengeState get currentState => _currentState;

  PublishSubject<DialogType> get currentDialog => _currentDialog;

  String get currentHandName {
    switch (_currentHand) {
      case Hand.Right:
        return '右手';
      case Hand.Left:
        return '左手';
    }
    return null;
  }

  void handleCurrentHand(Hand hand) {
    if (_currentState == ChallengeState.StandBy) {
      _currentHand = hand;
      notifyListeners();
    }
  }

  void startChallenge() {
    _currentState = ChallengeState.Doing;
    _currentDialog.add(DialogType.Finished); //TODO: 本来は測定が終わったタイミングで出す。
    notifyListeners();
  }

  void saveChallenge() {
    _currentState = ChallengeState.StandBy;
    notifyListeners();
  }

  void cancelChallenge() {
    _currentState = ChallengeState.StandBy;
    notifyListeners();
  }

  void init() {
    _currentDialog = PublishSubject<DialogType>();
    useCase.observeForceWeight.listen((weight) {
      _currentForce = weight < maxForce ? weight : maxForce;
      notifyListeners();
    });
  }

  void dispose() {
    _currentDialog.close();
  }
}
