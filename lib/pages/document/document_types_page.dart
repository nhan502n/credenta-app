import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_layout.dart';
import 'document_scan_page.dart'; // 👈 import trang đích

class DocumentTypesPage extends StatelessWidget {
  const DocumentTypesPage({super.key});

  static const _types = <String>[
    'Passport',
    'Driver license',
    'National ID',
    'Residence Permit',
    'Social Security Card',
    'Birth Certificate',
    'Military ID',
    'Voter ID Card',
    'Work Permit',
    'Student ID',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 380;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppLayout.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar: centered title + close (X) at right
              SizedBox(
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Document types',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isNarrow ? 20 : 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 38, height: 38),
                        icon: const Icon(Icons.close, color: AppColors.brandOrange, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // List
              Expanded(
                child: ListView.separated(
                  itemCount: _types.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.brandCream.withOpacity(0.35),
                  ),
                  itemBuilder: (context, i) {
                    final label = _types[i];
                    return InkWell(
                      onTap: () {
                        // 👉 Điều hướng sang trang scan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentScanPage(type: label),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
