sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    }
    return failure((self as FailureResult<T>).message);
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.message);

  final String message;
}
