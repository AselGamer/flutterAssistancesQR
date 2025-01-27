import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_app/services/localstore_service.dart';

class GraphQLService {
  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;

  late GraphQLClient _client;
  String? _currentToken;
  String? userId;
  final LocalStoreService _localStoreService = LocalStoreService();

  GraphQLService._internal() {
    _initializeClient();
  }

  /// Initialize the GraphQL client with token from LocalStore
  Future<void> _initializeClient() async {
    // Attempt to retrieve token from LocalStore
    final user = await _localStoreService.getDocument(
      collection: 'login',
      documentId: 'saved',
    );
    final String? storedToken = user == null ? null : user['token'];

    final HttpLink httpLink = HttpLink(
      'http://10.0.2.2:4000/', // Replace with your actual GraphQL endpoint
    );

    final AuthLink authLink = AuthLink(
      getToken: () async {
        // Prioritize current token, then stored token
        return storedToken != null ? 'Bearer $storedToken' : '';
      },
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    // If a token was found, update the current token
    if (storedToken != null) {
      _currentToken = storedToken;
	  refreshUserId();
    }
  }

  /// Update the bearer token in both current instance and LocalStore
  Future<void> updateToken(String newToken) async {
    _currentToken = newToken;
    await _localStoreService.saveDocument(
        collection: 'login',
        documentId: 'saved',
        data: {'token': newToken, 'userId': userId});
    await _initializeClient(); // Reinitialize with new token
  }

  Future<void> updateUserId(String userId) async {
    userId = userId;
    await _localStoreService.saveDocument(
        collection: 'login', documentId: 'user_id', data: {'userId': userId});
    await _initializeClient(); // Reinitialize with new token
  }

  Future<void> refreshUserId() async {
    final user = await _localStoreService.getDocument(
        collection: 'login', documentId: 'user_id');
    if (user == null) return;
    userId = user['userId'];
  }

  /// Perform a query with optional token refresh
  Future<QueryResult> performQuery(
    String query, {
    Map<String, dynamic>? variables,
    bool refreshTokenIfNeeded = true,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(query),
        variables: variables ?? {},
      );

      final QueryResult result = await _client.query(options);

      // Check for unauthorized error and handle token refresh if needed
      if (refreshTokenIfNeeded && _isUnauthorizedError(result)) {
        await _handleUnauthorizedError();
        return performQuery(query,
            variables: variables, refreshTokenIfNeeded: false);
      }

      _handleErrors(result);
      return result;
    } catch (e) {
      debugPrint('GraphQL Query Error: $e');
      rethrow;
    }
  }

  /// Perform a mutation with optional token refresh
  Future<QueryResult> performMutation(
    String mutation, {
    Map<String, dynamic>? variables,
    bool refreshTokenIfNeeded = true,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
      );

      final QueryResult result = await _client.mutate(options);

      // Check for unauthorized error and handle token refresh
      if (refreshTokenIfNeeded && _isUnauthorizedError(result)) {
        await _handleUnauthorizedError();
        return performMutation(mutation,
            variables: variables, refreshTokenIfNeeded: false);
      }

      _handleErrors(result);
      return result;
    } catch (e) {
      debugPrint('GraphQL Mutation Error: $e');
      rethrow;
    }
  }

  /// Check if the result indicates an unauthorized error
  bool _isUnauthorizedError(QueryResult result) {
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors;
      return errors?.any((error) =>
              error.message.toLowerCase().contains('unauthorized') ||
              error.message.toLowerCase().contains('token')) ??
          false;
    }
    return false;
  }

  /// Handle unauthorized error by attempting to refresh token
  Future<void> _handleUnauthorizedError() async {
    try {
      // This is where you would implement your token refresh logic
      // For example, calling a refresh token endpoint or method
      final user = await _localStoreService.getDocument(
        collection: 'login',
        documentId: 'saved',
      );
      final String? newToken = user == null ? null : user['token'];

      if (newToken != null) {
        await updateToken(newToken);
      } else {
        // If token refresh fails, you might want to log out the user
        await _localStoreService.deleteDocument(
            collection: 'login', documentId: 'saved');
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      debugPrint('Token Refresh Error: $e');
      rethrow;
    }
  }

  /// Handle potential GraphQL errors
  void _handleErrors(QueryResult result) {
    if (result.hasException) {
      final List<GraphQLError>? errors = result.exception?.graphqlErrors;

      if (errors != null && errors.isNotEmpty) {
        for (var error in errors) {
          debugPrint('GraphQL Error: ${error.message}');
        }
        throw Exception('GraphQL Query/Mutation Failed');
      }
    }
  }

  /// Perform a subscription
  Stream<QueryResult> performSubscription(
    String subscription, {
    Map<String, dynamic>? variables,
  }) {
    final SubscriptionOptions options = SubscriptionOptions(
      document: gql(subscription),
      variables: variables ?? {},
    );
    return _client.subscribe(options);
  }

  /* void refreshUserId() async {
    QueryResult login = await performQuery(r'''
		query Query($obtenerStudentIdToken2: String!) {
			obtenerStudentId(token: $obtenerStudentIdToken2)
		}
        ''',
        variables: {"obtenerStudentIdToken2": _currentToken},
        refreshTokenIfNeeded: false);
    userId = login.data?['obtenerStudentId'];
  } */
}
