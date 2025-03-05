String? emailValidation(String? email, {bool showDetails = true}) {
  if (email == null || email.trim().isEmpty) return 'Email can not be empty';

  final regex = RegExp(emailValidationPattern);
  if (!regex.hasMatch(email)) return 'Invalid email address';

  return null;
}

String? passwordValidation(String? password, {bool showDetails = true}) {
  if (password == null || password.trim().isEmpty) {
    return 'Password can not be empty';
  }

  if (password.length < passwordMinLength) {
    return showDetails
        ? 'Password must have at least ($passwordMinLength) characters in length'
        : 'Invalid password';
  }

  // RegExp digitRegex = RegExp(r'[0-9]');
  // RegExp lowercaseRegex = RegExp(r'[a-z]');
  // RegExp uppercaseRegex = RegExp(r'[A-Z]');
  // RegExp nonAlphanumericRegex = RegExp(r'[\W_]');

  // if (!digitRegex.hasMatch(password)) return showDetails ? "Password must contain at least one digit." : "Invalid password";
  // if (!lowercaseRegex.hasMatch(password)) return showDetails ? "Password must contain at least one lowercase letter." : "Invalid password";
  // if (!uppercaseRegex.hasMatch(password)) return showDetails ? "Password must contain at least one uppercase letter." : "Invalid password";
  // if (!nonAlphanumericRegex.hasMatch(password)) return showDetails ? "Password must contain at least one non-alphanumeric character." : "Invalid password";

  return null;
}

String? nameValidation(String? name, {bool showDetails = true}) {
  if (name == null || name.trim().isEmpty) return 'Name can not be empty';

  if (name.length < nameMinLength) {
    return 'Name must have at least ($nameMinLength) characters in length';
  }

  RegExp regex = RegExp(r'^[a-zA-Z\s]+$');
  if (!regex.hasMatch(name)) {
    return 'Name must not contain any numeric characters or symbol';
  }

  regex = RegExp(r'\s{2,}');
  if (regex.hasMatch(name.trim())) {
    return 'Name must not contain multiple white space in row';
  }

  return null;
}

String? phoneNumberValidation(String? number,
    {List<int>? lengths, bool showDetails = true}) {
  if (number == null || number.trim().isEmpty) {
    return 'Phone number can not be empty';
  }

  int l = number.length;

  lengths ??= [phoneNumberLength];
  if (!lengths.contains(l)) {
    return showDetails
        ? 'Phone number must be with length of $lengths digits'
        : 'Invalid phone number';
  }

  final RegExp regex = RegExp(r'^[0-9]+$');
  if (!regex.hasMatch(number)) {
    return showDetails
        ? 'Phone number must be contain only digits (0-9)'
        : 'Invalid phone number';
  }

  return null;
}

String? addressValidation(String? value, {bool showDetails = true}) {
  if (value == null || value.trim().isEmpty) return 'Address can not be empty';

  if (value.length < addressLength) {
    return showDetails
        ? 'Address must have at least ($addressLength) characters in length'
        : 'Invalid address';
  }

  return null;
}

String? webAddressValidation(String? value, {bool showDetails = true}) {
  if (value == null || value.trim().isEmpty) {
    return 'Web-address can not be empty';
  }

  final RegExp regex = RegExp(
      r"^(?:http:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[a-zA-Z0-9-._~:/?#[\]@!$&\'()*+,;=]*)?$");

  if (!regex.hasMatch(value)) return 'Invalid website';

  return null;
}
