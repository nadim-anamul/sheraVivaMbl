import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../data/repositories/viva_form_repository_impl.dart';
import '../../domain/entities/viva_form_entity.dart';
import '../../domain/repositories/viva_form_repository.dart';
import '../../domain/usecases/submit_viva_form_usecase.dart';

final vivaFormRepositoryProvider = Provider<VivaFormRepository>((Ref ref) {
  return VivaFormRepositoryImpl(ref.watch(apiClientProvider));
});

final submitVivaFormUseCaseProvider = Provider<SubmitVivaFormUseCase>((Ref ref) {
  return SubmitVivaFormUseCase(ref.watch(vivaFormRepositoryProvider));
});

class VivaFormState {
  const VivaFormState({
    this.examType,
    this.cadreChoice,
    this.homeDistrict,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final String? examType;
  final String? cadreChoice;
  final String? homeDistrict;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  bool get isValid =>
      examType != null && cadreChoice != null && homeDistrict != null;

  VivaFormState copyWith({
    String? examType,
    String? cadreChoice,
    String? homeDistrict,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return VivaFormState(
      examType: examType ?? this.examType,
      cadreChoice: cadreChoice ?? this.cadreChoice,
      homeDistrict: homeDistrict ?? this.homeDistrict,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class VivaFormController extends StateNotifier<VivaFormState> {
  VivaFormController(this._submitVivaFormUseCase)
      : super(const VivaFormState());

  final SubmitVivaFormUseCase _submitVivaFormUseCase;

  void setExamType(String value) {
    state = state.copyWith(examType: value, errorMessage: null);
  }

  void setCadreChoice(String value) {
    state = state.copyWith(cadreChoice: value, errorMessage: null);
  }

  void setHomeDistrict(String value) {
    state = state.copyWith(homeDistrict: value, errorMessage: null);
  }

  Future<Result<VivaFormEntity>> submit() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'সব তথ্য পূরণ করুন');
      return const FailureResult<VivaFormEntity>('সব তথ্য পূরণ করুন');
    }

    state = state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null);

    final payload = VivaFormEntity(
      examType: state.examType!,
      cadreChoice: state.cadreChoice!,
      homeDistrict: state.homeDistrict!,
    );

    final result = await _submitVivaFormUseCase(payload);

    return result.when(
      success: (entity) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        );
        return Success<VivaFormEntity>(entity);
      },
      failure: (message) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: message,
        );
        return FailureResult<VivaFormEntity>(message);
      },
    );
  }
}

final vivaFormProvider =
    StateNotifierProvider<VivaFormController, VivaFormState>(
  (Ref ref) => VivaFormController(ref.watch(submitVivaFormUseCaseProvider)),
);
