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
  final List<String> ingredientsPreview;
  final List<String> steps;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.ingredientsPreview,
    required this.steps,
  });
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
      name: 'Schokomuffins',
      ingredients: [
        '125 g weiche Butter',
        '150 g Zucker',
        '1 Pck. Vanillezucker',
        '2 Eier',
        '200 g Zartbitterschokolade',
        '200 g Mehl',
        '4 EL Backkakao',
        '1 Prise Salz',
        '2 TL Backpulver',
        '175 ml Milch',
      ],
      ingredientsPreview: [
        'weiche Butter',
        'Zucker',
        'Vanillezucker',
        'Eier',
        'Zartbitterschokolade',
        'Mehl',
        'Backkakao',
        'Salz',
        'Backpulver',
        'Milch',
      ],
      steps: [
        'Butter mit Zucker und Vanillezucker verrühren. Eier unterrühren. Zartbitterschokolade grob hacken. Ofen auf 180 Grad (Umluft: 160 Grad) vorheizen. Mehl mit Kakaopulver, Salz und Backpulver vermischen. Mehlmischung mit der Milch zur Butter-Zuckermischung geben und alles gut verrühren. Etwa zwei Drittel der gehackten Schokolade unterheben.',
        'Die Mulden eines Muffinblechs mit Förmchen auslegen. Mit einem Eisportionierer den Teig auf die Förmchen verteilen. Die restlichen gehackten Schokostückchen auf den Muffins verteilen. Im vorgeheizten Ofen ca. 25 Min backen.',
      ],
    ),
    Recipe(
      name: 'Pizza',
      ingredients: ['Teig', '500g Tomatensoße', '200g Käse'],
      ingredientsPreview: ['Teig', 'Tomatensoße', 'Käse'],
      steps: ['Teig ausrollen', 'Tomatensoße aufteilen', 'Käse auftragen'],
    ),
    Recipe(
      name: 'Salat',
      ingredients: ['Salatblätter', 'Tomaten', 'Gurken'],
      ingredientsPreview: ['Salatblätter', 'Tomaten', 'Gurken'],
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetail(recipe: filtered[index]),
                          ),
                        );
                      },

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
                                    filtered[index].ingredientsPreview.join(
                                      ', ',
                                    ),
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

// detail page for a recipe
class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetail({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          recipe.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ingredients section
            Text(
              'Zutaten',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8.0),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24.0),
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 16.0),
                    Text(ingredient),
                  ],
                ),
              ),
            ),

            // space between ingredients and steps
            const SizedBox(height: 32.0),

            // steps section
            Text(
              'Zubereitung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8.0),
            ...recipe.steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 24.0),
                    SizedBox(
                      width: 24.0,
                      child: Text(
                        '${entry.key + 1}.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
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
    );
  }
}
