import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:social/models/poll.dart';
import 'package:social/poll/poll_widget.dart';
import 'package:social/widgets/custom_check_box.dart';
import 'package:social/widgets/custom_text_field.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final FocusNode _questionFocusNode = FocusNode();
  final List<FocusNode> _optionFocusNodes = [];
  bool _allowMultipleAnswers = false;
  TextEditingController? _currentEmojiController;
  bool _showEmojiPicker = false;
  final PollService _pollService = PollService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize focus nodes for options
    for (var i = 0; i < _optionControllers.length; i++) {
      _optionFocusNodes.add(FocusNode());
    }
    
    // Add listeners to all initial controllers
    for (var controller in _optionControllers) {
      _addControllerListener(controller);
    }

    // Add listeners to focus nodes
    _questionFocusNode.addListener(_onFocusChange);
    for (var focusNode in _optionFocusNodes) {
      focusNode.addListener(_onFocusChange);
    }
  }

  Future<void> _savePoll() async {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    // Filter out empty options
    final validOptions = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 options')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final poll = Poll(
        question: _questionController.text.trim(),
        options: validOptions,
        multiple: _allowMultipleAnswers,
      );

      await _pollService.addPoll(poll);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating poll: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onFocusChange() {
    // If any text field gains focus, close the emoji picker
    if (_questionFocusNode.hasFocus || _optionFocusNodes.any((node) => node.hasFocus)) {
      if (_showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    }
  }

  void _showEmojiPickerBottomSheet(TextEditingController controller) {
    // Unfocus any text field when emoji picker is shown
    FocusScope.of(context).unfocus();
    
    setState(() {
      _currentEmojiController = controller;
      _showEmojiPicker = true;
    });
  }

  void _addControllerListener(TextEditingController controller) {
    controller.addListener(() {
      // Check if this is the last controller and it has text
      if (controller == _optionControllers.last && controller.text.isNotEmpty) {
        _addOption();
      }
    });
  }

  void _addOption() {
    setState(() {
      final newController = TextEditingController();
      final newFocusNode = FocusNode();
      newFocusNode.addListener(_onFocusChange);
      _addControllerListener(newController);
      _optionControllers.add(newController);
      _optionFocusNodes.add(newFocusNode);
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _questionFocusNode.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    if (_currentEmojiController != null) {
      final currentText = _currentEmojiController!.text;
      final cursorPosition = _currentEmojiController!.selection.base.offset;
      
      if (cursorPosition >= 0) {
        final newText = currentText.substring(0, cursorPosition) + 
                       emoji.emoji + 
                       currentText.substring(cursorPosition);
        _currentEmojiController!.text = newText;
        _currentEmojiController!.selection = TextSelection.collapsed(
          offset: cursorPosition + emoji.emoji.length
        );
      } else {
        _currentEmojiController!.text = currentText + emoji.emoji;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keyboard
        FocusScope.of(context).unfocus();
        if (_showEmojiPicker) {
          setState(() => _showEmojiPicker = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const Text(
            'Poll',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          if (_isLoading)
                const CircularProgressIndicator()
              else
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _savePoll,
                )
            ],
          )
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create a poll',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Question',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextFields(
                            controller: _questionController,
                            focusNode: _questionFocusNode,
                            hintText: 'Type poll question',
                            suffixIcon: Icons.emoji_emotions,
                            onSuffixIconTap: () => _showEmojiPickerBottomSheet(_questionController),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Options',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...List.generate(
                            _optionControllers.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomTextFields(
                                controller: _optionControllers[index],
                                focusNode: _optionFocusNodes[index],
                                hintText: '+ add option',
                                suffixIcon: Icons.emoji_emotions,
                                onSuffixIconTap: () => _showEmojiPickerBottomSheet(_optionControllers[index]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              CustomCheckbox(
                                isSelected: _allowMultipleAnswers,
                                onChanged: (value) {
                                  setState(() {
                                    _allowMultipleAnswers = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Allow multiple answers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const PollsListWidget()
                  ],
                ),
              ),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 300,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _onEmojiSelected(category, emoji);
                  },
                  config: Config(
                    columns: 7,
                   emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    initCategory: Category.RECENT,
                    bgColor: Theme.of(context).scaffoldBackgroundColor,
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    backspaceColor: Colors.blue,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentsLimit: 28,
                    noRecents: const Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Define your action here
            print('Send button pressed');
          },
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
 
      ),
    );
  }
}