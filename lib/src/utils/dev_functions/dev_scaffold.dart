// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:on_process_button_widget/on_process_button_widget.dart';

// import 'dev_button.dart';

// const double _defaultPadding = 24.0;

// class DevScaffold extends StatefulWidget {
//   const DevScaffold({super.key, required this.child, this.floatingActionButton});
//   final Widget child;
//   final Widget? floatingActionButton;

//   @override
//   State<DevScaffold> createState() => _DevScaffoldState();
// }

// class _DevScaffoldState extends State<DevScaffold> {
//   final ApiClient _controller = Get.find();
//   final GlobalKey<ScaffoldState> _key = GlobalKey();

//   Widget _onPress(String text, Function onTap) {
//     return OnProcessButtonWidget(
//       margin: EdgeInsets.symmetric(vertical: _defaultPadding / 4),
//       onDone: (isSuccess) => onTap(),
//       child: Text(text),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (kDebugMode) {
//       return Scaffold(
//         key: _key,
//         body: widget.child,
//         floatingActionButton: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (kIsWeb)
//               DevButton(
//                 onTap: () async {
//                   _key.currentState?.openEndDrawer();
//                   return;
//                 },
//                 child: Text("ED"),
//               ),
//             if (widget.floatingActionButton != null) widget.floatingActionButton!,
//           ],
//         ),
//         endDrawer: Container(
//           constraints: BoxConstraints(maxWidth: 400),
//           padding: EdgeInsets.all(_defaultPadding),
//           margin: EdgeInsets.only(left: _defaultPadding),
//           child: Column(
//             children: [
//               SizedBox(height: MediaQuery.of(context).padding.top),
//               for (var l in AppTranslations.supportedLocales) _onPress("Change Language ${l.languageCode}", () async => await AppTranslations.updateLocale(l)),
//               // _onPress("Change Theme - System Local", () => _controller.changeTheme()),
//               // _onPress("Change Theme - Dark Local", () => _controller.changeTheme(isDarkMode: true)),
//               // _onPress("Change Theme - Light Local", () => _controller.changeTheme(isDarkMode: false)),
//               _onPress("Logout", () => _controller.removeToken()),
//             ],
//           ),
//         ),
//       );
//     }

//     return widget.child;
//   }
// }
