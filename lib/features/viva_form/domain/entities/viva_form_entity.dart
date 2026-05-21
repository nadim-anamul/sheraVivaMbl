import 'package:equatable/equatable.dart';

class VivaFormEntity extends Equatable {
  const VivaFormEntity({
    required this.examType,
    required this.cadreChoice,
    required this.homeDistrict,
  });

  final String examType;
  final String cadreChoice;
  final String homeDistrict;

  @override
  List<Object> get props => <Object>[examType, cadreChoice, homeDistrict];
}
