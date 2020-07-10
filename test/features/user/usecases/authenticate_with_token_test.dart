import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/authenticate_with_token.dart';
import 'package:qiscus_chat_sdk/src/features/user/user_api.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  AuthenticateUserWithTokenUseCase authenticate;
  IUserRepository userRepo;
  Storage storage;

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

  setUpAll(() async {
    storage = Storage();
    userRepo = MockUserRepository();
    authenticate = AuthenticateUserWithTokenUseCase(userRepo, storage);
  });

  test('authenticate with token successfully', () async {
    var token = 'qwe12345';
    var params = AuthenticateWithTokenParams(token);

    var resp = AuthenticateResponse.fromJson(json);

    when(userRepo.authenticateWithToken(
            identityToken: anyNamed('identityToken')))
        .thenReturn(Task.delay(() => right(resp)));

    var rr = await authenticate(params).run();
    expect(rr.isRight(), true);
    rr.fold<void>((err) {
      expect(err, null);
    }, (data) {
      expect(data.id, resp.user.id);
    });

    expect(storage.userId, resp.user.id);
    expect(storage.token, resp.token);
    expect(storage.lastEventId, resp.user.lastEventId.getOrElse(() => null));
    expect(
        storage.lastMessageId, resp.user.lastMessageId.getOrElse(() => null));

    verify(userRepo.authenticateWithToken(
            identityToken: anyNamed('identityToken')))
        .called(1);
    verifyNoMoreInteractions(userRepo);
  });

  test('authenticate with token failure', () async {
    //
  });
}
