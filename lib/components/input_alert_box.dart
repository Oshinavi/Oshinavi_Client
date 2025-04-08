import 'package:flutter/material.dart';

/*
INPUT ALERT BOX

유저가 타이핑 가능한 alert dialog box

To use this widget, you need:

- text controller (to access what the user type)
- hint text
- a fuction (e.g. PostMessage)
- text 4 button (e.g. "Save")

*/

class InputAlertBox extends StatelessWidget {

  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;
  const InputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText
  });

  //Build UI
  @override
  Widget build(BuildContext context) {

    //Alert Dialog
    return AlertDialog(
      // Curve corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),

      //Color
      backgroundColor: Theme.of(context).colorScheme.surface,

      //Textfield (user types here)
      content: TextField(
        controller: textController,

        //limiting max characters
        maxLength: 280,

        decoration: InputDecoration(
          //border when textfield is unselected
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),

          //border when textfield is selected
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
             borderRadius: BorderRadius.circular(12),
          ),

          //hint text
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          // Color inside of textfield
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,

          //counter style
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),

      //Buttons
      actions: [
        // cancel button
        TextButton(onPressed: () {
          //close box
          Navigator.pop(context);

          //clear controller
          textController.clear();
        },
            child: const Text("취소"),
        ),

        //yes button
        TextButton(
          onPressed: () {
            //close box
            Navigator.pop(context);

            //execute function
            onPressed!();

            //clear controller
            textController.clear();
            },
            child: Text("onPressedText"),
        )
      ],
    );
  }
}
