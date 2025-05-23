class SessionManager {
  static bool isLoggedIn = false;
  static String? currentUserEmail;

  static void logIn() {
    isLoggedIn = true;
  }

  static void logOut() {
    isLoggedIn = false;
  }

  static void setCurrentUserEmail(String email) {
    currentUserEmail = email;
  }
}
