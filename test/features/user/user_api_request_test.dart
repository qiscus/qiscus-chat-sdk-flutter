import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart' as r;
import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';

void main() {
  group('AuthenticateRequest', () {
    r.AuthenticateRequest request;

    setUpAll(() {
      request = r.AuthenticateRequest(
        userId: 'userId',
        userKey: 'userKey',
        name: 'name',
        avatarUrl: 'avatar',
        extras: <String, dynamic>{
          'string': 'value',
          'int': 123,
        },
      );
    });
    test('body', () {
      expect(request.url, 'login_or_register');
      expect(request.method, IRequestMethod.post);
      expect(request.body['email'], 'userId');
      expect(request.body['password'], 'userKey');
      expect(request.body['username'], 'name');
      expect(request.body['avatar_url'], 'avatar');
      expect(request.body['extras']['string'], 'value');
      expect(request.body['extras']['int'], 123);
    });

    test('format', () {
      var responseBackend = <String, dynamic>{
        'results': {
          'user': {
            'active': true,
            'app': {
              'code': 'sdksample',
              'id': 947,
              'id_str': '947',
              'name': 'sdksample'
            },
            'avatar': {
              'avatar': {
                'url':
                    'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png'
              }
            },
            'avatar_url':
                'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png',
            'email': 'guest-101',
            'extras': {'title': 'senior manager'},
            'id': 32230310,
            'id_str': '32230310',
            'last_comment_id': 0,
            'last_comment_id_str': '0',
            'last_sync_event_id': 0,
            'pn_android_configured': true,
            'pn_ios_configured': false,
            'rtKey': 'somestring',
            'token': 'biY5BEcAMJxVhLsxPYID',
            'username': 'guest-101'
          }
        },
        'status': 200
      };
      var data = request.format(responseBackend);
      var user = data.second;
      var token = data.first;
      expect(token, 'biY5BEcAMJxVhLsxPYID');
      expect(user.id, 'guest-101');
      expect(user.name, Option.some('guest-101'));
      expect(
        user.avatarUrl,
        Option.some(
          'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png',
        ),
      );
    });
  });

  group('AuthenticateWithToken', () {
    r.AuthenticateWithTokenRequest request;

    setUpAll(() {
      request = r.AuthenticateWithTokenRequest(identityToken: 'some-token');
    });

    test('body', () {
      expect(request.body['identity_token'], 'some-token');
    });

    test('format', () {
      var backendResponse = <String, dynamic>{
        'results': {
          'user': {
            'app': {
              'code': 'jarjitapp',
              'id': 3,
              'id_str': '3',
              'name': 'jarjitapp'
            },
            'avatar': {
              'avatar': {
                'url':
                    'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png'
              }
            },
            'avatar_url':
                'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png',
            'email': 'jarjit@mail.com',
            'extras': {'role': 'admin'},
            'id': 13,
            'id_str': '13',
            'last_comment_id': 0,
            'last_comment_id_str': '0',
            'last_sync_event_id': 0,
            'pn_android_configured': true,
            'pn_ios_configured': false,
            'rtKey': 'somestring',
            'token': 'xTeQ0r3r82nrBmCKZBc0',
            'username': 'Jarjit singh'
          }
        },
        'status': 200
      };
      var data = request.format(backendResponse);

      expect(data.first, backendResponse['results']['user']['token']);
      expect(data.second.id, backendResponse['results']['user']['email']);
      expect(
        data.second.name,
        Option.some(backendResponse['results']['user']['username'] as String),
      );
      expect(
        data.second.avatarUrl,
        Option.some(backendResponse['results']['user']['avatar_url'] as String),
      );
    });
  });

  group('GetNonce', () {
    r.GetNonceRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'expired_at': 1503025239,
        'nonce': 'nabk2qL74OlVtdv5V5EhEYZGla5JoRyBlQPXp9xZ'
      },
      'status': 200
    };

    setUpAll(() {
      request = r.GetNonceRequest();
    });

    test('format', () {
      var data = request.format(responseBackend);
      expect(data, responseBackend['results']['nonce']);
    });
  });

  group('BlockUserRequest', () {
    r.BlockUserRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'user': {
          'avatar': {
            'avatar': {
              'url':
                  'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/FhDIH53G9r/image-304e1a31-47e9-46ff-9064-ece1d96bf808.jpg'
            }
          },
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/FhDIH53G9r/image-304e1a31-47e9-46ff-9064-ece1d96bf808.jpg',
          'email': 'guest-102',
          'extras': <String, dynamic>{},
          'id': 32593562,
          'id_str': '32593562',
          'username': 'guest-102'
        }
      },
      'status': 200
    };

    setUpAll(() {
      request = r.BlockUserRequest(userId: 'user-id');
    });

    test('body', () {
      expect(request.body['user_email'], 'user-id');
    });
    test('format', () {
      var data = request.format(responseBackend);
      var user = responseBackend['results']['user'] as Map<String, dynamic>;

      expect(data.id, Option.some(user['email'] as String));
      expect(data.name, Option.some(user['username'] as String));
      expect(data.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });

  group('UnblockUserRequest', () {
    r.UnblockUserRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'user': {
          'avatar': {
            'avatar': {
              'url':
                  'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/FhDIH53G9r/image-304e1a31-47e9-46ff-9064-ece1d96bf808.jpg'
            }
          },
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/FhDIH53G9r/image-304e1a31-47e9-46ff-9064-ece1d96bf808.jpg',
          'email': 'guest-102',
          'extras': <String, dynamic>{},
          'id': 32593562,
          'id_str': '32593562',
          'username': 'guest-102'
        }
      },
      'status': 200
    };

    setUpAll(() {
      request = r.UnblockUserRequest(userId: 'user-id');
    });

    test('body', () {
      expect(request.body['user_email'], 'user-id');
    });

    test('format', () {
      var data = request.format(responseBackend);
      var user = responseBackend['results']['user'] as Map<String, dynamic>;

      expect(data.id, Option.some(user['email'] as String));
      expect(data.name, Option.some(user['username'] as String));
      expect(data.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });

  group('GetBlockedUsersRequest', () {
    r.GetBlockedUsersRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'blocked_users': [
          {
            'avatar': {
              'avatar': {
                'url':
                    'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/1nOC-hvaQx/Screenshot_8.png'
              }
            },
            'avatar_url':
                'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/1nOC-hvaQx/Screenshot_8.png',
            'email': 'guest-1002',
            'extras': <String, dynamic>{},
            'id': 44465688,
            'id_str': '44465688',
            'username': 'guest-1002'
          }
        ],
        'total': 1
      },
      'status': 200
    };

    setUpAll(() {
      request = r.GetBlockedUsersRequest(
        page: 1,
        limit: 1,
      );
    });

    test('body', () {
      expect(request.params['page'], 1);
      expect(request.params['limit'], 1);
    });
    test('format', () {
      var data = request.format(responseBackend);
      var user = (responseBackend['results']['blocked_users'] as List)
          .cast<Map<String, dynamic>>()
          .first;

      expect(data.first.id, Option.some(user['email'] as String));
      expect(data.first.name, Option.some(user['username'] as String));
      expect(data.first.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });

  group('GetUserDataRequest', () {
    r.GetUserDataRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'user': {
          'active': true,
          'app': {
            'code': 'sdksample',
            'id': 947,
            'id_str': '947',
            'name': 'sdksample'
          },
          'avatar': {
            'avatar': {
              'url':
                  'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png'
            }
          },
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
          'email': 'guest-1001',
          'extras': {'extras': true},
          'id': 44465689,
          'id_str': '44465689',
          'last_comment_id': 0,
          'last_comment_id_str': '0',
          'last_sync_event_id': 0,
          'pn_android_configured': true,
          'pn_ios_configured': false,
          'rtKey': 'somestring',
          'token': 'DliiUcM3RdiRtlTyYpHK',
          'username': 'guest-1001'
        }
      },
      'status': 200
    };

    setUp(() {
      request = r.GetUserDataRequest();
    });

    test('format', () {
      var data = request.format(responseBackend);
      var user = responseBackend['results']['user'] as Map<String, dynamic>;

      expect(data.id, user['email']);
      expect(data.name, Option.some(user['username'] as String));
      expect(data.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });

  group('GetUserListRequest', () {
    r.GetUserListRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'meta': {'total_data': 0, 'total_page': 0},
        'users': [
          {
            'active': true,
            'avatar_url': 'https://image.url/image.jpeg',
            'created_at': '2018-11-12T00:46:53.611450Z',
            'email': 'guest99@qiscus.com',
            'extras': <String, dynamic>{},
            'id': 8832918,
            'name': 'QISCUS demo user',
            'updated_at': '2019-11-03T10:09:07.469457Z',
            'username': 'QISCUS demo user'
          }
        ]
      },
      'status': 200
    };

    setUp(() {
      request = r.GetUserListRequest(
        query: 'query',
        page: 1,
        limit: 1,
      );
    });

    test('body', () {
      expect(request.body['page'], 1);
      expect(request.body['limit'], 1);
      expect(request.body['query'], 'query');
    });

    test('format', () {
      var data = request.format(responseBackend);
      var user = (responseBackend['results']['users'] as List)
          .cast<Map<String, dynamic>>()
          .first;

      expect(data.first.id, Option.some(user['email'] as String));
      expect(data.first.name, Option.some(user['username'] as String));
      expect(data.first.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });

  group('SetDeviceTokenRequest', () {
    r.SetDeviceTokenRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'changed': true,
        'pn_android_configured': true,
        'pn_ios_configured': false
      },
      'status': 200
    };

    setUp(() {
      request = r.SetDeviceTokenRequest(token: 'some-token');
    });

    test('body', () {
      expect(request.body['device_token'], 'some-token');
      expect(request.body['device_platform'], 'flutter');
      expect(request.body['is_development'], false);
    });

    test('format', () {
      var data = request.format(responseBackend);

      expect(data, responseBackend['results']['changed']);
    });
  });

  group('UnsetDeviceTokenRequest', () {
    r.UnsetDeviceTokenRequest request;
    var responseBackend = <String, dynamic>{
      'results': {'success': true},
      'status': 200
    };

    setUp(() {
      request = r.UnsetDeviceTokenRequest(token: 'some-token');
    });

    test('body', () {
      expect(request.body['device_token'], 'some-token');
      expect(request.body['device_platform'], 'flutter');
      expect(request.body['is_development'], false);
    });

    test('format', () {
      var data = request.format(responseBackend);
      expect(data, responseBackend['results']['success']);
    });
  });

  group('UpdateUserDataRequest', () {
    r.UpdateUserDataRequest request;
    var responseBackend = <String, dynamic>{
      'results': {
        'user': {
          'active': true,
          'app': {
            'code': 'sdksample',
            'id': 947,
            'id_str': '947',
            'name': 'sdksample'
          },
          'avatar': {
            'avatar': {
              'url':
                  'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png'
            }
          },
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
          'email': 'guest-1001',
          'extras': {'extras': true},
          'id': 44465689,
          'id_str': '44465689',
          'last_comment_id': 0,
          'last_comment_id_str': '0',
          'last_sync_event_id': 0,
          'pn_android_configured': true,
          'pn_ios_configured': false,
          'rtKey': 'somestring',
          'token': 'DliiUcM3RdiRtlTyYpHK',
          'username': 'guest-1001'
        }
      },
      'status': 200
    };

    setUpAll(() {
      request = r.UpdateUserDataRequest();
    });

    test('only updating name should not update other field', () {
      request = r.UpdateUserDataRequest(name: 'some-name');
      expect(request.body['name'], 'some-name');
      expect(request.body['avatar_url'], null);
      expect(request.body['extras'], null);
    });

    test('format', () {
      var data = request.format(responseBackend);
      var user = responseBackend['results']['user'] as Map<String, dynamic>;

      expect(data.id, user['email']);
      expect(data.name, Option.some(user['username'] as String));
      expect(data.avatarUrl, Option.some(user['avatar_url'] as String));
    });
  });
}
