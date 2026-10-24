final class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/api/v1/auth/login';
  static const String loginSendPassword = '/api/v1/auth/login/send-password';
  static const String loginRequestOtp = '/api/v1/auth/login/request-otp';
  static const String loginVerifyOtp = '/api/v1/auth/login/verify-otp';
  static const String me = '/api/v1/auth/me';
  static const String changePassword = '/api/v1/auth/change-password';
  static const String signupRequestOtp = '/api/v1/auth/signup/request-otp';
  static const String signupVerifyOtp = '/api/v1/auth/signup/verify-otp';
  static const String playerProfile = '/api/v1/player/profile';
  static const String playerHome = '/api/v1/player/home';
  static const String playerSessions = '/api/v1/player/sessions';
  static const String playerMatches = '/api/v1/player/matches';
  static const String playerAttendance = '/api/v1/player/attendance';
  static const String academy = '/api/v1/academy';
  static const String accountants = '/api/v1/accountants';
  static const String accountantMe = '/api/v1/accountants/me';
  static const String coaches = '/api/v1/coaches';
  static const String students = '/api/v1/students';
  static const String batches = '/api/v1/batches';
  static const String enrollments = '/api/v1/batches/enrollments';
  static const String sessions = '/api/v1/sessions';
  static const String sessionAssignments = '/api/v1/sessions/assignments';
  static const String bills = '/api/v1/bills';
  static const String home = '/api/v1/home';
  static const String matches = '/api/v1/matches';
  static const String profile = '/api/v1/profile';
  static const String leaves = '/api/v1/leaves';

  static String sessionStudents(int sessionId) => '/api/v1/sessions/$sessionId/students';
  static String sessionCoaches(int sessionId) => '/api/v1/sessions/$sessionId/coaches';
  static String coachAttendance(int sessionId) => '/api/v1/sessions/$sessionId/coach-attendance';
  static String studentAttendance(int sessionId) => '/api/v1/sessions/$sessionId/student-attendance';
  static String batchStudents(int batchId) => '/api/v1/batches/$batchId/students';
  static String playerSessionResponse(int sessionId) => '/api/v1/player/sessions/$sessionId/response';
}
