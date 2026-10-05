import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

class DataTableCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailingAction;
  final Widget? searchAndFilters;
  final Widget? child;
  final List<DataColumn>? columns;
  final List<DataRow>? rows;
  final bool isLoading;

  const DataTableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingAction,
    this.searchAndFilters,
    this.child,
    this.columns,
    this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingAction != null) trailingAction!,
              ],
            ),
          ),
          if (searchAndFilters != null) ...[
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: searchAndFilters!,
            ),
          ],
          const Divider(height: 1, color: AppTheme.border),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (child != null)
            child!
          else if (columns != null && rows != null)
            rows!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 40, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No records found',
                            style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.bgDark),
                      headingTextStyle: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      dataTextStyle: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      dividerThickness: 1,
                      horizontalMargin: 20,
                      columnSpacing: 24,
                      columns: columns!,
                      rows: rows!,
                    ),
                  )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
