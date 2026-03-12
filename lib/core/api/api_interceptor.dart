import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._dio);

  // Public routes — skip token injection
  static const _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.parts,
    ApiEndpoints.categories,
    ApiEndpoints.brands,
    ApiEndpoints.search,
    ApiEndpoints.vehicleMakes,
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((p) => options.path.startsWith(p));

    if (!isPublic) {
      final token = await SecureStorage.getAccessToken();
      print("ACCESS TOKEN: $token");
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        // Queue this request until refresh completes
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null) {
          await SecureStorage.clearTokens();
          handler.reject(err);
          return;
        }

        // Refresh access token
        final response = await _dio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
          options: Options(
            headers: {'Authorization': null}, // no token on refresh request
          ),
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String?;

        await SecureStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await SecureStorage.saveRefreshToken(newRefreshToken);
        }

        // Retry original request with new token
        final opts = err.requestOptions
          ..headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(opts);

        // Retry all pending requests
        for (final pendingOptions in _pendingRequests) {
          pendingOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          await _dio.fetch(pendingOptions);
        }
        _pendingRequests.clear();

        handler.resolve(retryResponse);
      } catch (_) {
        await SecureStorage.clearTokens();
        _pendingRequests.clear();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
