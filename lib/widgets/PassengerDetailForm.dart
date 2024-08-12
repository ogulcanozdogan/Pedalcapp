import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PassengerDetailForm extends StatefulWidget {
  final dynamic booking;
  const PassengerDetailForm({Key? key, this.booking});

  @override
  State<PassengerDetailForm> createState() => _PassengerDetailFormState();
}

class _PassengerDetailFormState extends State<PassengerDetailForm> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'US');

  @override
  Widget build(BuildContext context) {
    dynamic booking = widget.booking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Passenger Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("First Name"),
        const SizedBox(height: 5),
        TextFormField(
          onChanged: (value) {
            booking.firstName = value;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hintText: "Enter your first name",
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            } else if (value.length > 25) {
              return 'Maximum 25 characters allowed';
            } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
              return 'Only letters are allowed';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        const Text("Last Name"),
        const SizedBox(height: 5),
        TextFormField(
          onChanged: (value) {
            booking.lastName = value;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hintText: "Enter your last name",
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            } else if (value.length > 25) {
              return 'Maximum 25 characters allowed';
            } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
              return 'Only letters are allowed';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        const Text("Email"),
        const SizedBox(height: 5),
        TextFormField(
          controller: emailController,
          onChanged: (value) {
            booking.emailAddress = value;
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hintText: "Enter your email address",
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            } else if (!EmailValidator.validate(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        const Text("Phone Number"),
        const SizedBox(height: 5),
        InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber number) {
            booking.phoneNumber = number.phoneNumber!;
          },
          inputBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.DROPDOWN,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          selectorTextStyle: const TextStyle(color: Colors.black),
          initialValue: number,
          textFieldController: controller,
          formatInput: false,
          inputDecoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hintText: "Enter your phone number",
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            return null;
          },
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
        ),
      ],
    );
  }
}
