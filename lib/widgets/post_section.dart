// import 'package:flutter/material.dart';

// class PostSection extends StatelessWidget {
//   const PostSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final horizontalPadding = screenWidth * 0.07;

//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             horizontalPadding,
//             30,
//             horizontalPadding,
//             0,
//           ),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundImage:
//                     (profile?.photo != null && profile!.photo!.isNotEmpty)
//                     ? NetworkImage(profile.photo!)
//                     : null,
//                 child: (profile?.photo == null || profile!.photo!.isEmpty)
//                     ? const Icon(Icons.person, size: 20)
//                     : null,
//               ),
//               const SizedBox(width: 10),

//               Text(
//                 '${profile?.front_name ?? "-"} ${profile?.last_name ?? "-"}',
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Text(
//                 '22 hours ago',
//                 style: const TextStyle(
//                   color: Color(0xFF249A00),
//                   fontSize: 13,
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               Container(
//                 width: 57,
//                 height: 25,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE0FFDE),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Text(
//                   'Safety',
//                   style: TextStyle(
//                     color: Color(0xFF249A00),
//                     fontSize: 13,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: EdgeInsetsGeometry.only(top: 7, left: 75, right: 25),
//           child: Column(
//             children: [
//               SizedBox(
//                 width: 328,
//                 child: Text(
//                   'The pedestrian signal at the main intersection near Mexico Square is not functioning. Cars don’t stop, and people are forced to cross dangerously. This puts children and elderly at high risk. Please fix urgently.',
//                   style: TextStyle(
//                     color: Colors.black /* Black */,
//                     fontSize: 13,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.w400,
//                     height: 1.92,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 7),
//               Container(
//                 width: double.infinity,
//                 height: 145,
//                 decoration: ShapeDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(
//                       "https://dishub.banjarmasinkota.go.id/wp-content/uploads/2024/11/lampu-lalu-lintas-punya-3-warna_169.jpg",
//                     ),
//                     fit: BoxFit.cover,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
