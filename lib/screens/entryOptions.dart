import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'signupPage.dart';

class EntryOptions extends StatefulWidget {
  @override
  _EntryOptionsState createState() => _EntryOptionsState();
}

class _EntryOptionsState extends State<EntryOptions> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Color.fromRGBO(223, 32, 34, 1);
    Color backgroundColor = Color.fromRGBO(255, 255, 255, 0.97);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/ubicacion-fondo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 40,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.grey[400]!,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = true;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _isLogin ? buttonColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: _isLogin ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = false;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: !_isLogin ? buttonColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: !_isLogin ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 320,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isLogin) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('Button 1');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/google-logo.png',
                          color: Colors.white,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Button 2');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/facebook-logo.png',
                          color: Colors.white,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Button 3');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/instagram-logo.png',
                          color: Colors.white,
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Button 4');
                    },
                    child: Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/x-logo.png',
                          color: Colors.white,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
