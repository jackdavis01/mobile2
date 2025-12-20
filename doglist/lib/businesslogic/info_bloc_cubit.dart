import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'info_bloc_state.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState.initial()) {
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String buildMode = kDebugMode ? 'debug' : 'release';

      emit(state.copyWith(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        buildMode: buildMode,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
