class Response {
  final String label;
  final double confidence;

  Response({
    this.label,
    this.confidence,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Response && o.label == label && o.confidence == confidence;
  }

  @override
  int get hashCode => label.hashCode ^ confidence.hashCode;

  Response copyWith({
    String label,
    double confidence,
  }) {
    return Response(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
    );
  }
}
