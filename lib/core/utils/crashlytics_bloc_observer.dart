import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BlocObserver qui envoie les erreurs BLoC à Crashlytics.
///
/// Les transitions sont loguées comme breadcrumbs pour retracer
/// le chemin de l'utilisateur avant un crash.
class CrashlyticsBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'BLoC error in ${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    FirebaseCrashlytics.instance.log(
      '[BLoC] ${bloc.runtimeType}: ${transition.event.runtimeType} → ${transition.nextState.runtimeType}',
    );
    super.onTransition(bloc, transition);
  }
}
