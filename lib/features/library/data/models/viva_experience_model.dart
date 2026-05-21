class VivaExperienceModel {
  final String id;
  final String examType; // "BCS" or "Primary"
  final String title;
  final String edition;
  final String year;
  final String candidateName;
  final String subject;
  final String district;
  final String upazila;
  final String board;
  final List<String> choices;
  final String duration;
  final String result;
  final String experienceRating;
  final String remarks;
  final List<TranscriptTurn> transcript;

  VivaExperienceModel({
    required this.id,
    required this.examType,
    required this.title,
    required this.edition,
    required this.year,
    required this.candidateName,
    required this.subject,
    required this.district,
    required this.upazila,
    required this.board,
    required this.choices,
    required this.duration,
    required this.result,
    required this.experienceRating,
    required this.remarks,
    required this.transcript,
  });

  factory VivaExperienceModel.fromJson(Map<String, dynamic> json) {
    final transcriptList = json['transcript'] as List? ?? [];
    final List<TranscriptTurn> parsedTranscript = transcriptList
        .map((e) => TranscriptTurn.fromJson(e as Map<String, dynamic>))
        .toList();

    final choicesList = json['choices'] as List? ?? [];
    final List<String> parsedChoices = choicesList.map((e) => e.toString()).toList();

    return VivaExperienceModel(
      id: json['id'] as String? ?? '',
      examType: json['examType'] as String? ?? '',
      title: json['title'] as String? ?? '',
      edition: json['edition'] as String? ?? '',
      year: json['year'] as String? ?? '',
      candidateName: json['candidateName'] as String? ?? 'বেনামী',
      subject: json['subject'] as String? ?? 'সাধারণ/অন্যান্য',
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String? ?? '',
      board: json['board'] as String? ?? '',
      choices: parsedChoices,
      duration: json['duration'] as String? ?? '',
      result: json['result'] as String? ?? '',
      experienceRating: json['experienceRating'] as String? ?? 'Good',
      remarks: json['remarks'] as String? ?? '',
      transcript: parsedTranscript,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examType': examType,
      'title': title,
      'edition': edition,
      'year': year,
      'candidateName': candidateName,
      'subject': subject,
      'district': district,
      'upazila': upazila,
      'board': board,
      'choices': choices,
      'duration': duration,
      'result': result,
      'experienceRating': experienceRating,
      'remarks': remarks,
      'transcript': transcript.map((e) => e.toJson()).toList(),
    };
  }
}

class TranscriptTurn {
  final String speaker; // "Chairman" | "Board Member" | "Candidate"
  final String text;

  TranscriptTurn({
    required this.speaker,
    required this.text,
  });

  factory TranscriptTurn.fromJson(Map<String, dynamic> json) {
    return TranscriptTurn(
      speaker: json['speaker'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
    };
  }
}
