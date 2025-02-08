// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';

// class ButtonCard extends StatelessWidget {
//   const ButtonCard({
//     Key? key,
//     required this.name,
//     required this.icon,
//   }) : super(key: key);
  
//   final String name;
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         radius: 23,
//         child: Icon(
//           icon,
//           size: 26,
//           color: Colors.white,
//         ),
//         backgroundColor: Color(0xFF25D366),
//       ),
//       title: Text(
//         name,
//         style: TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  const ButtonCard({
    Key? key,
    required this.name,
    this.imageUrl,
    this.icon = Icons.person,
  }) : super(key: key);

  final String name;
  final String? imageUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 23,
        backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
            ? NetworkImage(imageUrl!)
            : null,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Icon(
                icon,
                size: 26,
                color: Colors.white,
              )
            : null,
        backgroundColor: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Colors.transparent
            : const Color(0xFF25D366),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Row(
              children: [
                Icon(Icons.done_all),
                SizedBox(
                  width: 3,
                ),
                Text(
                  'we have to show latest message',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            // trailing: Text(chatModells.createdAt.toString()),
    );
  }
}
