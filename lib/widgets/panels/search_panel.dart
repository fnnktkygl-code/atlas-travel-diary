import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panel_widget.dart';
import '../../theme/app_theme.dart';
import '../../data/countries.dart';
import '../../providers/map_provider.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({Key? key}) : super(key: key);

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      title: 'Rechercher un pays',
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          final query = textEditingValue.text.toLowerCase();
          return countriesData.entries
              .where((entry) => entry.value.name.toLowerCase().contains(query))
              .map((entry) => entry.key);
        },
        displayStringForOption: (String id) => countriesData[id]?.name ?? id,
        onSelected: (String id) {
          context.read<MapProvider>().selectCountry(id);
          _controller.clear();
          _focusNode.unfocus();
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          // Sync controllers for clearing
          if (_controller.text != controller.text) {
            controller.text = _controller.text;
          }
          controller.addListener(() {
            _controller.text = controller.text;
          });

          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Cliquez ou tapez pour chercher...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: AppTheme.ink1,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.mapStroke),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.mapStroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.countryVisited),
              ),
            ),
            style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: AppTheme.panelBg,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppTheme.mapStroke),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final id = options.elementAt(index);
                    final name = countriesData[id]?.name ?? id;
                    return ListTile(
                      title: Text(name, style: const TextStyle(color: AppTheme.textColor)),
                      onTap: () => onSelected(id),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
