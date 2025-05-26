import 'package:flutter/material.dart';

class ProgramListPage extends StatefulWidget {
  const ProgramListPage({super.key});

  @override
  State<ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<ProgramListPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _programs = [
    'KARDEŞLER FITNESS SPECIAL',
    'PUSH-PULL LEGS',
    'FULL BODY',
    'ORTAYA KARIŞIK',
  ];

  void _addProgram() {
    final text = _controller.text.trim().toUpperCase();
    if (text.isNotEmpty) {
      setState(() {
        _programs.add(text);
        _controller.clear();
      });
    }
  }

  void _removeProgram(int index) {
    setState(() {
      _programs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Program Adı',
                style: TextStyle(
                  color: Color(0xFFC1FF72),
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addProgram(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _addProgram,
                    child: Text(
                      'Ekle',
                      style: TextStyle(
                        color: Color(0xFFC1FF72),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: _programs.length,
                  itemBuilder: (context, index) {
                    final program = _programs[index];
                    return Dismissible(
                      key: Key(program),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _removeProgram(index),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                program,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(0xFFC1FF72),
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
