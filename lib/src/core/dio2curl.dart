part of qiscus_chat_sdk.core;

// A simple utility function to dump `curl` from "Dio" requests
String dio2curl(RequestOptions requestOption) {
  var curl = 'curl --request ${requestOption.method} ';
  var baseUrl = '';
  if (requestOption.path.startsWith('http')) {
    baseUrl = requestOption.path;
  } else {
    baseUrl = '${requestOption.baseUrl}${requestOption.path}';
  }

  // Include query parameters
  var params = requestOption.queryParameters.entries
    .map((entry) => '${entry.key}=${entry.value}')
    .join('&');

  if (params?.isNotEmpty == true) {
    curl += '\'$baseUrl?$params\'';
  } else {
    curl += '\'$baseUrl\'';
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
