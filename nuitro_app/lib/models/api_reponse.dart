

class ApiResponse {
  final bool status;
  final String message;
  final dynamic data; // optional, can hold API response data

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  // Create from JSON (useful if API already sends status/message)
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
