import 'package:ezsports/features/matches/presentation/screens/create_match_screen.dart';
import 'package:ezsports/features/matches/presentation/widgets/empty_matches.dart';
import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: EmptyMatches(
        onCreate: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CreateMatchScreen()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CreateMatchScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
