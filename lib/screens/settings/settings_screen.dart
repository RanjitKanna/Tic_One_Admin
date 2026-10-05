import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().fetchLogs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final auditProvider = context.watch<AuditProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          AdminHeader(
            title: 'System Settings & Audit Trail',
            trailing: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Security & Audit Logs'),
                  Tab(text: 'System Environment'),
                ],
                onTap: (idx) => setState(() {}),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_tabController.index == 0)
                    _buildAuditLogsView(auditProvider)
                  else
                    _buildSystemEnvironmentView(auth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsView(AuditProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Card
        DataTableCard(
          title: 'Immutable Admin Activity Trail (${provider.logs.length})',
          isLoading: provider.isLoading,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('ADMIN EMAIL')),
            DataColumn(label: Text('ACTION')),
            DataColumn(label: Text('TARGET ENTITY')),
            DataColumn(label: Text('TIMESTAMP')),
            DataColumn(label: Text('PAYLOAD / DETAILS')),
          ],
          rows: provider.logs.map((log) {
            return DataRow(
              cells: [
                DataCell(Text('#${log.id}', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12))),
                DataCell(
                  Text(
                    log.adminEmail ?? 'admin@ticone.com',
                    style: GoogleFonts.plusJakartaSans(color: AppTheme.accentTeal, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
                DataCell(
                  StatusBadge(
                    status: log.action.toUpperCase(),
                    type: log.action.contains('DELETE')
                        ? StatusBadgeType.danger
                        : log.action.contains('CREATE')
                            ? StatusBadgeType.success
                            : StatusBadgeType.primary,
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.bgDark, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.border)),
                    child: Text(
                      '${log.entityType} ${log.entityId != null ? "#${log.entityId}" : ""}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                    style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.code_rounded, size: 18, color: AppTheme.accentPurple),
                    tooltip: 'Inspect Payload',
                    onPressed: () => _showPayloadInspector(context, log),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSystemEnvironmentView(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dns_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System & Architecture Overview', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('High-performance Dart Frog backend & PostgreSQL relational engine', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppTheme.border, height: 32),
              _configRow('Backend Base URL', ApiConfig.baseUrl),
              _configRow('Admin API Namespace', '${ApiConfig.baseUrl}/api/admin'),
              _configRow('Architecture Model', 'Flutter Web Admin → Dart Frog REST APIs → PostgreSQL'),
              _configRow('Authentication Mechanism', 'Bearer JWT HMAC-SHA256 (24-Hour Expiry)'),
              _configRow('Active Administrator', auth.user != null ? '${auth.user!.name} (${auth.user!.email})' : 'Super Admin'),
              _configRow('Role & Permissions', 'SUPER_ADMIN (Full Read/Write/Audit Authority)'),
              _configRow('Soft Delete Safety', 'Enabled for Users, Movies, Theaters, Buses & Trips'),
              _configRow('Schedule Conflict Guard', 'Enabled (Active Collision Interception on Screen/Time)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _configRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 240,
            child: Text(label, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPayloadInspector(BuildContext context, AuditLogModel log) {
    String formattedDetails = '{}';
    try {
      if (log.details is Map || log.details is List) {
        formattedDetails = const JsonEncoder.withIndent('  ').convert(log.details);
      } else if (log.details != null) {
        formattedDetails = log.details.toString();
      }
    } catch (_) {
      formattedDetails = log.details.toString();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
          title: Row(
            children: [
              const Icon(Icons.terminal_rounded, color: AppTheme.accentPurple),
              const SizedBox(width: 10),
              Text('Audit Payload #${log.id}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Container(
            width: 550,
            height: 320,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                formattedDetails,
                style: GoogleFonts.jetBrainsMono(color: AppTheme.accentTeal, fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(child: Text('Close', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)), onPressed: () => Navigator.pop(ctx)),
          ],
        );
      },
    );
  }
}
