extension StringExtensions on String {
  String iniciais() {
    final spplited = split(" ").map((p) => p[0]).toList();
    return spplited.join("");
  }
}
