import 'package:animated_login/animation_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Artboard? riveArtBoard;

  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerLookLeft;
  late RiveAnimationController controllerLookRight;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String testMail = "MohamedOsama@gmail.com";
  String testPassword = "123456";
  final passwordFocusNode = FocusNode();
  bool isLookingRight = false;
  bool isLookingLeft = false;

  void removeAllController() {
    riveArtBoard!.artboard.removeController(controllerIdle);
    riveArtBoard!.artboard.removeController(controllerHandsUp);
    riveArtBoard!.artboard.removeController(controllerHandsDown);
    riveArtBoard!.artboard.removeController(controllerLookLeft);
    riveArtBoard!.artboard.removeController(controllerLookRight);
    riveArtBoard!.artboard.removeController(controllerSuccess);
    riveArtBoard!.artboard.removeController(controllerFail);
    isLookingRight = false;
    isLookingLeft = false;
  }

  void addIdleController() {
    removeAllController();
    riveArtBoard!.artboard.addController(controllerIdle);
    debugPrint('idle');
  }

  void addHandsUpController() {
    removeAllController();
    riveArtBoard!.artboard.addController(controllerHandsUp);
    debugPrint('controllerHandsUp');
  }

  void addHandsDownController() {
    removeAllController();
    riveArtBoard!.artboard.addController(controllerHandsDown);
    debugPrint('controllerHandsDown');
  }

  void addLookLeftController() {
    removeAllController();
    isLookingLeft = true;
    riveArtBoard!.artboard.addController(controllerLookLeft);
    debugPrint('controllerLookLeft');
  }

  void addLookRightController() {
    removeAllController();
    isLookingRight = true;
    riveArtBoard!.artboard.addController(controllerLookRight);
    debugPrint('controllerLookRight');
  }

  void addSuccessController() {
    removeAllController();
    riveArtBoard!.artboard.addController(controllerSuccess);
    debugPrint('controllerSuccess');
  }

  void addFailController() {
    removeAllController();
    riveArtBoard!.artboard.addController(controllerFail);
    debugPrint('controllerFail');
  }

  void checkForPasswordFocusNodeToChangeAnimation() {
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        addHandsUpController();
      } else if (!passwordFocusNode.hasFocus) {
        addHandsDownController();
      }
    });
  }

  void validateEmailAndPassword() {
    Future.delayed(const Duration(seconds: 1));
    if (formKey.currentState!.validate()) {
      addSuccessController();
    } else {
      addFailController();
    }
  }

  @override
  void initState() {
    super.initState();
    controllerIdle = SimpleAnimation(AnimationEnum.idle.name);
    controllerHandsUp = SimpleAnimation(AnimationEnum.Hands_up.name);
    controllerHandsDown = SimpleAnimation(AnimationEnum.hands_down.name);
    controllerLookLeft = SimpleAnimation(AnimationEnum.Look_down_left.name);
    controllerSuccess = SimpleAnimation(AnimationEnum.success.name);
    controllerLookRight = SimpleAnimation(AnimationEnum.Look_down_right.name);
    controllerFail = SimpleAnimation(AnimationEnum.fail.name);

    rootBundle.load('assets/login_animation.riv').then((data) {
      final file = RiveFile.import(data);
      final artBoard = file.mainArtboard;
      artBoard.addController(controllerIdle);
      setState(() {
        riveArtBoard = artBoard;
      });
    });
    checkForPasswordFocusNodeToChangeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Animated Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20,
          ),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: riveArtBoard == null
                    ? const SizedBox.shrink()
                    : Rive(artboard: riveArtBoard!),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) =>
                          value != testMail ? 'Wrong Mail' : null,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            value.length < 16 &&
                            !isLookingLeft) {
                          addLookLeftController();
                        } else if (value.isNotEmpty &&
                            value.length > 16 &&
                            !isLookingRight) {
                          addLookRightController();
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 25),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      validator: (value) =>
                          value != testPassword ? 'Wrong Password' : null,
                      focusNode: passwordFocusNode,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 18),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 8,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          passwordFocusNode.unfocus();
                          validateEmailAndPassword();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
