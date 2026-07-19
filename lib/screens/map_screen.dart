import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../widgets/world_map_widget.dart';
import '../widgets/stat_strip.dart';
import '../widgets/sidebar_widget.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 860;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas - Carnet de voyage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, child) {
          final mapWidget = WorldMapWidget(
            userData: provider.userData,
            onCountryTap: provider.selectCountry,
          );

          return Column(
            children: [
              const StatStrip(),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: mapWidget),
                          const SizedBox(
                            width: 340,
                            child: SidebarWidget(),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          SizedBox(
                            height: 400,
                            child: mapWidget,
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SidebarWidget(),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


