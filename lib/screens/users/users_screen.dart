import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../services/admin_api_service.dart';
import '../../services/api_client.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
    });
  }

  void _viewUserDetails(UserModel user) async {
    showDialog(
      context: context,
      builder: (ctx) => _UserDetailsDialog(userId: user.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTableCard(
            title: 'User Management',
            subtitle: 'Manage registered customer accounts, view booking history and permissions',
            isLoading: provider.isLoading,
            searchAndFilters: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone number...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.fetchUsers(search: '');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (val) => provider.fetchUsers(search: val.trim()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: AppTheme.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active Only')),
                    DropdownMenuItem(value: 'inactive', child: Text('Disabled Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _statusFilter = val);
                      provider.fetchUsers(status: val);
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _roleFilter,
                  dropdownColor: AppTheme.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Roles')),
                    DropdownMenuItem(value: 'user', child: Text('Customers')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _roleFilter = val);
                      provider.fetchUsers(role: val);
                    }
                  },
                ),
              ],
            ),
            child: provider.users.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No users match the search criteria')),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.bgSurface),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(label: Text('USER ID')),
                        DataColumn(label: Text('NAME')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('PHONE')),
                        DataColumn(label: Text('ROLE')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('REGISTERED')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.users.map((u) {
                        final createdStr = u.createdAt != null ? DateFormat('dd MMM yyyy').format(u.createdAt!.toLocal()) : 'N/A';
                        return DataRow(
                          cells: [
                            DataCell(Text('#${u.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted))),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppTheme.primary.withOpacity(0.15),
                                    child: Text(
                                      u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            DataCell(Text(u.email)),
                            DataCell(Text(u.phone ?? '—')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (u.role == 'admin' ? AppTheme.primary : AppTheme.border).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  u.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: u.role == 'admin' ? AppTheme.primary : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(StatusBadge(status: u.isActive ? 'active' : 'inactive')),
                            DataCell(Text(createdStr, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.secondary),
                                    tooltip: 'View Profile & Booking History',
                                    onPressed: () => _viewUserDetails(u),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      u.isActive ? Icons.block_rounded : Icons.check_circle_outline,
                                      size: 18,
                                      color: u.isActive ? AppTheme.warning : AppTheme.success,
                                    ),
                                    tooltip: u.isActive ? 'Disable User' : 'Enable User',
                                    onPressed: () async {
                                      final conf = await ConfirmationDialog.show(
                                        context,
                                        title: u.isActive ? 'Disable User Account?' : 'Enable User Account?',
                                        message: 'Are you sure you want to ${u.isActive ? "disable" : "enable"} ${u.name} (${u.email})?',
                                        confirmText: u.isActive ? 'Disable' : 'Enable',
                                        confirmColor: u.isActive ? AppTheme.warning : AppTheme.success,
                                      );
                                      if (conf == true) {
                                        await provider.toggleUserStatus(u.id, !u.isActive);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                                    tooltip: 'Delete User',
                                    onPressed: () async {
                                      final conf = await ConfirmationDialog.show(
                                        context,
                                        title: 'Delete User Account?',
                                        message: 'Are you sure you want to delete ${u.name}? This will perform a soft-delete.',
                                        confirmText: 'Delete User',
                                      );
                                      if (conf == true) {
                                        await provider.deleteUser(u.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final int userId;
  const _UserDetailsDialog({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<ApiResponse<Map<String, dynamic>>>(
          future: AdminApiService().getUserDetails(userId),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            final data = snapshot.data?.data;
            if (data == null) {
              return const Center(child: Text('User details not found'));
            }

            final user = data['user'] as Map<String, dynamic>;
            final movieBookings = (data['movieBookings'] as List?) ?? [];
            final busBookings = (data['busBookings'] as List?) ?? [];
            final payments = (data['payments'] as List?) ?? [];

            final isActive = user['isActive'] != false;
            final role = (user['role'] ?? 'user').toString();
            final createdAt = DateTime.tryParse(user['createdAt']?.toString() ?? '');
            final totalSpent = [...movieBookings, ...busBookings]
                .where((b) => b['bookingStatus'] != 'cancelled')
                .fold<double>(0, (sum, b) => sum + ((b['amount'] as num?)?.toDouble() ?? 0));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            (user['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 18, color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
                            Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile details
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DetailTile(label: 'USER ID', value: '#${user['id']}'),
                    _DetailTile(label: 'PHONE', value: user['phone']?.toString() ?? '—'),
                    _DetailTile(
                      label: 'ROLE',
                      value: role.toUpperCase(),
                      valueColor: role == 'admin' ? AppTheme.primary : null,
                    ),
                    _DetailTile(
                      label: 'STATUS',
                      value: isActive ? 'Active' : 'Disabled',
                      valueColor: isActive ? AppTheme.success : AppTheme.error,
                    ),
                    _DetailTile(
                      label: 'JOINED',
                      value: createdAt != null ? DateFormat('dd MMM yyyy').format(createdAt.toLocal()) : 'N/A',
                    ),
                    _DetailTile(label: 'BOOKINGS', value: '${movieBookings.length + busBookings.length}'),
                    _DetailTile(label: 'TOTAL SPENT', value: '₹${totalSpent.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 12),

                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: AppTheme.primary,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppTheme.textMuted,
                          tabs: [
                            Tab(text: 'Movie Bookings'),
                            Tab(text: 'Bus Bookings'),
                            Tab(text: 'Payment History'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Movie Bookings
                              movieBookings.isEmpty
                                  ? const Center(child: Text('No movie tickets booked'))
                                  : ListView.builder(
                                      itemCount: movieBookings.length,
                                      itemBuilder: (ctx, i) {
                                        final b = movieBookings[i];
                                        return Card(
                                          color: AppTheme.bgSurface,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            title: Text(b['movieTitle'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                            subtitle: Text('Code: ${b['bookingCode']} • ${b['seats']} seats • ₹${b['amount']}'),
                                            trailing: StatusBadge(status: b['bookingStatus'] ?? 'confirmed'),
                                          ),
                                        );
                                      },
                                    ),
                              // Bus Bookings
                              busBookings.isEmpty
                                  ? const Center(child: Text('No bus trips booked'))
                                  : ListView.builder(
                                      itemCount: busBookings.length,
                                      itemBuilder: (ctx, i) {
                                        final b = busBookings[i];
                                        return Card(
                                          color: AppTheme.bgSurface,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            title: Text(b['routeName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                            subtitle: Text('PNR: ${b['pnrNumber']} • ${b['seats']} seats • ₹${b['amount']}'),
                                            trailing: StatusBadge(status: b['bookingStatus'] ?? 'confirmed'),
                                          ),
                                        );
                                      },
                                    ),
                              // Payments
                              payments.isEmpty
                                  ? const Center(child: Text('No payment records'))
                                  : ListView.builder(
                                      itemCount: payments.length,
                                      itemBuilder: (ctx, i) {
                                        final p = payments[i];
                                        return Card(
                                          color: AppTheme.bgSurface,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            title: Text('${p['paymentMethod']} • ₹${p['amount']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                            subtitle: Text('Tx: ${p['transactionRef'] ?? 'N/A'}'),
                                            trailing: StatusBadge(status: p['status'] ?? 'completed'),
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
