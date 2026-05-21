import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/viva_form_provider.dart';

class VivaFormPage extends ConsumerWidget {
  const VivaFormPage({super.key});

  static const List<String> _examTypes = <String>[
    'BCS',
    'Bank Job',
    'Primary Teacher',
    'University Lecturer',
  ];

  static const List<String> _cadreChoices = <String>[
    'Administration',
    'Police',
    'Foreign Affairs',
    'Education',
    'Customs & VAT',
  ];

  static const List<String> _districts = <String>[
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vivaFormProvider);

    ref.listen<VivaFormState>(vivaFormProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('ফর্ম সফলভাবে সাবমিট হয়েছে'),
              ],
            ),
            backgroundColor: const Color(0xFF047857), // emerald-700
          ),
        );
      }
    });

    // Calculate completed steps for the visual progress bar
    int completedSteps = 0;
    if (state.examType != null && state.examType!.isNotEmpty) completedSteps++;
    if (state.cadreChoice != null && state.cadreChoice!.isNotEmpty) completedSteps++;
    if (state.homeDistrict != null && state.homeDistrict!.isNotEmpty) completedSteps++;
    final double completionProgress = completedSteps / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ভাইভা নিবন্ধন ফর্ম',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Step Progress Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.08)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'প্রস্তুতি অগ্রগতি',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F766E),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$completedSteps / ৩ তথ্য সম্পন্ন',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section Header
            const Text(
              'প্রার্থী তথ্য ও লক্ষ্য',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'সঠিক মক ভাইভা প্রিপারেশন অর্কেস্ট্রেশনের জন্য নিচের তথ্যগুলো পূরণ করুন।',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Curved Main Form Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown 1: Exam Type
                  const Text(
                    'পরীক্ষার ধরন (Exam Type)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: state.examType,
                    decoration: InputDecoration(
                      hintText: 'পরীক্ষা নির্বাচন করুন',
                      prefixIcon: const Icon(Icons.school_outlined, size: 20, color: Color(0xFF0F766E)),
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: _examTypes
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(vivaFormProvider.notifier).setExamType(value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dropdown 2: Cadre Choice
                  const Text(
                    'কাঙ্ক্ষিত ক্যাডার (Cadre Choice)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: state.cadreChoice,
                    decoration: InputDecoration(
                      hintText: 'ক্যাডার পছন্দ নির্বাচন করুন',
                      prefixIcon: const Icon(Icons.stars_outlined, size: 20, color: Color(0xFF0F766E)),
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: _cadreChoices
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(vivaFormProvider.notifier).setCadreChoice(value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dropdown 3: Home District
                  const Text(
                    'নিজ জেলা (Home District)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: state.homeDistrict,
                    decoration: InputDecoration(
                      hintText: 'জেলা নির্বাচন করুন',
                      prefixIcon: const Icon(Icons.map_outlined, size: 20, color: Color(0xFF0F766E)),
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: _districts
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(vivaFormProvider.notifier).setHomeDistrict(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      ref.read(vivaFormProvider.notifier).submit();
                    },
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'নিবন্ধন নিশ্চিত করুন',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
