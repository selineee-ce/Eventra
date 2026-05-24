class EventraSession {
  EventraSession._();

  static final EventraSession instance = EventraSession._();

  Map<String, dynamic>? currentUser;

  bool get isLoggedIn => currentUser != null;

  void setUser(Map<String, dynamic> user) {
    currentUser = user;
  }

  void clear() {
    currentUser = null;
  }
}
