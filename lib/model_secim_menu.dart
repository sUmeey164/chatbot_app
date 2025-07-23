import 'package:flutter/material.dart';

class ModelSecimMenu extends StatelessWidget {
  final String secilenModel;
  final Function(String) modelDegistir;

  const ModelSecimMenu({
    Key? key,
    required this.secilenModel,
    required this.modelDegistir,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modeller = ['ChatGPT', 'Gemini', 'DeepSeek', 'Chatbot'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: modeller.map((model) {
          final isSelected = model == secilenModel;
          return ListTile(
            title: Text(model),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => modelDegistir(model),
          );
        }).toList(),
      ),
    );
  }
}
