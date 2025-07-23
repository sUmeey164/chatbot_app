import 'package:flutter/material.dart';

class MesajGirisAlani extends StatelessWidget {
  final TextEditingController mesajController;
  final String? dosyaAdi;
  final VoidCallback onDosyaSecimDialogAc;
  final ValueChanged<String> onMesajGonder;
  final ValueChanged<String> onDosyaAdiGuncelle;

  const MesajGirisAlani({
    Key? key,
    required this.mesajController,
    this.dosyaAdi,
    required this.onDosyaSecimDialogAc,
    required this.onMesajGonder,
    required this.onDosyaAdiGuncelle,
    required void Function(String mesaj) mesajGonderVeGetir,
    required void Function() dosyaSecimDialogAc,
    required Color Function() mesajRengi,
  }) : super(key: key);

  Color _mesajRengi() {
    // Burada istersen tema veya dışarıdan renk alabilirsin.
    // Ama genelde dışarıdan parametre olarak da verilebilir.
    return Colors.deepPurple; // Örnek sabit renk
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dosyaAdi != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dosyaAdi!,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      onDosyaAdiGuncelle('');
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: mesajController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Mesaj yaz...",
                    hintStyle: TextStyle(color: _mesajRengi().withOpacity(0.7)),
                    filled: true,
                    fillColor: _mesajRengi().withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.attach_file, color: _mesajRengi()),
                      onPressed: onDosyaSecimDialogAc,
                    ),
                  ),
                  onSubmitted: onMesajGonder,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: _mesajRengi()),
                onPressed: () => onMesajGonder(mesajController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
