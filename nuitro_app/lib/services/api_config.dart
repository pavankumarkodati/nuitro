class ApiConfig {
  // TODO: Consider loading this from runtime environment or flavor settings.
  static const String baseUrl = "https://nuitro.thedatageek.in";
  // static const String baseUrl = "http://192.168.225.54:8000";
  // static const String baseUrl = "http://192.168.134.184:8000";

  // Authentication & session
  static const String signupEndpoint = "/api/signupdetails";
  static const String loginEndpoint = "/api/login";
  static const String tokenRefreshEndpoint = "/api/token/refresh/";

  // User data
  static const String userProfileInfoEndpoint = "/api/userprofileinfo";
  static const String sendEmailOtpEndpoint = "/api/sendemailotp";
  static const String mobileOtpEndpoint = "/api/mobileotp";
  static const String verifyEmailOtpEndpoint = "/api/verifyemailotp";

  // Food insights
  static const String nutritionInfoEndpoint = "/api/nutritioninfo";
  static const String foodPredictionsEndpointBase = "/api/getfoodpredictions";
  static const String manualLogBase = "/api/manual-log";
  static const String manualLogSearchEndpoint = "$manualLogBase/search";
  static const String manualLogPredictEndpoint = "$manualLogBase/predict";
  static const String manualLogSaveEndpoint = "$manualLogBase/save";
  static const String manualLogCaptureEndpoint = "$manualLogBase/capture";

  static const String foodLogEndpoint = "/api/foodlog";
  static const String foodLogSearchEndpoint = "$foodLogEndpoint/search";
  static const String foodLogCaptureEndpoint = "$foodLogEndpoint/capture";
  static const String barcodeScanEndpoint = "/api/barcodescan";
  static const String foodLogByDateEndpointBase = "/api/getfoodlog";
  static const String waterLogEndpoint = "/api/waterlog";
  static const String waterLogByDateEndpointBase = "/api/getwaterlog";
  static const String updateWellnessEndpoint = "/api/updatewellness";

  // Progress & plans
  static const String progressAnalyticsEndpoint = "/api/progress/analytics";
  static const String progressCaloriesEndpoint = "/api/progress/calories";
  static const String progressMacrosEndpoint = "/api/progress/macros";
  static const String progressNutrientsEndpoint = "/api/progress/nutrients";

  static const String dietPlansEndpoint = "/api/user/diet-plans";
  static const String weightDashboardEndpoint = "/api/user/weight/dashboard";

  // Date utilities
  static DateTime localToday() => DateTime.now();

  static String formatDate(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  static String formattedLocalToday() => formatDate(localToday());

  static String foodPredictionsForDate(String formattedDate) {
    return "$foodPredictionsEndpointBase/$formattedDate/";
  }

  static String foodLogForDate(String formattedDate) {
    return "$foodLogByDateEndpointBase/$formattedDate";
  }

  static String waterLogForDate(String formattedDate) {
    return "$waterLogByDateEndpointBase/$formattedDate";
  }

  static String resolveMediaUrl(String? rawUrl) {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty) {
      return "";
    }

    if (url.startsWith('assets/') || url.startsWith('packages/')) {
      return url;
    }

    final parsed = Uri.tryParse(url);
    final base = Uri.tryParse(baseUrl);
    if (parsed == null) {
      return url;
    }

    if (base == null) {
      return url;
    }

    if (parsed.hasScheme && parsed.host.isNotEmpty) {
      if (_isLocalHost(parsed.host)) {
        return Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
          path: parsed.path,
          query: parsed.hasQuery ? parsed.query : null,
          fragment: parsed.hasFragment ? parsed.fragment : null,
        ).toString();
      }
      return url;
    }

    return base.resolveUri(parsed).toString();
  }

  static bool _isLocalHost(String host) {
    const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
    if (localHosts.contains(host)) {
      return true;
    }
    return host.startsWith('192.168.') || host.startsWith('10.') || host.startsWith('172.');
  }
}
