import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/info_bloc_cubit.dart';
import '../businesslogic/info_bloc_state.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    const String platform = 'Flutter 3.38.3';
    const String platformPrerelease = '-';
    const String platformChannel = 'stable';
    const String author = 'Jack Davis';
    
    return BlocProvider(
      create: (_) => InfoCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.infoTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: BlocBuilder<InfoCubit, InfoState>(
          builder: (context, state) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(15.0),
              children: [
                const SizedBox(height: 20),
                // Application Information Box
                Center(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            appLocalizations.infoApplicationInformation,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            appLocalizations.infoApplicationName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            state.appName,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            appLocalizations.infoPackageName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              state.packageName,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            appLocalizations.infoVersionNumber,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            state.version,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                appLocalizations.infoBuildNumber,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                " ${state.buildNumber}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                appLocalizations.infoBuildMode,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                " ${state.buildMode}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          Text(
                            appLocalizations.infoPlatform,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            platform,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                appLocalizations.infoPrerelease,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                " $platformPrerelease",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                appLocalizations.infoChannel,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                " $platformChannel",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              Text(
                                appLocalizations.infoAuthor,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                " $author",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
