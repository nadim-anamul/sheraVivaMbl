import '../../../../core/result/result.dart';
import '../entities/viva_form_entity.dart';

abstract class VivaFormRepository {
  Future<Result<VivaFormEntity>> submit(VivaFormEntity entity);
}
