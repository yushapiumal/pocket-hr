
//qr onoff test  button 

// line 1079 

// Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: apiService.qrEnable ? Colors.green : Colors.red,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 apiService.qrEnable = !apiService.qrEnable;
//                               });
//                             },
//                             child: Text('QR: ${apiService.qrEnable ? "ON" : "OFF"}', style: TextStyle(color: Colors.white)),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: apiService.remoteEnable ? Colors.green : Colors.red,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 apiService.remoteEnable = !apiService.remoteEnable;
//                               });
//                             },
//                             child: Text('Remote: ${apiService.remoteEnable ? "ON" : "OFF"}', style: TextStyle(color: Colors.white)),
//                           ),
//                         ],
//                       ),
//                     ),"