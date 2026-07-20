import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/map_models.dart';
import '../../data/countries.dart';
import '../../data/cities.dart';
import 'panel_widget.dart';
import '../../theme/app_theme.dart';

class DetailPanel extends StatelessWidget {
  const DetailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final selectedId = provider.selectedCountryId;
        
        if (selectedId == null) {
          return PanelWidget(
            title: 'Pays sélectionné', // We could translate this too but let's just do it
            child: Text(
              'Cliquez sur un pays de la carte, ou utilisez la recherche, pour voir ses détails et ajouter un voyage.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        final countryInfo = countriesData[selectedId];
        final name = countryInfo?.getName(localeProvider.currentLocale) ?? selectedId;
        
        final currentData = provider.userData[selectedId];
        final isVisited = currentData?.status == CountryStatus.visited;
        final isLived = currentData?.status == CountryStatus.lived;
        final isWish = currentData?.status == CountryStatus.wishlist;
        final isRedlist = currentData?.status == CountryStatus.redlist;

        return PanelWidget(
          title: 'Pays sélectionné',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVisited ? AppTheme.countryVisited : Theme.of(context).cardColor,
                      foregroundColor: isVisited ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isVisited ? AppTheme.countryVisited : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isVisited ? CountryStatus.none : CountryStatus.visited);
                    },
                    child: Text(isVisited ? '${tr(context, 'visited')} ✓' : tr(context, 'mark_visited')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLived ? AppTheme.countryLived : Theme.of(context).cardColor,
                      foregroundColor: isLived ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isLived ? AppTheme.countryLived : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isLived ? CountryStatus.none : CountryStatus.lived);
                    },
                    child: Text(isLived ? '${tr(context, 'lived')} ✓' : tr(context, 'mark_lived')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWish ? AppTheme.countryWishlist : Theme.of(context).cardColor,
                      foregroundColor: isWish ? Theme.of(context).colorScheme.surfaceTint : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isWish ? AppTheme.countryWishlist : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isWish ? CountryStatus.none : CountryStatus.wishlist);
                    },
                    child: Text(isWish ? '${tr(context, 'wishlist')} ✓' : tr(context, 'add_wishlist')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRedlist ? AppTheme.countryRedlistHover : Theme.of(context).cardColor,
                      foregroundColor: isRedlist ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: isRedlist ? AppTheme.countryRedlistHover : Theme.of(context).colorScheme.outline),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      provider.markCountryStatus(selectedId, isRedlist ? CountryStatus.none : CountryStatus.redlist);
                    },
                    child: Text(isRedlist ? '${tr(context, 'redlist')} ✓' : tr(context, 'add_redlist')),
                  ),
                ],
              ),
              if (isRedlist) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.countryRedlistHover.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.countryRedlistHover.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.countryRedlistHover, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr(context, 'redlist_info'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (currentData != null && (currentData.status == CountryStatus.visited || currentData.status == CountryStatus.lived)) ...[
                const SizedBox(height: 24),
                _CitiesSection(
                  countryId: selectedId,
                  cities: currentData.cities,
                  provider: provider,
                ),
                const SizedBox(height: 24),
                _NotesSection(
                  countryId: selectedId,
                  notes: currentData.notes,
                  provider: provider,
                ),
                const SizedBox(height: 24),
                _PhotosSection(
                  countryId: selectedId,
                  photos: currentData.photos,
                  provider: provider,
                ),
              ],
              if (currentData != null && currentData.status != CountryStatus.none) ...[
                const SizedBox(height: 16),
                Divider(color: Theme.of(context).colorScheme.outline),
                TextButton(
                  onPressed: () {
                    provider.removeCountryData(selectedId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: Text(tr(context, 'remove_country')),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
class _CitiesSection extends StatefulWidget {
  final String countryId;
  final List<String> cities;
  final MapProvider provider;

  const _CitiesSection({
    Key? key,
    required this.countryId,
    required this.cities,
    required this.provider,
  }) : super(key: key);

  @override
  State<_CitiesSection> createState() => _CitiesSectionState();
}

class _CitiesSectionState extends State<_CitiesSection> {
  final TextEditingController _controller = TextEditingController();

  void _addCity(String val) {
    final text = val.trim();
    if (text.isNotEmpty && !widget.cities.contains(text)) {
      final newCities = List<String>.from(widget.cities)..add(text);
      widget.provider.updateCities(widget.countryId, newCities);
      _controller.clear();
    }
  }

  void _removeCity(String city) {
    final newCities = List<String>.from(widget.cities)..remove(city);
    widget.provider.updateCities(widget.countryId, newCities);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'cities_visited'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.cities.map((city) {
            return Chip(
              label: Text(city),
              onDeleted: () => _removeCity(city),
              backgroundColor: Theme.of(context).colorScheme.outline,
              deleteIconColor: Colors.grey,
              side: BorderSide.none,
              labelStyle: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.all(4),
            );
          }).toList(),
        ),
        if (widget.cities.isNotEmpty) const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            final countryCities = citiesData[widget.countryId] ?? [];
            return countryCities
                .map((c) => c.name)
                .where((name) => name.toLowerCase().contains(query))
                .take(10);
          },
          onSelected: (String selection) {
            _addCity(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: tr(context, 'add_city'),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.countryVisited),
                  onPressed: () {
                     _addCity(controller.text);
                     controller.clear();
                  },
                ),
              ),
              onSubmitted: (val) {
                _addCity(val);
                controller.clear();
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(option, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NotesSection extends StatefulWidget {
  final String countryId;
  final String? notes;
  final MapProvider provider;

  const _NotesSection({
    Key? key,
    required this.countryId,
    required this.notes,
    required this.provider,
  }) : super(key: key);

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notes ?? '');
  }
  
  @override
  void didUpdateWidget(_NotesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryId != widget.countryId) {
      _controller.text = widget.notes ?? '';
      _isEditing = false;
    }
  }

  void _save() {
    final text = _controller.text.trim();
    widget.provider.updateNotes(widget.countryId, text);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasNotes = widget.notes != null && widget.notes!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr(context, 'journal'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (hasNotes && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () => setState(() => _isEditing = true),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isEditing || !hasNotes) ...[
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Vos souvenirs, anecdotes, ou impressions...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.countryVisited,
                foregroundColor: Theme.of(context).colorScheme.surfaceTint,
              ),
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.notes!,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotosSection extends StatefulWidget {
  final String countryId;
  final List<String>? photos;
  final MapProvider provider;

  const _PhotosSection({
    Key? key,
    required this.countryId,
    required this.photos,
    required this.provider,
  }) : super(key: key);

  @override
  State<_PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<_PhotosSection> {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await image.readAsBytes();
      final extension = image.name.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';

      final url = await widget.provider.uploadPhoto(widget.countryId, bytes, fileName);
      if (url != null) {
        widget.provider.addPhoto(widget.countryId, url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'upload: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr(context, 'photos'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo, color: Colors.grey, size: 20),
              onPressed: _isUploading ? null : _pickAndUploadImage,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (photos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.photo_library, color: Colors.grey, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Aucune photo',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Cliquez sur l'icône en haut pour uploader des images de ce pays.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final photoUrl = photos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => widget.provider.removePhoto(widget.countryId, photoUrl),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
