import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../data/world_map_paths.dart';
import '../models/map_models.dart';
import 'world_map_painter.dart';

class WorldMapWidget extends StatefulWidget {
  final Map<String, UserCountryData> userData;
  final Function(String countryId) onCountryTap;

  const WorldMapWidget({
    Key? key,
    required this.userData,
    required this.onCountryTap,
  }) : super(key: key);

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget> {
  List<ParsedMapGroup>? _parsedGroups;
  String? _hoveredCountryId;
  final TransformationController _transformationController = TransformationController();

  static const double _mapWidth = 1000.0;
  static const double _mapHeight = 500.0;

  @override
  void initState() {
    super.initState();
    _parsePaths();
  }

  void _parsePaths() {
    // Parse SVG paths efficiently in the background or just synchronously as it's around 188 paths.
    List<ParsedMapGroup> parsed = [];
    for (var group in worldMapData) {
      List<Path> groupPaths = [];
      for (var p in group.paths) {
        groupPaths.add(parseSvgPathData(p.d));
      }
      parsed.add(ParsedMapGroup(id: group.id, paths: groupPaths));
    }
    setState(() {
      _parsedGroups = parsed;
    });
  }

  void _handleTap(TapUpDetails details) {
    if (_parsedGroups == null) return;
    
    // details.localPosition is exactly in the 1000x500 coordinate space
    final point = details.localPosition;
    
    for (var group in _parsedGroups!) {
      for (var path in group.paths) {
        if (path.contains(point)) {
          widget.onCountryTap(group.id);
          return;
        }
      }
    }
  }

  void _handleHover(PointerEvent event) {
    if (_parsedGroups == null) return;
    
    final point = event.localPosition;
    String? foundId;
    
    for (var group in _parsedGroups!) {
      for (var path in group.paths) {
        if (path.contains(point)) {
          foundId = group.id;
          break;
        }
      }
      if (foundId != null) break;
    }

    if (foundId != _hoveredCountryId) {
      setState(() {
        _hoveredCountryId = foundId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedGroups == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute initial scale to fit the map horizontally
        final initialScale = constraints.maxWidth / _mapWidth;
        // Optionally center vertically if the screen is tall
        
        return InteractiveViewer(
          transformationController: _transformationController,
          constrained: false, // Let the map be its actual 1000x500 size
          minScale: initialScale * 0.5,
          maxScale: initialScale * 10,
          boundaryMargin: EdgeInsets.all(_mapWidth / 2),
          child: MouseRegion(
            onHover: _handleHover,
            onExit: (_) {
              setState(() {
                _hoveredCountryId = null;
              });
            },
            child: GestureDetector(
              onTapUp: _handleTap,
              child: CustomPaint(
                size: const Size(_mapWidth, _mapHeight),
                painter: WorldMapPainter(
                  parsedGroups: _parsedGroups!,
                  userData: widget.userData,
                  hoveredCountryId: _hoveredCountryId,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
