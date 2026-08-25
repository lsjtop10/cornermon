import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

import 'itinerary_status_card.dart';

class ItineraryStatusList extends StatelessWidget {
  const ItineraryStatusList({
    required this.itinerary,
    required this.cornerNames,
    super.key,
  });

  final Iterable<api.CornerProgress> itinerary;
  final Map<String, String> cornerNames;

  @override
  Widget build(BuildContext context) {
    final items = itinerary.toList();
    if (items.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.route_outlined),
          title: Text('순회표가 아직 없습니다'),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _itineraryColumnCount(constraints.maxWidth),
          mainAxisSpacing: AppSpacing.space2,
          crossAxisSpacing: AppSpacing.space2,
          childAspectRatio: 2.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => ItineraryStatusCard(
          progress: items[index],
          cornerName: cornerNames[items[index].cornerId],
        ),
      ),
    );
  }
}

int _itineraryColumnCount(double width) {
  if (width >= 800) return 5;
  if (width >= 600) return 4;
  if (width >= 400) return 3;
  return 2;
}
