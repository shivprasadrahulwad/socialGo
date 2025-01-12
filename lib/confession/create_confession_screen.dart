import 'package:flutter/material.dart';
import 'package:social/widgets/custom_toggle_button.dart';

class CreateConfessionScreen extends StatefulWidget {
  const CreateConfessionScreen({Key? key}) : super(key: key);

  @override
  State<CreateConfessionScreen> createState() => _CreateConfessionScreenState();
}

class _CreateConfessionScreenState extends State<CreateConfessionScreen> {
  final TextEditingController _confessionController = TextEditingController();
  bool isAnonymous = true;
  String selectedCategory = '';
  String selectedVisibility = '24 Hours';
  bool isNSFW = false;
  final int maxCharacters = 500;

  final List<String> categories = [
    'Academic Life',
    'Campus Love',
    'Roommates',
    'College Life',
    'Study Tips',
    'Party Scene',
    'Mental Health',
    'Career',
  ];

  final List<String> visibilityOptions = [
    '24 Hours',
    '48 Hours',
    '1 Week',
    'Forever',
  ];

  @override
  void dispose() {
    _confessionController.dispose();
    super.dispose();
  }

  void _submitConfession() {
    // Implement confession submission logic
    if (_confessionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your confession first!')),
      );
      return;
    }

    if (selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // Add your submission logic here
    print('Confession submitted!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Confession',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // actions: [
        //   TextButton(
        //     onPressed: _submitConfession,
        //     child: const Text(
        //       'Post',
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         fontSize: 16,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Settings Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacy Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anonymous Post',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hide your identity',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          CustomToggleButton(
                            isToggled: isAnonymous,
                            onTap: () {
                              setState(() {
                                isAnonymous = !isAnonymous;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      SizedBox(height: 10,),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Visibility Duration',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        value: selectedVisibility,
                        items: visibilityOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedVisibility = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confession Input Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _confessionController,
                        maxLength: maxCharacters,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Share your confession...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15)), // Added radius here
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((category) {
                          return ChoiceChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            selectedColor: Colors.blue.shade100,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: selectedCategory == category
                                  ? Colors.blue
                                  : Colors.black,
                              fontWeight: selectedCategory == category
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            showCheckmark: false,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = selected ? category : '';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Guidelines Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Guidelines',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Keep it respectful and avoid harmful content\n'
                        '• Do not share personal information\n'
                        '• No hate speech or harassment\n'
                        '• No spam or promotional content',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
    onPressed: _submitConfession,
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Icon(
      Icons.send,
      color: Colors.white,
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
);
  }
}
