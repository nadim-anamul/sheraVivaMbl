import '../../../../core/result/result.dart';
import '../entities/viva_form_entity.dart';
import '../repositories/viva_form_repository.dart';

class SubmitVivaFormUseCase {
  const SubmitVivaFormUseCase(this._repository);

  final VivaFormRepository _repository;

  Future<Result<VivaFormEntity>> call(VivaFormEntity entity) {
    return _repository.submit(entity);
  }
}
