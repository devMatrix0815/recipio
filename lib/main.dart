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

// model for a recipe
class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({required this.name, required this.ingredients, required this.steps});
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
  final List<Recipe> _recipes = [
    Recipe(
      name: 'Pasta',
      ingredients: ['Nudeln', 'Tomaten', 'Knoblauch'],
      steps: [
        'Nudeln kochen',
        'Tomaten und Knoblauch anbraten',
        'Nudeln mit Sauce vermischen',
      ],
    ),
    Recipe(
      name: 'Pizza',
      ingredients: ['Teig', 'Tomatensoße', 'Käse'],
      steps: ['Teig ausrollen', 'Tomatensoße aufteilen', 'Käse auftragen'],
    ),
    Recipe(
      name: 'Salat',
      ingredients: ['Salatblätter', 'Tomaten', 'Gurken'],
      steps: [
        'Salatblätter waschen',
        'Tomaten und Gurken schneiden',
        'Salat mischen',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // only show recipes that match the search
    final filtered = _recipes
        .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
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

            // Recipe list
            const SizedBox(height: 32.0),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () => debugPrint('Card tapped.'),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),

                        // Recipe title and description
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // title of the recipe
                                  Text(
                                    filtered[index].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),

                                  // space between title and description
                                  const SizedBox(height: 4.0),

                                  // description of the recipe
                                  Text(
                                    filtered[index].ingredients.join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // right arrow icon
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => debugPrint('Add recipe.'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
