import 'package:flutter/material.dart';
import '../../data/models/viva_experience_model.dart';

class VivaTranscriptPage extends StatefulWidget {
  final VivaExperienceModel experience;

  const VivaTranscriptPage({super.key, required this.experience});

  @override
  State<VivaTranscriptPage> createState() => _VivaTranscriptPageState();
}

class _VivaTranscriptPageState extends State<VivaTranscriptPage> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.experience.examType == 'BCS'
        ? const Color(0xFF0F766E)
        : const Color(0xFF1E3A8A);

    // Filter dialogue turns based on local search query
    final filteredTurns = widget.experience.transcript.where((turn) {
      if (_searchQuery.isEmpty) return true;
      return turn.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          turn.speaker.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.experience.candidateName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 16,
              ),
            ),
            Text(
              widget.experience.examType == 'BCS'
                  ? '${widget.experience.edition} বিসিএস ভাইভা'
                  : 'প্রাথমিক শিক্ষক ভাইভা',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      body: Column(
        children: [
          // Search bar inside the transcript
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: ' কথোপকথন খুঁজুন...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeColor, width: 1.5),
                ),
              ),
            ),
          ),

          // Scrollable chat dialogue
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Top Information Card (Remarks & Highlights)
                _buildHighlightsCard(themeColor),
                const SizedBox(height: 24),

                // Dialogue Label
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ভাইভা কথোপকথন শুরু',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                  ],
                ),
                const SizedBox(height: 20),

                // Chat bubble list
                if (filteredTurns.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? 'এই শব্দের কোনো কথোপকথন পাওয়া যায়নি।' : 'কোনো কথোপকথন রেকর্ড করা নেই।',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredTurns.map((turn) => _buildChatBubble(turn, themeColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Highlights / Advice block at top of transcript
  Widget _buildHighlightsCard(Color themeColor) {
    final exp = widget.experience;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: themeColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                'ক্যান্ডিডেট হাইলাইটস ও পরামর্শ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata Grid list
          _buildInfoRow(Icons.account_balance_rounded, 'ভাইভা বোর্ড', exp.board.isNotEmpty ? exp.board : 'সাধারণ বোর্ড'),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.book_rounded, 'পঠিত বিষয়', exp.subject),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.timer_rounded, 'ভাইভা সময়কাল', exp.duration),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          if (exp.result.isNotEmpty && exp.result != 'ফলাফল পাওয়া যায়নি') ...[
            _buildInfoRow(Icons.emoji_events_rounded, 'ফলাফল', exp.result, isSuccess: true),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ],

          // Remarks if exists
          if (exp.remarks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: themeColor, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'পরামর্শ / মন্তব্য:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exp.remarks,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {bool isSuccess = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 10),
        Text(
          '$title:  ',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSuccess ? const Color(0xFF15803D) : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. CHAT BUBBLE VIEW ---
  Widget _buildChatBubble(TranscriptTurn turn, Color themeColor) {
    final bool isCandidate = turn.speaker.toLowerCase() == 'candidate';

    // Highlight text segments matching the query
    Widget textWidget = _buildHighlightedText(turn.text);

    if (isCandidate) {
      // Candidate: Right aligned, Teal/Blue gradient
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 32),
        key: ValueKey('candidate-${turn.text.hashCode}'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 4),
                    child: Text(
                      'আমি (প্রার্থী)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColor, themeColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                      child: textWidget,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: themeColor.withOpacity(0.1),
              child: Icon(Icons.person_rounded, color: themeColor, size: 16),
            ),
          ],
        ),
      );
    } else {
      // Board Member: Left aligned, Slate background
      final String speakerName = turn.speaker == 'Chairman' ? 'চেয়ারম্যান স্যার' : 'বোর্ড মেম্বার';
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 32),
        key: ValueKey('board-${turn.text.hashCode}'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE2E8F0),
              child: Icon(
                turn.speaker == 'Chairman' ? Icons.assignment_ind_rounded : Icons.supervised_user_circle_rounded,
                color: const Color(0xFF475569),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      speakerName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                      child: textWidget,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // Helper function to highlight text matching local query
  Widget _buildHighlightedText(String text) {
    if (_searchQuery.isEmpty) return Text(text);

    final String query = _searchQuery.toLowerCase();
    final String lowercaseText = text.toLowerCase();
    
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery = lowercaseText.indexOf(query, start);

    while (indexOfQuery != -1) {
      // Add text before match
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
      }

      // Add matching highlighted text
      spans.add(TextSpan(
        text: text.substring(indexOfQuery, indexOfQuery + query.length),
        style: const TextStyle(
          backgroundColor: Colors.yellowAccent,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = indexOfQuery + query.length;
      indexOfQuery = lowercaseText.indexOf(query, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14.5, height: 1.45),
        children: spans,
      ),
    );
  }
}
