// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('情報技術者倫理クイズ①'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 10),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     '情報技術者倫理',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text('名古屋国際工科専門職大学', style: TextStyle(fontSize: 20)),
//                   const SizedBox(height: 10),
//                   const Text('砂川優治', style: TextStyle(fontSize: 16)),
//                   const SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const QuizPage(),
//                         ),
//                       );
//                     },
//                     child: const Text('クイズを開始'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
