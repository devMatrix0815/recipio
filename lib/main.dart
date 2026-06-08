// imports
import 'package:flutter/material.dart';

// Run the app
void main() {
  runApp(const MyApp());
}

// root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const MyRecipes(),
    );
  }
}

// home page of the application
class MyRecipes extends StatefulWidget {
  const MyRecipes({super.key});

  @override
  State<MyRecipes> createState() => _MyRecipesState();
}

class _MyRecipesState extends State<MyRecipes> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // later fetch this from a database
  final List<String> _recipes = ['Pasta', 'Pizza', 'Salat'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // only show recipes that match the search
    final filtered = _recipes
        .where((r) => r.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Meine Rezepte',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
        child: Column(
          children: [
            SearchBar(
              controller: _searchController,
              hintText: 'Rezept suchen...',
              elevation: const WidgetStatePropertyAll(0),

              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainer,
              ),

              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),

              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),

              onChanged: (value) => setState(() => _query = value),
              leading: const Icon(Icons.search),
            ),

            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(filtered[index])),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: '...'),
        ],
      ),
    );
  }
}
