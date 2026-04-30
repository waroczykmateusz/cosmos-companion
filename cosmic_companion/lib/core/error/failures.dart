sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

final class AstronomyFailure extends Failure {
  const AstronomyFailure(super.message);
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
