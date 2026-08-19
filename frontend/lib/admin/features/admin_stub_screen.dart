import 'package:material_ui/material_ui.dart';

class AdminStubScreen extends StatelessWidget {
  const AdminStubScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}
