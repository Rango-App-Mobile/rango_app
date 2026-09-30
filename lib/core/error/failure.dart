/// Errors the ViewModel knows how to show. Repositories translate
/// Firebase/HTTP exceptions into one of these; the View never sees raw ones.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Algo deu errado.']);
}
