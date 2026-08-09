import 'package:church/domain/entity/account/account_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Account.resolvedMemberType', () {
    test('does not treat generic account status as membership type', () {
      const account = Account(type: 'USER', status: 'ACTIVE');

      expect(account.resolvedMemberType, isNull);
    });

    test('maps baptism state to Jemaat and Simpatisan', () {
      expect(const Account(baptized: true).resolvedMemberType, 'Jemaat');
      expect(const Account(baptized: false).resolvedMemberType, 'Simpatisan');
      expect(const Account(baptized: 'sudah').resolvedMemberType, 'Jemaat');
      expect(const Account(baptized: 'belum').resolvedMemberType, 'Simpatisan');
    });

    test('normalizes explicit membership labels', () {
      expect(const Account(memberType: 'Jemaat').resolvedMemberType, 'Jemaat');
      expect(
        const Account(jenisAnggota: 'Simpatisan').resolvedMemberType,
        'Simpatisan',
      );
      expect(
        const Account(memberType: 'not baptized').resolvedMemberType,
        'Simpatisan',
      );
    });
  });
}
