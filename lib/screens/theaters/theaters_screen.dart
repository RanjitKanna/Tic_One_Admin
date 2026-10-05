import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';

class TheatersScreen extends StatefulWidget {
  const TheatersScreen({super.key});

  @override
  State<TheatersScreen> createState() => _TheatersScreenState();
}

class _TheatersScreenState extends State<TheatersScreen> {
  final _searchCtrl = TextEditingController();
  int? _cityFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TheaterProvider>().fetchInitial();
    });
  }

  void _openTheaterForm([TheaterModel? theater]) {
    showDialog(
      context: context,
      builder: (ctx) => _TheaterFormDialog(theater: theater),
    );
  }

  void _openScreenManager(TheaterModel theater) {
    showDialog(
      context: context,
      builder: (ctx) => _ScreenManagerDialog(theater: theater),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TheaterProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTableCard(
            title: 'Theaters & Multiplex Management',
            subtitle: 'Configure cinema venues, screen auditoriums, seating layouts, formats and sound systems',
            isLoading: provider.isLoading,
            trailingAction: ElevatedButton.icon(
              onPressed: () => _openTheaterForm(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Theater'),
            ),
            searchAndFilters: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by theater name, landmark, address...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.fetchTheaters(search: '');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (v) => provider.fetchTheaters(search: v.trim()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int?>(
                  value: _cityFilter,
                  dropdownColor: AppTheme.bgCard,
                  hint: const Text('All Cities'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Cities')),
                    ...provider.cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (val) {
                    setState(() => _cityFilter = val);
                    provider.fetchTheaters(cityId: val);
                  },
                ),
              ],
            ),
            child: provider.theaters.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No theaters found')),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.bgSurface),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(label: Text('THEATER CODE')),
                        DataColumn(label: Text('THEATER NAME')),
                        DataColumn(label: Text('CITY')),
                        DataColumn(label: Text('SCREENS')),
                        DataColumn(label: Text('FORMATS')),
                        DataColumn(label: Text('ADDRESS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.theaters.map((t) {
                        return DataRow(
                          cells: [
                            DataCell(Text(t.theaterCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted, fontFamily: 'monospace'))),
                            DataCell(Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.borderLight.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(t.cityName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataCell(
                              InkWell(
                                onTap: () => _openScreenManager(t),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.tv_rounded, size: 14, color: AppTheme.secondary),
                                      const SizedBox(width: 4),
                                      Text('${t.screenCount} Screens', style: const TextStyle(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(t.formats ?? 'IMAX, Dolby Atmos', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                            DataCell(Text(t.address ?? t.landmark ?? '—', style: const TextStyle(fontSize: 12))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.meeting_room_outlined, size: 18, color: AppTheme.secondary),
                                    tooltip: 'Manage Screens & Seats',
                                    onPressed: () => _openScreenManager(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.info),
                                    tooltip: 'Edit Theater',
                                    onPressed: () => _openTheaterForm(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                                    tooltip: 'Delete Theater',
                                    onPressed: () => _deleteTheater(t),
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

  void _deleteTheater(TheaterModel theater) async {
    final conf = await ConfirmationDialog.show(
      context,
      title: 'Delete "${theater.name}"?',
      message: 'This will soft-delete the theater and its associated screens.',
      confirmText: 'Delete Theater',
    );
    if (conf == true && mounted) {
      await context.read<TheaterProvider>().deleteTheater(theater.id);
    }
  }
}

class _TheaterFormDialog extends StatefulWidget {
  final TheaterModel? theater;
  const _TheaterFormDialog({this.theater});

  @override
  State<_TheaterFormDialog> createState() => _TheaterFormDialogState();
}

class _TheaterFormDialogState extends State<_TheaterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _landmarkCtrl;
  late TextEditingController _formatsCtrl;
  int? _cityId;

  @override
  void initState() {
    super.initState();
    final t = widget.theater;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _addressCtrl = TextEditingController(text: t?.address ?? '');
    _landmarkCtrl = TextEditingController(text: t?.landmark ?? '');
    _formatsCtrl = TextEditingController(text: t?.formats ?? 'IMAX, Dolby Atmos 4K, 4DX');
    _cityId = t?.cityId ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _landmarkCtrl.dispose();
    _formatsCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cityId == null) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'cityId': _cityId,
      'address': _addressCtrl.text.trim(),
      'landmark': _landmarkCtrl.text.trim(),
      'formats': _formatsCtrl.text.trim(),
      if (widget.theater == null) 'autoGenerateSeats': true,
    };

    final provider = context.read<TheaterProvider>();
    bool success;
    if (widget.theater != null) {
      success = await provider.updateTheater(widget.theater!.id, data);
    } else {
      success = await provider.createTheater(data);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = context.watch<TheaterProvider>().cities;

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.theater != null ? 'Edit Theater' : 'Add New Theater',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Theater / Multiplex Name *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _cityId,
                dropdownColor: AppTheme.bgCard,
                decoration: const InputDecoration(labelText: 'City *'),
                items: cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _cityId = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _formatsCtrl,
                decoration: const InputDecoration(labelText: 'Supported Formats (e.g. IMAX, 4DX)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landmarkCtrl,
                decoration: const InputDecoration(labelText: 'Landmark / Area'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _save, child: const Text('Save Theater')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenManagerDialog extends StatefulWidget {
  final TheaterModel theater;
  const _ScreenManagerDialog({required this.theater});

  @override
  State<_ScreenManagerDialog> createState() => _ScreenManagerDialogState();
}

class _ScreenManagerDialogState extends State<_ScreenManagerDialog> {
  final _screenNameCtrl = TextEditingController(text: 'Screen 2');
  final _seatsCtrl = TextEditingController(text: '96');

  void _addScreen() async {
    if (_screenNameCtrl.text.trim().isEmpty) return;
    final provider = context.read<TheaterProvider>();
    await provider.createScreen({
      'theaterId': widget.theater.id,
      'screenName': _screenNameCtrl.text.trim(),
      'totalSeats': int.tryParse(_seatsCtrl.text.trim()) ?? 80,
      'autoGenerateSeats': true,
    });
    _screenNameCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final screens = context.watch<TheaterProvider>().screens.where((s) => s.theaterId == widget.theater.id).toList();

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Screens in ${widget.theater.name}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.border),
            const SizedBox(height: 12),

            // Add Screen Form inline
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _screenNameCtrl,
                    decoration: const InputDecoration(labelText: 'Screen Name (e.g. Audi 1 / IMAX Screen)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _seatsCtrl,
                    decoration: const InputDecoration(labelText: 'Total Capacity'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addScreen,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Screen'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: screens.isEmpty
                  ? const Center(child: Text('No screens configured yet.'))
                  : ListView.builder(
                      itemCount: screens.length,
                      itemBuilder: (ctx, i) {
                        final s = screens[i];
                        return Card(
                          color: AppTheme.bgSurface,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.tv_rounded, color: AppTheme.secondary, size: 20),
                            ),
                            title: Text(s.screenName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${s.totalSeats} seats configured'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.bgCard,
                                    foregroundColor: AppTheme.secondary,
                                    side: const BorderSide(color: AppTheme.secondary),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    nav.setTab(AdminNavTab.seatEditor, params: {'screenId': s.id});
                                  },
                                  icon: const Icon(Icons.event_seat_rounded, size: 14),
                                  label: const Text('Edit Seat Matrix', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                                  onPressed: () => context.read<TheaterProvider>().deleteScreen(s.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
