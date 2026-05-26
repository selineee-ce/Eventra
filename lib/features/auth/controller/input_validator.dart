class InputValidator {
  // Validasi Phone Number: Harus angka & tepat 10 digit
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    
    // RegExp untuk memastikan hanya angka (0-9)
    final phoneRegex = RegExp(r'^[0-9]+$');
    
    if (!phoneRegex.hasMatch(value)) {
      return "Must be numbers only";
    }
    if (value.length <= 10) {
      return "Must be at least 10 digits";
    }
    return null;
  }

  // Validasi Email: Wajib ada @gmail.com
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    
    // Cek apakah mengandung @gmail.com
    if (!value.endsWith("@gmail.com")) {
      return "Only @gmail.com addresses are allowed";
    }
    
    // Opsional: Tetap cek format email umum agar tidak ada typo di depan @
    final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid gmail format";
    }
    
    return null;
  }

  // Validasi Username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return "Username cannot be empty";
    return null;
  }

  // Validasi Password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 8) return "Min. 8 characters";
    return null;
  }

  // Validasi Match Password
  static String? validateConfirmPassword(String? value, String password) {
    if (value != password) return "Passwords do not match";
    return null;
  }
}