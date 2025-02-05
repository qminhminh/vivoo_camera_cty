import 'package:flutter/material.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class TextFieldCommonSecurity extends StatelessWidget {
  const TextFieldCommonSecurity({
    Key? key,
    this.prefixIcon,
    this.keyboardType,
    this.onEditingComplete,
    this.controller,
    this.hintText,
    this.focusNode,
    this.initialValue,
    this.onChanged, // Thêm thuộc tính onChanged
    this.validator, // Thêm validator để kiểm tra mật khẩu
  }) : super(key: key);

  final String? hintText;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final void Function()? onEditingComplete;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final void Function(String)? onChanged; // Xử lý khi giá trị thay đổi
  final String? Function(String?)? validator; // Kiểm tra giá trị nhập vào

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      textInputAction: TextInputAction.next,
      onEditingComplete: onEditingComplete,
      keyboardType: keyboardType,
      initialValue: initialValue,
      controller: controller,
      onChanged: onChanged, // Gọi hàm khi giá trị thay đổi
      validator: validator ??
          (value) {
            if (value!.isEmpty) {
              return "Please enter a valid value";
            }
            if (value.length < 6) {
              return "Password must be at least 6 characters";
            }
            if (value.length > 72) {
              return "Password must not exceed 72 characters";
            }
            return null;
          },
      style: appStyle(16, kDark, FontWeight.normal),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        isDense: false,
        hintStyle: appStyle(14, kGray, FontWeight.normal),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kDark, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kGray, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: kGray, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: kDark, width: 0.5),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    );
  }
}
