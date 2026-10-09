import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_badge.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchMovies();
    });
  }

  void _openMovieForm([MovieModel? movie]) {
    showDialog(
      context: context,
      builder: (ctx) => _MovieFormDialog(movie: movie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTableCard(
            title: 'Movie Catalogue Management',
            subtitle: 'Add, update, or retire films, configure posters, banners, trailers, cast and release statuses',
            isLoading: provider.isLoading,
            trailingAction: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: AppTheme.textSecondary),
                  tooltip: _isGridView ? 'Switch to Table' : 'Switch to Grid',
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _openMovieForm(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add New Movie'),
                ),
              ],
            ),
            searchAndFilters: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by title, genre, language...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.fetchMovies(search: '');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (v) => provider.fetchMovies(search: v.trim()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: AppTheme.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'now_showing', child: Text('Now Showing')),
                    DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'ended', child: Text('Ended')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _statusFilter = val);
                      provider.fetchMovies(status: val);
                    }
                  },
                ),
              ],
            ),
            child: provider.movies.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No movies found')),
                  )
                : _isGridView
                    ? _buildMovieGrid(provider.movies)
                    : _buildMovieTable(provider.movies),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(List<MovieModel> movies) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final count = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: 0.62,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (ctx, i) {
              final m = movies[i];
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            m.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.bgDark,
                              child: const Icon(Icons.movie, size: 40, color: AppTheme.textMuted),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: StatusBadge(status: m.status),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.genre} • ${m.language}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('${m.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.secondary),
                                      onPressed: () => _openMovieForm(m),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.error),
                                      onPressed: () => _deleteMovie(m),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMovieTable(List<MovieModel> movies) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppTheme.bgSurface),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('POSTER')),
          DataColumn(label: Text('TITLE')),
          DataColumn(label: Text('GENRE & LANG')),
          DataColumn(label: Text('DURATION')),
          DataColumn(label: Text('RATING')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('RELEASE DATE')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: movies.map((m) {
          return DataRow(
            cells: [
              DataCell(
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    m.imageUrl,
                    width: 36,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 36, height: 48, color: AppTheme.bgDark),
                  ),
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (m.format.isNotEmpty)
                      Text(m.format, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              DataCell(Text('${m.genre}\n${m.language}', style: const TextStyle(fontSize: 12))),
              DataCell(Text('${m.durationMins} mins')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${m.rating} (${m.ratingCount})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              DataCell(StatusBadge(status: m.status)),
              DataCell(Text(m.releaseDate, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.secondary),
                      tooltip: 'Edit Movie',
                      onPressed: () => _openMovieForm(m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                      tooltip: 'Delete Movie',
                      onPressed: () => _deleteMovie(m),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _deleteMovie(MovieModel movie) async {
    final conf = await ConfirmationDialog.show(
      context,
      title: 'Delete "${movie.title}"?',
      message: 'This will soft-delete the movie and mark its status as ended.',
      confirmText: 'Delete Movie',
    );
    if (conf == true && mounted) {
      final success = await context.read<MovieProvider>().deleteMovie(movie.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie deleted successfully'), backgroundColor: AppTheme.success),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete movie'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}

class _MovieFormDialog extends StatefulWidget {
  final MovieModel? movie;
  const _MovieFormDialog({this.movie});

  @override
  State<_MovieFormDialog> createState() => _MovieFormDialogState();
}

class _MovieFormDialogState extends State<_MovieFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _slugCtrl;
  late TextEditingController _genreCtrl;
  late TextEditingController _languageCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _ratingCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _bannerUrlCtrl;
  late TextEditingController _trailerUrlCtrl;
  late TextEditingController _castCtrl;
  late TextEditingController _directorCtrl;
  late TextEditingController _synopsisCtrl;
  late TextEditingController _releaseDateCtrl;
  String _status = 'now_showing';
  String _certificate = 'UA';
  bool _isTrending = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleCtrl = TextEditingController(text: m?.title ?? '');
    _slugCtrl = TextEditingController(text: m?.slug ?? '');
    _genreCtrl = TextEditingController(text: m?.genre ?? 'Action / Sci-Fi');
    _languageCtrl = TextEditingController(text: m?.language ?? 'English');
    _durationCtrl = TextEditingController(text: m != null ? '${m.durationMins}' : '120');
    _ratingCtrl = TextEditingController(text: m != null ? '${m.rating}' : '8.5');
    _imageUrlCtrl = TextEditingController(text: m?.imageUrl ?? 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800');
    _bannerUrlCtrl = TextEditingController(text: m?.bannerUrl ?? '');
    _trailerUrlCtrl = TextEditingController(text: m?.trailerUrl ?? '');
    _castCtrl = TextEditingController(text: m?.cast ?? '');
    _directorCtrl = TextEditingController(text: m?.director ?? '');
    _synopsisCtrl = TextEditingController(text: m?.synopsis ?? '');
    _releaseDateCtrl = TextEditingController(text: m?.releaseDate ?? DateTime.now().toIso8601String().substring(0, 10));
    _status = m?.status ?? 'now_showing';
    _certificate = m?.certificate ?? 'UA';
    _isTrending = m?.isTrending ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _slugCtrl.dispose();
    _genreCtrl.dispose();
    _languageCtrl.dispose();
    _durationCtrl.dispose();
    _ratingCtrl.dispose();
    _imageUrlCtrl.dispose();
    _bannerUrlCtrl.dispose();
    _trailerUrlCtrl.dispose();
    _castCtrl.dispose();
    _directorCtrl.dispose();
    _synopsisCtrl.dispose();
    _releaseDateCtrl.dispose();
    super.dispose();
  }

  void _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _titleCtrl.text.trim(),
      'slug': _slugCtrl.text.trim(),
      'genre': _genreCtrl.text.trim(),
      'language': _languageCtrl.text.trim(),
      'durationMins': int.tryParse(_durationCtrl.text.trim()) ?? 120,
      'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 8.0,
      'certificate': _certificate,
      'status': _status,
      'imageUrl': _imageUrlCtrl.text.trim(),
      'bannerUrl': _bannerUrlCtrl.text.trim(),
      'trailerUrl': _trailerUrlCtrl.text.trim(),
      'cast': _castCtrl.text.trim(),
      'director': _directorCtrl.text.trim(),
      'synopsis': _synopsisCtrl.text.trim(),
      'releaseDate': _releaseDateCtrl.text.trim(),
      'isTrending': _isTrending,
    };

    final provider = context.read<MovieProvider>();
    bool success;
    if (widget.movie != null) {
      success = await provider.updateMovie(widget.movie!.id, data);
    } else {
      success = await provider.createMovie(data);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.movie != null ? 'Movie updated successfully' : 'Movie added successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? (widget.movie != null ? 'Failed to update movie' : 'Failed to add movie')),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Movie Details' : 'Add New Movie',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.border),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(labelText: 'Movie Title *'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _releaseDateCtrl,
                            decoration: const InputDecoration(labelText: 'Release Date (YYYY-MM-DD) *'),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              final valid = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
                                  DateTime.tryParse(value) != null;
                              return valid ? null : 'Use YYYY-MM-DD';
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _genreCtrl,
                            decoration: const InputDecoration(labelText: 'Genre'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _languageCtrl,
                            decoration: const InputDecoration(labelText: 'Language'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationCtrl,
                            decoration: const InputDecoration(labelText: 'Duration (Minutes)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _ratingCtrl,
                            decoration: const InputDecoration(labelText: 'Rating (0.0 - 10.0)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _certificate,
                            dropdownColor: AppTheme.bgCard,
                            decoration: const InputDecoration(labelText: 'Certificate'),
                            items: const [
                              DropdownMenuItem(value: 'U', child: Text('U')),
                              DropdownMenuItem(value: 'UA', child: Text('UA')),
                              DropdownMenuItem(value: 'A', child: Text('A')),
                            ],
                            onChanged: (v) => setState(() => _certificate = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            dropdownColor: AppTheme.bgCard,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: const [
                              DropdownMenuItem(value: 'now_showing', child: Text('Now Showing')),
                              DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                              DropdownMenuItem(value: 'ended', child: Text('Ended')),
                            ],
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Trending Flag', style: TextStyle(fontSize: 13)),
                            value: _isTrending,
                            activeColor: AppTheme.primary,
                            onChanged: (v) => setState(() => _isTrending = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Poster Image URL *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Image URL is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bannerUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Banner Image URL (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _castCtrl,
                      decoration: const InputDecoration(labelText: 'Cast Members (e.g. Timothée Chalamet, Zendaya)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _directorCtrl,
                      decoration: const InputDecoration(labelText: 'Director (e.g. Denis Villeneuve)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _synopsisCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Synopsis / Description'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveMovie,
                    child: Text(isEdit ? 'Save Changes' : 'Create Movie'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
