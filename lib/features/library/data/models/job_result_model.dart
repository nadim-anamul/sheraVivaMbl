import 'package:equatable/equatable.dart';

class JobResultModel extends Equatable {
  final String id;
  final String title;
  final String organization;
  final String publishDate;
  final String pdfUrl;
  final String fileSize;
  final String description;

  const JobResultModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.publishDate,
    required this.pdfUrl,
    required this.fileSize,
    required this.description,
  });

  factory JobResultModel.fromJson(Map<String, dynamic> json) {
    return JobResultModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      publishDate: json['publishDate'] as String? ?? '',
      pdfUrl: json['pdfUrl'] as String? ?? '',
      fileSize: json['fileSize'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'publishDate': publishDate,
      'pdfUrl': pdfUrl,
      'fileSize': fileSize,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, title, organization, publishDate, pdfUrl, fileSize, description];
}
