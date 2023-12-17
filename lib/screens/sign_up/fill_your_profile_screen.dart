import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ctrlfirl/common/button.dart';
import 'package:ctrlfirl/common/form_container.dart';
import 'package:ctrlfirl/constants/app_settings.dart';
import 'package:ctrlfirl/constants/app_theme.dart';
import 'package:ctrlfirl/constants/colors.dart';
import 'package:ctrlfirl/constants/routes.dart';
import 'package:ctrlfirl/controllers/auth_controller.dart';
import 'package:ctrlfirl/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FillYourProfileScreen extends StatefulWidget {
  const FillYourProfileScreen({super.key});

  @override
  State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
}

class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String _dOB = 'Date of Birth';
  String? _gender;
  final _formKey = GlobalKey<FormState>();
  String? _userType;
  final List<String> _userTypes = [
    'Student',
    'Teacher',
    'Part-Time Employee',
    'Full-Time Employee',
    'Other',
  ];

  XFile? _selectedImage;
  bool _isSelectedTC = false;
  List<String> selected = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 120)),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dOB = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthController>(
          builder: (context, authControllerConsumer, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Personal Information',
                style: AppTheme.textTheme.titleLarge),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Column(
                    children: [
                      // text field for the full name
                      TextFormField(
                        onEditingComplete: () => setState(() {}),
                        controller: _fullNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Full name cannot be empty';
                          }
                          return null;
                        },
                        style: AppTheme.textTheme.titleSmall,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: AppTheme.textTheme.labelMedium,
                          enabledBorder: _fullNameController.text.isNotEmpty
                              ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: AppColors.white, width: 1.5),
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      // date picker for the date of birth
                      FormContainer(
                        initialValue: _dOB,
                        validator: (value) {
                          if (value == 'Date of Birth' || value == null) {
                            return 'Date of birth cannot be empty';
                          }
                          if (selectedDate.isAfter(DateTime.now())) {
                            return 'Date of birth cannot be in the future';
                          }
                          //  calculate age in years
                          var age =
                              DateTime.now().difference(selectedDate).inDays;
                          if (age < 365 * minimumAge) {
                            return 'You must be 18 years or older';
                          }
                          return null;
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dOB,
                              style: _dOB != 'Date of Birth'
                                  ? AppTheme.textTheme.titleSmall!
                                  : AppTheme.textTheme.labelMedium,
                            ),
                            IconButton(
                                onPressed: () => _selectDate(context),
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  color: _dOB != 'Date of Birth'
                                      ? AppColors.white
                                      : AppColors.greyDark,
                                  size: 20,
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      // gender selection
                      FormContainer(
                        initialValue: _gender,
                        validator: (value) {
                          if (value == 'Gender' || value == null) {
                            return 'Gender cannot be empty';
                          }
                          return null;
                        },
                        child: DropdownButton<String>(
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.greyDark,
                            size: 38,
                          ),
                          padding: const EdgeInsets.only(top: 5),
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: AppTheme.textTheme.titleSmall,
                          hint: Text(
                            'Gender',
                            style: AppTheme.textTheme.labelMedium,
                          ),
                          value: _gender,
                          onChanged: (value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // gender selection
                      FormContainer(
                        initialValue: _userType,
                        validator: (value) {
                          if (value == null) {
                            return 'User Type cannot be empty';
                          }
                          return null;
                        },
                        child: DropdownButton<String>(
                          icon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.greyDark,
                            size: 38,
                          ),
                          padding: const EdgeInsets.only(top: 5),
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: AppTheme.textTheme.titleSmall,
                          hint: Text(
                            'Occupation',
                            style: AppTheme.textTheme.labelMedium,
                          ),
                          value: _userType,
                          onChanged: (value) {
                            setState(() {
                              _userType = value;
                            });
                          },
                          items: _userTypes
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            checkColor: AppColors.white,
                            activeColor: AppColors.primary,
                            value: _isSelectedTC,
                            onChanged: (value) {
                              setState(() {
                                _isSelectedTC = value!;
                              });
                            },
                          ),
                          Text(
                            'I agree to the terms and conditions',
                            style: AppTheme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      // button to submit the form

                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Button(
                          disabled: !_isSelectedTC,
                          text: 'Submit',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Process data.
                              UserModel userData = UserModel(
                                fullName: _fullNameController.text,
                                dob: selectedDate,
                                gender: _gender,
                                profileImageFile: _selectedImage,
                              );

                              await authControllerConsumer
                                  .createUserDocument(userData)
                                  .then((value) {
                                if (value) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, Routes.home, (route) => false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Something went wrong. Please try again later')));
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
