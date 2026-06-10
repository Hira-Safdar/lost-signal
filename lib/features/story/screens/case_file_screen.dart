import 'package:flutter/material.dart';
import 'package:lost_signal/shared/game/game_controller.dart';

class CaseFileScreen extends StatelessWidget {
  const CaseFileScreen({super.key});

  static const Map<String, _CaseFileEntry> _entries = {
    'badge': _CaseFileEntry(
      title: 'STUDENT ID',
      imagePath: 'assets/images/student_id.png',
      meaning: 'Confirms Nathan Kim reached Engineering Block alive.',
      unlock: 'Unlocks Admin verification path.',
    ),
    'notice': _CaseFileEntry(
      title: 'MISSING REPORT',
      imagePath: 'assets/images/missing_report.png',
      meaning: 'Proves the university already logged Nathan as missing.',
      unlock: 'Confirms the Admin route matters.',
    ),
    'archive_route': _CaseFileEntry(
      title: 'ARCHIVE ROUTE',
      imagePath: 'assets/images/horror_asset.png',
      meaning: 'Links the report trail to the archive side passage.',
      unlock: 'Unlocks the library search phase.',
    ),
    'logbook': _CaseFileEntry(
      title: 'BROKEN PHONE',
      imagePath: 'assets/images/broken_phone.png',
      meaning: 'Contains Nathan\'s unsent draft about a basement service door.',
      unlock: 'Confirms basement objective.',
    ),
    'photo': _CaseFileEntry(
      title: 'ARCHIVE PHOTO',
      imagePath: 'assets/images/horror_asset.png',
      meaning: 'Places Nathan in the library route the same night.',
      unlock: 'Supports the final route reconstruction.',
    ),
    'security_card': _CaseFileEntry(
      title: 'DORM SECURITY CARD',
      imagePath: 'assets/images/security_card.png',
      meaning: 'Shows unauthorized access tied to Nathan\'s dorm route.',
      unlock: 'Required before basement confrontation.',
    ),
    'keycard': _CaseFileEntry(
      title: 'BASEMENT KEY',
      imagePath: 'assets/images/old_key.png',
      meaning: 'Provides the final physical link to the service route below campus.',
      unlock: 'Completes Chapter 1 evidence chain.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final clues = game.save.collectedClueIds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panelDecoration(),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await GameScope.read(context).closeCaseFile();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: _panelDecoration(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF7CFF41),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CASE FILE',
                            style: TextStyle(
                              color: Color(0xFF7CFF41),
                              fontSize: 18,
                              letterSpacing: 1.4,
                            ),
                          ),
                          Text(
                            game.nextObjectiveLabel(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: clues.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: _panelDecoration(),
                        child: const Text(
                          'No evidence logged yet.',
                          style: TextStyle(
                            color: Color(0xFFBFFF9A),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: clues.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final clueId = clues[index];
                          final entry = _entries[clueId];
                          if (entry == null) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            decoration: _panelDecoration(),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: _panelDecoration(),
                                  child: Image.asset(entry.imagePath, fit: BoxFit.contain),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.title,
                                        style: const TextStyle(
                                          color: Color(0xFF7CFF41),
                                          fontSize: 14,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        entry.meaning,
                                        style: const TextStyle(
                                          color: Color(0xFFEAFAEA),
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        entry.unlock,
                                        style: const TextStyle(
                                          color: Color(0xFFBFFF9A),
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseFileEntry {
  const _CaseFileEntry({
    required this.title,
    required this.imagePath,
    required this.meaning,
    required this.unlock,
  });

  final String title;
  final String imagePath;
  final String meaning;
  final String unlock;
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: 0.34),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: 0.08),
        blurRadius: 16,
      ),
    ],
    color: const Color(0xFF020502).withValues(alpha: 0.84),
  );
}
