/// errors : [{"code":"l_name","message":"The last name field is required."},{"code":"password","message":"The password field is required."}]
library;

class ErrorResponseModel {
  List<Errors>? _errors;

  List<Errors>? get errors => _errors;

  ErrorResponseModel({List<Errors>? errors}) {
    _errors = errors;
  }

  ErrorResponseModel.fromJson(dynamic json) {
    if (json == null) {
      _errors = null;
    } else if (json is Map && json["errors"] != null && json["errors"] is List) {
      _errors = [];
      json["errors"].forEach((v) {
        _errors!.add(Errors.fromJson(v));
      });
    } else if (json is Map && json["errors"] != null && json["errors"] is Map) {
      _errors = [Errors.fromJson(json["errors"])];
    } else if (json is Map) {
      String message = json["message"]?.toString() ?? json["msg"]?.toString() ?? json.toString();
      _errors = [Errors(code: '', message: message)];
    } else if (json is String) {
      _errors = [Errors(code: '', message: json)];
    } else {
      _errors = [Errors(code: '', message: json.toString())];
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_errors != null) {
      map["errors"] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// code : "l_name"
/// message : "The last name field is required."

class Errors {
  String? _code;
  String? _message;

  String? get code => _code;
  String? get message => _message;

  Errors({String? code, String? message}) {
    _code = code;
    _message = message;
  }

  Errors.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    return map;
  }
}
