import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class ShowsScreen extends StatefulWidget {
  const ShowsScreen({super.key});

  @override
  State<ShowsScreen> createState() => _ShowsScreenState();
}

class _ShowsScreenState extends State<ShowsScreen> {
  final _searchCtrl = TextEditingController();
  int? _movieFilter;
  int? _theaterFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowProvider>().fetchShows();
      context.read<MovieProvider>().fetchMovies();
      context.read<TheaterProvider>().fetchTheaters();
    });
  }

  void _openShowForm([ShowModel? show]) {
    showDialog(
      context: context,
      builder: (ctx) => _ShowFormDialog(show: show),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showProvider = context.watch<ShowProvider>();
    final movieProvider = context.watch<MovieProvider>();
    final theaterProvider = context.watch<TheaterProvider>();
    final nav = context.watch<NavigationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTableCard(
            title: 'Movie Show Schedules',
            subtitle: 'Schedule showtimes per screen with automated collision/overlap conflict detection',
            isLoading: showProvider.isLoading,
            trailingAction: ElevatedButton.icon(
              onPressed: () => _openShowForm(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Schedule Show'),
            ),
            searchAndFilters: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by movie or theater name...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                showProvider.fetchShows(search: '');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (v) => showProvider.fetchShows(search: v.trim()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<int?>(
                  value: _movieFilter,
                  dropdownColor: AppTheme.bgCard,
                  hint: const Text('All Movies'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Movies')),
                    ...movieProvider.movies.map((m) => DropdownMenuItem(value: m.id, child: Text(m.title, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) {
                    setState(() => _movieFilter = val);
                    showProvider.fetchShows(movieId: val);
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int?>(
                  value: _theaterFilter,
                  dropdownColor: AppTheme.bgCard,
                  hint: const Text('All Theaters'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Theaters')),
                    ...theaterProvider.theaters.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) {
                    setState(() => _theaterFilter = val);
                    showProvider.fetchShows(theaterId: val);
                  },
                ),
              ],
            ),
            child: showProvider.shows.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No shows scheduled matching filters')),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.bgSurface),
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 64,
                      columns: const [
                        DataColumn(label: Text('MOVIE')),
                        DataColumn(label: Text('VENUE & SCREEN')),
                        DataColumn(label: Text('SHOWTIME')),
                        DataColumn(label: Text('FORMAT & LANG')),
                        DataColumn(label: Text('BASE PRICE')),
                        DataColumn(label: Text('BOOKINGS')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: showProvider.shows.map((s) {
                        final dtStr = DateFormat('dd MMM yyyy, hh:mm a').format(s.showTime.toLocal());
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  if (s.movieImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(s.movieImage!, width: 28, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                                    ),
                                  const SizedBox(width: 10),
                                  Text(s.movieTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                            DataCell(Text('${s.theaterName}\n(${s.screenName})', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(dtStr, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text('${s.format} • ${s.language}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                            DataCell(Text('₹${s.basePrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(
                              InkWell(
                                onTap: () {
                                  nav.setTab(AdminNavTab.seatEditor, params: {'showId': s.id, 'screenId': s.screenId});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${s.bookingCount} Booked • Live Matrix',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(StatusBadge(status: s.status)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.event_seat_outlined, size: 18, color: AppTheme.secondary),
                                    tooltip: 'Live Seat Layout & Bookings',
                                    onPressed: () {
                                      nav.setTab(AdminNavTab.seatEditor, params: {'showId': s.id, 'screenId': s.screenId});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.error),
                                    tooltip: 'Cancel Show',
                                    onPressed: () async {
                                      final conf = await ConfirmationDialog.show(
                                        context,
                                        title: 'Cancel Show?',
                                        message: 'Are you sure you want to cancel the show for "${s.movieTitle}" at ${s.theaterName}?',
                                        confirmText: 'Cancel Show',
                                      );
                                      if (conf == true) {
                                        await showProvider.deleteShow(s.id);
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

class _ShowFormDialog extends StatefulWidget {
  final ShowModel? show;
  const _ShowFormDialog({this.show});

  @override
  State<_ShowFormDialog> createState() => _ShowFormDialogState();
}

class _ShowFormDialogState extends State<_ShowFormDialog> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedMovieId;
  int? _selectedTheaterId;
  int? _selectedScreenId;
  DateTime _showDate = DateTime.now().add(const Duration(hours: 4));
  TimeOfDay _showTime = const TimeOfDay(hour: 18, minute: 30);
  final _priceCtrl = TextEditingController(text: '250');
  String _language = 'English';
  String _format = '2D';
  String? _conflictError;

  @override
  void initState() {
    super.initState();
    final movies = context.read<MovieProvider>().movies;
    final theaters = context.read<TheaterProvider>().theaters;

    if (movies.isNotEmpty) _selectedMovieId = movies.first.id;
    if (theaters.isNotEmpty) {
      _selectedTheaterId = theaters.first.id;
      _loadScreens(theaters.first.id);
    }
  }

  void _loadScreens(int theaterId) async {
    await context.read<TheaterProvider>().fetchScreens(theaterId: theaterId);
    final screens = context.read<TheaterProvider>().screens.where((s) => s.theaterId == theaterId).toList();
    if (screens.isNotEmpty && mounted) {
      setState(() => _selectedScreenId = screens.first.id);
    }
  }

  void _schedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMovieId == null || _selectedScreenId == null) return;

    final fullDateTime = DateTime(
      _showDate.year,
      _showDate.month,
      _showDate.day,
      _showTime.hour,
      _showTime.minute,
    );

    final data = {
      'movieId': _selectedMovieId,
      'screenId': _selectedScreenId,
      'showTime': fullDateTime.toIso8601String(),
      'basePrice': double.tryParse(_priceCtrl.text.trim()) ?? 250.0,
      'language': _language,
      'format': _format,
      'status': 'active',
    };

    final err = await context.read<ShowProvider>().createShow(data);
    if (err != null && mounted) {
      setState(() => _conflictError = err);
    } else if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Show scheduled successfully!'), backgroundColor: AppTheme.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieProvider>().movies;
    final theaters = context.watch<TheaterProvider>().theaters;
    final screens = context.watch<TheaterProvider>().screens.where((s) => s.theaterId == _selectedTheaterId).toList();

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule Movie Show', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (_conflictError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _conflictError!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<int>(
                value: _selectedMovieId,
                dropdownColor: AppTheme.bgCard,
                decoration: const InputDecoration(labelText: 'Movie *'),
                items: movies.map((m) => DropdownMenuItem(value: m.id, child: Text(m.title))).toList(),
                onChanged: (v) => setState(() => _selectedMovieId = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedTheaterId,
                      dropdownColor: AppTheme.bgCard,
                      decoration: const InputDecoration(labelText: 'Theater Venue *'),
                      items: theaters.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedTheaterId = v;
                          if (v != null) _loadScreens(v);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedScreenId,
                      dropdownColor: AppTheme.bgCard,
                      decoration: const InputDecoration(labelText: 'Screen / Auditorium *'),
                      items: screens.map((s) => DropdownMenuItem(value: s.id, child: Text(s.screenName))).toList(),
                      onChanged: (v) => setState(() => _selectedScreenId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _showDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (d != null) setState(() => _showDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Show Date'),
                        child: Text(DateFormat('dd MMM yyyy').format(_showDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _showTime);
                        if (t != null) setState(() => _showTime = t);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Show Time'),
                        child: Text(_showTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Base Ticket Price (₹)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _format,
                      dropdownColor: AppTheme.bgCard,
                      decoration: const InputDecoration(labelText: 'Format'),
                      items: const [
                        DropdownMenuItem(value: '2D', child: Text('2D')),
                        DropdownMenuItem(value: '3D', child: Text('3D')),
                        DropdownMenuItem(value: 'IMAX 3D', child: Text('IMAX 3D')),
                        DropdownMenuItem(value: '4DX', child: Text('4DX')),
                      ],
                      onChanged: (v) => setState(() => _format = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _schedule, child: const Text('Save & Schedule')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
