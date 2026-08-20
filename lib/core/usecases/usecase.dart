import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meet_action/core/errors/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
