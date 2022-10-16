class NoBuilderFound extends Error {
  NoBuilderFound(this.type);

  final String type;

  @override
  String toString() {
    return 'No builder for $type element.';
  }
}
