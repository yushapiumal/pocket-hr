import 'dart:io';

/// Bypasses TLSV1_ALERT_UNRECOGNIZED_NAME errors caused by servers whose SSL
/// configuration doesn't handle SNI properly.
///
/// Root cause: the server sends a fatal TLS alert (unrecognized_name, code 112)
/// when it doesn't recognise the SNI hostname. Dart closes the connection
/// immediately — badCertificateCallback is never reached.
///
/// Fix: resolve the hostname to an IP address, then open TLS directly to that
/// IP. Per RFC 6066 §3, Dart/BoringSSL must NOT include the SNI extension when
/// the host is a literal IP address, so the server never sends the alert.
class AppHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;

    client.connectionFactory =
        (Uri uri, String? proxyHost, int? proxyPort) async {
      if (uri.isScheme('https') && proxyHost == null) {
        try {
          final addresses = await InternetAddress.lookup(uri.host);
          final ip = addresses.first; // InternetAddress → no SNI extension
          final Future<Socket> socketFuture = SecureSocket.connect(
            ip,
            uri.port,
            onBadCertificate: (_) => true,
          ).then<Socket>((s) => s);
          // fromSocket<Socket> → HttpClient sees SecureSocket, skips re-encryption
          return ConnectionTask.fromSocket(socketFuture, () {});
        } catch (_) {
          // DNS lookup failed – fall through to direct connect (may still hit SNI
          // error, but there is nothing further we can do client-side).
        }
      }
      return Socket.startConnect(
        proxyHost ?? uri.host,
        proxyPort ?? uri.port,
      );
    };

    return client;
  }
}

/// Call this once at the very start of every flavor's main() before runApp().
void setupHttpOverride() {
  HttpOverrides.global = AppHttpOverride();
}
