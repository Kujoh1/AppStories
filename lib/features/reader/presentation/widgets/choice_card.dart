import 'package:flutter/material.dart';
import '../../../../domain/models/choice.dart';
import '../../../../core/constants/app_constants.dart';

/// Card widget for displaying a story choice
class ChoiceCard extends StatelessWidget {
  final Choice choice;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.choice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (choice.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        choice.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display a list of choices
class ChoicesList extends StatelessWidget {
  final List<Choice> choices;
  final ValueChanged<Choice> onChoiceSelected;

  const ChoicesList({
    super.key,
    required this.choices,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Text(
            'Wähle deinen Weg:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...choices.map(
          (choice) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            child: ChoiceCard(
              choice: choice,
              onTap: () => onChoiceSelected(choice),
            ),
          ),
        ),
      ],
    );
  }
}


