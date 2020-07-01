import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/authenticate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() async {
  AuthenticateUserUseCase authenticate;
  IUserRepository userRepo;
  Storage storage;

  setUpAll(() {
    storage = Storage();
    userRepo = MockUserRepository();
    authenticate = AuthenticateUserUseCase(userRepo, storage);
  });

  test('successfully authenticate', () async {
    // region json response
    var json = {
      "results": {
        "user": {
          "active": true,
          "app": {
            "code": "sdksample",
            "id": 947,
            "id_str": "947",
            "name": "sdksample"
          },
          "avatar": {
            "avatar": {
              "url":
                  "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png"
            }
          },
          "avatar_url":
              "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png",
          "email": "guest-1001",
          "extras": {"extras": true},
          "id": 44465689,
          "id_str": "44465689",
          "last_comment_id": 0,
          "last_comment_id_str": "0",
          "last_sync_event_id": 0,
          "pn_android_configured": true,
          "pn_ios_configured": false,
          "rtKey": "somestring",
          "token": "DliiUcM3RdiRtlTyYpHK",
          "username": "guest-1001"
        }
      },
      "status": 200
    };
    // endregion
    var response = AuthenticateResponse.fromJson(json);
    when(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).thenReturn(Task.delay(() => right(response)));

    var params = AuthenticateParams(
      userId: 'guest-1001',
      userKey: 'passkey',
    );
    var resp = await authenticate.call(params).run();
    expect(resp.isRight(), true);
    resp.fold<void>((err) {
      expect(err, null);
    }, (data) {
      expect(data.value1, response.token);
      expect(data.value2.name, response.user.name);
    });

    verify(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).called(1);
    expect(storage.userId, response.user.id);
    expect(storage.token, response.token);
    verifyNoMoreInteractions(userRepo);
  });

  test('failure authenticate', () async {
    // region json response
    var json = <String, dynamic>{
      "error": {"code": 401306, "message": "wrong password"},
      "status": 401
    };
    // endregion

    when(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).thenReturn(
        Task.delay(() => left(QError(json['error']['message'] as String))));

    var params = AuthenticateParams(userId: 'guest-1001', userKey: 'wrong');
    var resp = await authenticate.call(params).run();
    expect(resp.isLeft(), true);
    resp.fold<void>((QError err) {
      expect(err.toString(), 'QError: wrong password');
    }, (data) {
      expect(data, null);
    });

    verify(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).called(1);
    verifyNoMoreInteractions(userRepo);
  });
}
