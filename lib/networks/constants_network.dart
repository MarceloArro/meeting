class NetworkConstants {
  //APP CONFIG
  static const String HOST = "https://meeting-test-api.herokuapp.com";
  static const String _API = "api/v1";
  static const String _TOKEN = "tokens";

  //ROUTES
  //User
  static const String API_LOGIN = "$HOST/$_API/login";
  static const String API_REGISTER = "$HOST/$_API/register";
  static const String API_USER_UPDATE = "$HOST/$_API/update-user";
  static const String API_USER_INFO = "$HOST/$_API/user-info";

  static const String API_TOKEN_REGISTER = "$HOST/$_API/$_TOKEN/register";
  static const String API_TOKEN_REFRESH = "$HOST/$_API/$_TOKEN/refresh";

  //Group
  static const String API_CREATE_GROUP = "$HOST/$_API/create-group";
  static const String API_UPDATE_GROUP = "$HOST/$_API/update-group";
  static const String API_DELETE_GROUP = "$HOST/$_API/delete-group";
  static const String API_GROUP_INFO = "$HOST/$_API/group-info";

  //Group Members
  static const String API_INVITE_MEMBER = "$HOST/$_API/invite-member";
  static const String API_DELETE_MEMBER = "$HOST/$_API/delete-member";

  //Image manager
  static const String API_AVATAR_USER = "$HOST/$_API/update-user-avatar";
  static const String API_AVATAR_USER_DELETE = "$HOST/$_API/delete-user-avatar";
  static const String API_AVATAR_GROUP = "$HOST/$_API/update-group-avatar";
  static const String API_AVATAR_INVITED = "$HOST/$_API/add-invited-avatar";

  //Group linkCodes
  static const String API_CODE_GROUP = "$HOST/$_API/verify-group-code";
  static const String API_CODE_ADD_MEMBER = "$HOST/$_API/add-member";
}
