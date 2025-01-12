import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        prefixIcon: prefixIcon,
      ),
      style: TextStyle(color: Colors.black),
    );
  }
}





class CustomTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Widget? prefixWidget;  // Updated: For prefix widget (e.g., image)
  final IconData? suffixIcon;  // For suffix icon
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final VoidCallback? onSuffixIconTap; // Added for suffix icon tap handling

  const CustomTextFields({
    Key? key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.prefixWidget,  // Updated parameter
    this.suffixIcon,  // Suffix icon remains the same
    this.obscureText = false,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.hintStyle,
    this.style,
    this.onSuffixIconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15);
    
    // Define colors
    const focusedBorderColor = Colors.green;
    const labelColor = Colors.black;
    
    // Error border style
    final errorBorderStyle = BorderSide(
      color: Colors.red.shade400,
      width: 1.5,
    );

    // Normal border style
    const normalBorderStyle = BorderSide(
      color: Colors.black38,
    );

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: hintText,
        
        // Floating label style
        floatingLabelStyle: const TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
        
        // Label style when not floating
        labelStyle: const TextStyle(
          color: Colors.grey,
        ),
        
        // Prefix Widget (can be an image or any widget)
        prefix: prefixWidget,

        // Suffix Icon with optional tap handler
        suffixIcon: suffixIcon != null 
          ? GestureDetector(
              onTap: onSuffixIconTap,
              child: Icon(
                suffixIcon,
                color: Colors.grey,
              ),
            )
          : null,

        filled: fillColor != null,
        fillColor: fillColor,
        hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
        
        // Error style
        errorStyle: TextStyle(
          color: Colors.red.shade400,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        
        // Border styling
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: normalBorderStyle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: normalBorderStyle,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: focusedBorderColor,
            width: 2,
          ),
        ),
        // Error borders
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: errorBorderStyle,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: errorBorderStyle.copyWith(width: 2),
        ),
        
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: style,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
