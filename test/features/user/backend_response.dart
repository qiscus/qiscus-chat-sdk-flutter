const loginOrRegisterResponse = <String, dynamic>{
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
          "url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png"
        }
      },
      "avatar_url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png",
      "email": "guest-101",
      "extras": {
        "title": "senior manager"
      },
      "id": 32230310,
      "id_str": "32230310",
      "last_comment_id": 0,
      "last_comment_id_str": "0",
      "last_sync_event_id": 0,
      "pn_android_configured": true,
      "pn_ios_configured": false,
      "rtKey": "somestring",
      "token": "biY5BEcAMJxVhLsxPYID",
      "username": "guest-101"
    }
  },
  "status": 200
};

const authenticateWithTokenResponse = loginOrRegisterResponse;

const blockUserResponse = <String, dynamic>{
  "results": {
    "user": {
      "avatar": {
        "avatar": {
          "url": "https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png"
        }
      },
      "avatar_url": "https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png",
      "email": "guest-1021",
      "extras": <String, dynamic>{},
      "id": 100268118,
      "id_str": "100268118",
      "username": "guest-ckpb"
    }
  },
  "status": 200
};

const unblockUserResponse = blockUserResponse;

const getBlockedUsersResponse = <String, dynamic>{
  "results": {
    "blocked_users": [
      {
        "avatar": {
          "avatar": {
            "url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/1nOC-hvaQx/Screenshot_8.png"
          }
        },
        "avatar_url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/1nOC-hvaQx/Screenshot_8.png",
        "email": "guest-1002",
        "extras": <String, dynamic>{},
        "id": 44465688,
        "id_str": "44465688",
        "username": "guest-1002"
      }
    ],
    "total": 1
  },
  "status": 200
};

const getNonceResponse = <String, dynamic>{
  "results": {
    "expired_at": 1595317052,
    "nonce": "jl9k14Gw7gY0hMpNXGBS5WYd2E94xx1joBa5NqMV"
  },
  "status": 200
};

const getUserDataResponse = <String, dynamic>{
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
          "url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png"
        }
      },
      "avatar_url": "https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png",
      "email": "guest-1001",
      "extras": {
        "extras": true
      },
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

const getUsersResponse = <String, dynamic>{
  "results": {
    "meta": {
      "total_data": 0,
      "total_page": 0
    },
    "users": [
      {
        "active": true,
        "avatar_url": "https://image.url/image.jpeg",
        "created_at": "2018-11-12T00:46:53.611450Z",
        "email": "guest99@qiscus.com",
        "extras": <String, dynamic>{},
        "id": 8832918,
        "name": "QISCUS demo user",
        "updated_at": "2019-11-03T10:09:07.469457Z",
        "username": "QISCUS demo user"
      }
    ]
  },
  "status": 200
};

const setDeviceTokenResponse = <String, dynamic>{
  "results": {
    "changed": true,
    "pn_android_configured": true,
    "pn_ios_configured": false
  },
  "status": 200
};

const unsetDeviceTokenResponse = <String, dynamic>{
  "results": {
    "success": true
  },
  "status": 200
};

const updateUserDataResponse = loginOrRegisterResponse;