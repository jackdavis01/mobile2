class InfoState {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildMode;
  final bool isLoading;

  InfoState({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildMode,
    required this.isLoading,
  });

  factory InfoState.initial() => InfoState(
        appName: '',
        packageName: '',
        version: '',
        buildNumber: '',
        buildMode: '',
        isLoading: true,
      );

  InfoState copyWith({
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? buildMode,
    bool? isLoading,
  }) {
    return InfoState(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      buildMode: buildMode ?? this.buildMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
