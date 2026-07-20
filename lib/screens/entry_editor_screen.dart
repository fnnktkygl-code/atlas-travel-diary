import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/map_models.dart';
import '../providers/map_provider.dart';
import '../providers/locale_provider.dart';
import '../data/cities.dart';
import '../theme/app_theme.dart';

class EntryEditorScreen extends StatefulWidget {
  final String countryCode;
  final JournalEntry? existingEntry;

  const EntryEditorScreen({
    Key? key,
    required this.countryCode,
    this.existingEntry,
  }) : super(key: key);

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _cityController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    _titleController = TextEditingController(text: e?.title ?? '');
    _cityController = TextEditingController(text: e?.city ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _selectedDate = e?.date ?? DateTime.now();
    _photos = e != null ? List.from(e.photoUrls) : [];
  }

  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final provider = Provider.of<MapProvider>(context, listen: false);
    setState(() => _isUploading = true);
    try {
      final url = await provider.uploadPhotoWithPicker(widget.countryCode);
      if (url != null) {
        setState(() {
          _photos.add(url);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _save() {
    final provider = Provider.of<MapProvider>(context, listen: false);
    
    final entry = JournalEntry(
      id: widget.existingEntry?.id ?? const Uuid().v4(),
      countryCode: widget.countryCode,
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      date: _selectedDate,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      note: _noteController.text.trim(),
      photoUrls: _photos,
    );

    if (widget.existingEntry == null) {
      provider.addEntry(entry);
    } else {
      provider.updateEntry(entry);
    }
    
    // Also ensure country has at least 'visited' status if not already tracked
    final currentStatus = provider.userData[widget.countryCode]?.status ?? CountryStatus.none;
    if (currentStatus == CountryStatus.none || currentStatus == CountryStatus.wishlist || currentStatus == CountryStatus.redlist) {
      provider.markCountryStatus(widget.countryCode, CountryStatus.visited);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCities = citiesData[widget.countryCode]?.map((c) => c.name).toList() ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.existingEntry == null ? tr(context, 'add_memory') : tr(context, 'edit_memory')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(tr(context, 'save'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(_selectedDate)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: tr(context, 'title_optional'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // City Autocomplete
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return availableCities.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _cityController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // sync controller
                if (_cityController.text.isNotEmpty && controller.text.isEmpty) {
                  controller.text = _cityController.text;
                }
                controller.addListener(() {
                  _cityController.text = controller.text;
                });
                
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: tr(context, 'city_optional'),
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: tr(context, 'notes'),
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context, 'photos'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _isUploading ? null : _pickAndUploadImage,
                ),
              ],
            ),
            if (_isUploading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
            if (_photos.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(_photos[index], fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _photos.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
