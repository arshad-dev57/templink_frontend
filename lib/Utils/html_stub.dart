class _Window {
  final _History history = _History();
  final _Location location = _Location();

  dynamic open(String url, String target) => null;
}

class _History {
  void replaceState(dynamic data, String title, String? url) {}
}

class _Location {
  String href = '';
}

final _Window window = _Window();

class File {
  String name = '';
  int size = 0;
}

class FileReader {
  final _EventStream onLoad = _EventStream();
  dynamic result;

  void readAsDataUrl(dynamic file) {}

  void readAsArrayBuffer(dynamic file) {}
}

class FileUploadInputElement {
  dynamic files;
  bool multiple = false;
  String accept = '';
  final _EventStream onChange = _EventStream();

  void click() {}
}

class Blob {
  Blob(List<dynamic> parts, String type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';

  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  AnchorElement({String? href});

  String download = '';

  void setAttribute(String name, String value) {}

  void click() {}
}

class _EventStream {
  Future<dynamic> get first => Future<dynamic>.value(null);

  void listen(void Function(dynamic) callback) {}
}
