import 'package:church/presentations/initial/bloc/initial_cubit.dart';
import 'package:church/presentations/initial/view/initial_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shows startup preparation popup only during KR first-run preparation', () {
    expect(
      shouldShowStartupPreparationDialog(
        const InitialState(message: startupKrPreparationMessage),
      ),
      isTrue,
    );

    expect(
      shouldShowStartupPreparationDialog(
        const InitialState(message: 'Initiating...'),
      ),
      isFalse,
    );

    expect(
      shouldShowStartupPreparationDialog(
        const InitialState(
          isLoaded: true,
          message: startupKrPreparationMessage,
        ),
      ),
      isFalse,
    );
  });
}
