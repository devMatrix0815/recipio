import 'package:flutter/material.dart';

// model + service
import '../models/recipe.dart';
import '../services/recipe_service.dart';

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

        actions: [
          // delete button
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: "Rezept löschen",
            onPressed: () async {
              // use recipe service
              await RecipeService().delete(recipe.id);

              // go back to my recipes
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ingridients section
            Text(
              'Zutaten',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            // space + ingridients
            const SizedBox(height: 8.0),
            ...recipe.ingredients.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // [space] - Circle - [Space] - Ingridient
                    const SizedBox(width: 24.0),
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 16.0),
                    Text(
                      '${recipe.amount[entry.key]} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.value),
                  ],
                ),
              ),
            ),

            // big space
            const SizedBox(height: 32.0),

            // steps section
            Text(
              'Zubereitung',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            // space + steps
            const SizedBox(height: 8.0),
            ...recipe.steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [space] - number - step
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
        destinations: [
          NavigationDestination(icon: Icon(Icons.book), label: 'Meine Rezepte'),
          NavigationDestination(icon: Icon(Icons.search), label: 'SOON'),
        ],
      ),
    );
  }
}
