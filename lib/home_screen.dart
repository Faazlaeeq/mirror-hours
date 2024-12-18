import 'package:flutter/material.dart';
import 'package:mirror/screens/alarm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/bg-full.jpg',
            fit: BoxFit.fitHeight,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              const Text("Houruoh", style: TextStyle(fontSize: 40, color: Color(0xffffffff), fontFamily: 'Mouldy')),
              SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 100),
                child: Text(
                    "A “Mirror Hour” is an hour with double figures. It usually shows itself to you accidentally when you look at your phone, your watch, or any other device which shows the time in a digital format. This can give you a strange feeling, especially when the same double hour appears to you regularly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xffffffff),
                        shadows: [Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(5, 5))])),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffE9E1EC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MirrorHoursPage()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Manage Mirror Hours",
                        style: TextStyle(
                          color: Color(0xff2C1542),
                          fontSize: 16,
                        )),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
