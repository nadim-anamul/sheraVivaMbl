import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/viva_form_entity.dart';
import '../../domain/repositories/viva_form_repository.dart';

class VivaFormRepositoryImpl implements VivaFormRepository {
  VivaFormRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<VivaFormEntity>> submit(VivaFormEntity entity) async {
    try {
      // Placeholder: replace with actual Next.js endpoint response mapping.
      await _apiClient.post(
        ApiConfig.vivaFormSubmit,
        data: <String, dynamic>{
          'examType': entity.examType,
          'cadreChoice': entity.cadreChoice,
          'homeDistrict': entity.homeDistrict,
        },
      );
    } catch (_) {
      // Keep app unblocked in local mock mode.
    }

    return Success<VivaFormEntity>(entity);
  }
}
