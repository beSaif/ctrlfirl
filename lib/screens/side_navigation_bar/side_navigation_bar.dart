import 'package:ctrlfirl/constants/colors.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SideNavigationBar extends StatefulWidget {
  const SideNavigationBar({super.key});

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarState();
}

class _SideNavigationBarState extends State<SideNavigationBar> {
  // bool _switchValue = false;
  List<Map<String, dynamic>> profileOptions = [
    {
      'option': 'Edit Profile',
      'icon': 'assets/graphics/edit_profile_icon.png',
    },
    {
      'option': 'About App',
      'icon': 'assets/graphics/about_clinic_icon.png',
      'route': Routes.aboutUs,
    },
    {
      'option': 'Contact Us',
      'icon': 'assets/graphics/contact_details_icon.png',
      'route': Routes.contactDetail,
    },
    {
      'option': 'Settings',
      'icon': 'assets/graphics/settings_icon.png',
    }
  ];

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     UserHelper userHelper = UserHelper();
  //     userHelper
  //         .getUserData(FirebaseAuth.instance.currentUser!.uid)
  //         .then((value) => {setState(() {})});
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return Consumer<AuthController>(builder: (context, authController, child) {
      return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            actions: [
              // close button
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            title: const Text('Navigation Bar'),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(),
                Padding(
                  padding: EdgeInsets.only(
                    left: w * 0.03,
                    right: w * 0.005,
                  ),
                  child: SizedBox(
                    // height: h *
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: profileOptions.length,
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              visualDensity: VisualDensity(vertical: 0.01),
                              leading: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  profileOptions[i]["icon"],
                                  height: 5.h,
                                  width: 7.w,
                                  color: AppColors.white,
                                ),
                              ),
                              title: Text(profileOptions[i]['option'],
                                  style:
                                      AppTheme.textTheme.titleMedium?.copyWith(
                                          // color: AppColors.primary,
                                          )),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  profileOptions[i]['route'],
                                );
                              },
                            ),
                          );
                        }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: GestureDetector(
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        backgroundColor: AppColors.white,
                        surfaceTintColor: AppColors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        alignment: Alignment.bottomCenter,
                        insetPadding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox(
                            height: h * 0.28,
                            width: double.infinity,
                            child: Column(
                              //mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: h * 0.025),
                                Text(
                                  'Logout',
                                  style: AppTheme.textTheme.bodyLarge!.copyWith(
                                    color: AppColors.alertRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: h * 0.01),
                                Divider(
                                  color: AppColors.greyLight,
                                  indent: w * 0.06,
                                  endIndent: w * 0.06,
                                ),
                                SizedBox(height: h * 0.01),
                                Text(
                                  'Are you sure you want to log out?',
                                  style: AppTheme.textTheme.titleLarge,
                                ),
                                SizedBox(height: h * 0.03),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: h * 0.07,
                                        width: w * 0.44,
                                        decoration: BoxDecoration(
                                          color: AppColors.turqoise,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Cancel',
                                            style: AppTheme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: w * 0.03),
                                    SizedBox(
                                      height: h * 0.07,
                                      width: w * 0.44,
                                      child: ButtonWithShadow(
                                        text: 'Yes, Logout',
                                        onPressed: () {
                                          authController.signOut().then(
                                              (value) => {
                                                    Navigator
                                                        .pushNamedAndRemoveUntil(
                                                            context,
                                                            Routes.signUp,
                                                            (route) => false)
                                                  });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: w * 0.076,
                        right: w * 0.06,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_outlined,
                            color: AppColors.alertRed,
                          ),
                          SizedBox(
                            width: w * 0.08,
                          ),
                          Text(
                            'Logout',
                            style: AppTheme.textTheme.titleMedium!.copyWith(
                              color: AppColors.alertRed,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ButtonWithShadow extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ButtonWithShadow({
    super.key,
    this.text = 'Text here',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            textStyle: AppTheme.textTheme.titleMedium,
            elevation: 0),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
