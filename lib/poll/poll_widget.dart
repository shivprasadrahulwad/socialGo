import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social/models/poll.dart';

class PollsListWidget extends StatefulWidget {
  const PollsListWidget({Key? key}) : super(key: key);

  @override
  _PollsListWidgetState createState() => _PollsListWidgetState();
}

class _PollsListWidgetState extends State<PollsListWidget> {
  late Future<List<Poll>> _pollsFuture;
  final PollService _pollService = PollService();

  @override
  void initState() {
    super.initState();
    _pollsFuture = _pollService.getAllPolls();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Poll>>(
      future: _pollsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No polls found'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final poll = snapshot.data![index];
            return _PollWidget(poll: poll);
          },
        );
      },
    );
  }
}

class _PollWidget extends StatefulWidget {
  final Poll poll;

  const _PollWidget({Key? key, required this.poll}) : super(key: key);

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<_PollWidget> {
  late List<bool> _selectedOptions;
  late List<int> _randomNumbers;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.filled(widget.poll.options.length, false);
    _generateRandomNumbers();
  }

  void _generateRandomNumbers() {
    // Generate random numbers for each option (between 10 and 100 for demo)
    _randomNumbers = List.generate(widget.poll.options.length, (index) {
      return 10 + (index + 1) * 15; // Replace with Random().nextInt if dynamic
    });
  }

  void _toggleOption(int index) {
    setState(() {
      if (widget.poll.multiple) {
        _selectedOptions[index] = !_selectedOptions[index];
      } else {
        // For single selection, unselect all others
        _selectedOptions = List.filled(widget.poll.options.length, false);
        _selectedOptions[index] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll Question
            Row(
              children: [
                Text(
                  widget.poll.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade200, // Light red color
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(
                      5.0), // Optional: adjust the padding for spacing
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red, // White icon color
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Selection Type Text
            Text(
              widget.poll.multiple
                  ? 'Select one or more options'
                  : 'Select one option',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),

            // Poll Options
            ...List.generate(widget.poll.options.length, (index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: Colors.grey,
                    strokeWidth: 2,
                    dashPattern: [5, 5],
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // const SizedBox(width: 16),

                  const SizedBox(width: 10),

                  // Option text, number, and progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.poll.options[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_randomNumbers[index]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Progress Bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: LinearProgressIndicator(
                              value: _randomNumbers[index] / 100,
                              color: Colors.red,
                              backgroundColor: Colors.red.shade200,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
            Text(
              DateFormat('EEE, h:mm a').format(widget.poll.createdAt),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const Divider(
              color: Colors.red,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Center(
                child: Text(
                  'View votes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
