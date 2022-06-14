part of qiscus_chat_sdk.core;

// A simple utility function to dump `curl` from "Dio" requests
String dio2curl(RequestOptions requestOption) {
  var curl = 'curl --request ${requestOption.method}';

  if (requestOption.path.startsWith('http')) {
    curl += ' \'${requestOption.path}\'';
  } else {
    // Add PATH + REQUEST_METHOD
    curl += ' \'${requestOption.baseUrl}${requestOption.path}\'';
  }

  var query = requestOption.queryParameters.entries.fold<String>(
      '', (res, params) => res + '${params.key}=${params.value}&');
  if (query.isNotEmpty) {
    curl += '?${query.substring(0, query.length - 1)}';
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
