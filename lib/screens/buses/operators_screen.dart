import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';

class OperatorsScreen extends StatefulWidget {
  const OperatorsScreen({super.key});

  @override
  State<OperatorsScreen> createState() => _OperatorsScreenState();
}

class _OperatorsScreenState extends State<OperatorsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusProvider>().fetchOperators();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = context.watch<BusProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          AdminHeader(
            title: 'Bus Operators Management',
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_business_rounded, size: 18),
              label: Text('Add Operator', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              onPressed: () => _showOperatorFormDialog(context),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search operators by company name or code...',
                              hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        busProvider.fetchOperators(search: '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              filled: true,
                              fillColor: AppTheme.bgCard,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            ),
                            onSubmitted: (val) {
                              busProvider.fetchOperators(search: val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                          tooltip: 'Refresh operators',
                          onPressed: () => busProvider.fetchOperators(search: _searchCtrl.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Operators Table
                  DataTableCard(
                    title: 'Registered Bus Operators (${busProvider.operators.length})',
                    isLoading: busProvider.isLoading,
                    columns: const [
                      DataColumn(label: Text('OPERATOR')),
                      DataColumn(label: Text('CODE')),
                      DataColumn(label: Text('RATING')),
                      DataColumn(label: Text('ACTIVE BUSES')),
                      DataColumn(label: Text('CONTACT INFO')),
                      DataColumn(label: Text('POLICY')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: busProvider.operators.map((op) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                                  backgroundImage: (op.logoUrl != null && op.logoUrl!.startsWith('http'))
                                      ? NetworkImage(op.logoUrl!)
                                      : null,
                                  child: (op.logoUrl == null || !op.logoUrl!.startsWith('http'))
                                      ? Text(
                                          op.name.isNotEmpty ? op.name[0].toUpperCase() : 'O',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  op.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.bgDark,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                op.operatorCode,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  op.rating.toStringAsFixed(1),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${op.totalReviews})',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${op.busCount} Buses',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (op.contactNumber != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 12, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        op.contactNumber!,
                                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                if (op.email != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 12, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        op.email!,
                                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 140,
                              child: Text(
                                op.cancellationPolicy ?? 'Standard 24h cancellation',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                                  tooltip: 'Edit Operator',
                                  onPressed: () => _showOperatorFormDialog(context, op: op),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                                  tooltip: 'Delete Operator',
                                  onPressed: () => _confirmDeleteOperator(context, op),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOperatorFormDialog(BuildContext context, {BusOperatorModel? op}) {
    final formKey = GlobalKey<FormState>();
    final isEdit = op != null;
    final nameCtrl = TextEditingController(text: op?.name ?? '');
    final logoCtrl = TextEditingController(text: op?.logoUrl ?? '');
    final phoneCtrl = TextEditingController(text: op?.contactNumber ?? '');
    final emailCtrl = TextEditingController(text: op?.email ?? '');
    final policyCtrl = TextEditingController(text: op?.cancellationPolicy ?? 'Full refund 12 hours before departure; 50% refund within 6-12 hours.');
    double rating = op?.rating ?? 4.7;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.border),
              ),
              title: Row(
                children: [
                  const Icon(Icons.add_business_rounded, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text('Register Bus Operator', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Operator / Agency Name *',
                            hintText: 'e.g. SRS Travels, Orange Tours',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: logoCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Logo Image URL',
                            hintText: 'https://...',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: phoneCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Contact Phone',
                                  hintText: '+91 98765 43210',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: emailCtrl,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Contact Email',
                                  hintText: 'ops@operator.com',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.bgDark,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: policyCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Cancellation Policy',
                            labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.bgDark,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(isEdit ? 'Save Changes' : 'Save Operator', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    Navigator.pop(ctx);

                    final data = {
                      'name': nameCtrl.text.trim(),
                      'logoUrl': logoCtrl.text.trim().isNotEmpty ? logoCtrl.text.trim() : null,
                      'contactNumber': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                      'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                      'cancellationPolicy': policyCtrl.text.trim(),
                      'rating': rating,
                    };

                    final provider = context.read<BusProvider>();
                    final success = isEdit ? await provider.updateOperator(op.id, data) : await provider.createOperator(data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                          content: Text(success ? (isEdit ? 'Operator updated successfully!' : 'Operator registered successfully!') : (isEdit ? 'Failed to update operator.' : 'Failed to register operator.')),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteOperator(BuildContext context, BusOperatorModel op) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Operator ${op.name}?',
      message: 'Are you sure you want to delete this bus operator? All affiliated buses and scheduled trips will be deactivated.',
      confirmLabel: 'Delete Operator',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<BusProvider>().deleteOperator(op.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? AppTheme.success : AppTheme.error,
            content: Text(success ? 'Operator removed.' : 'Failed to delete operator.'),
          ),
        );
      }
    }
  }
}
