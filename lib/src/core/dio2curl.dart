part of qiscus_chat_sdk.core;

// A simple utility function to dump `curl` from "Dio" requests
String dio2curl(RequestOptions requestOption) {
  var curl = '';

  var query = requestOption
    .queryParameters
    .entries
    .fold<String>('', (res, params) => res + '${params.key}=${params.value}&');

  if (requestOption.path.startsWith('http')) {
    curl += 'curl --request ${requestOption.method} \'${requestOption.path}$query\'';
  } else {
    // Add PATH + REQUEST_METHOD
    curl +=
        'curl --request ${requestOption.method} \'${requestOption.baseUrl}${requestOption.path}?$query\'';
  }

  // Include headers
  for (var key in requestOption.headers.keys) {
    curl += ' -H \'$key: ${requestOption.headers[key]}\'';
  }

  // Include data if there is data
  if (requestOption.data != null &&
      (requestOption.data is Map && (requestOption.data as Map).isNotEmpty)) {
    curl += ' --data-binary \'${requestOption.data}\'';
  }

  // curl += ' --insecure'; //bypass https verification

  return curl;
}
