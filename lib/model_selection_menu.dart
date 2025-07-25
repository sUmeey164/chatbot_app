// lib/model_selection_menu.dart // Renamed file
import 'package:flutter/material.dart';

class ModelSelectionMenu extends StatelessWidget {
  // Renamed class
  final String selectedModel; // Renamed secilenModel
  final Function(String) changeModel; // Renamed modelDegistir

  const ModelSelectionMenu({
    Key? key,
    required this.selectedModel, // Renamed secilenModel
    required this.changeModel, // Renamed modelDegistir
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final models = [
      'ChatGPT',
      'Gemini',
      'DeepSeek',
      'Chatbot',
    ]; // Renamed modeller

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: models.map((model) {
          // Renamed modeller
          final isSelected = model == selectedModel; // Renamed secilenModel
          return ListTile(
            title: Text(model),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => changeModel(model), // Renamed modelDegistir
          );
        }).toList(),
      ),
    );
  }
}
