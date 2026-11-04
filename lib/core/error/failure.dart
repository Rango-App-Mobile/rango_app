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

final class LocationDeniedFailure extends Failure {
  const LocationDeniedFailure([
    super.message = 'Sem permissão de localização.',
  ]);
}

final class LocationDeniedForeverFailure extends Failure {
  const LocationDeniedForeverFailure([
    super.message = 'A localização está bloqueada nos ajustes.',
  ]);
}

final class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure([
    super.message = 'A localização do celular está desligada.',
  ]);
}
