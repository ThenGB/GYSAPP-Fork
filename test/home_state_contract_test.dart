import 'package:church/presentations/home/bloc/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home content toggles stay visible by default until remote config loads', () {
    const state = HomeState();

    expect(state.isSauhEnabled, isTrue);
    expect(state.isSuaraSejatiEnabled, isTrue);
  });
}
