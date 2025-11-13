import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/navigation_drawer_bloc_cubit.dart';
import '../businesslogic/navigation_drawer_bloc_state.dart';

class DogNavDrawer extends StatelessWidget {
  const DogNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationDrawerCubit(),
      child: const _DogNavDrawerContent(),
    );
  }
}

class _DogNavDrawerContent extends StatelessWidget {
  const _DogNavDrawerContent();

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToInfoPage(BuildContext context) {
    Navigator.pushNamed(context, '/info');
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return BlocBuilder<NavigationDrawerCubit, NavigationDrawerState>(
      builder: (BuildContext context, NavigationDrawerState drawerState) {
        Widget drawerHeader = Container(
          padding: const EdgeInsets.only(right: 16),
          color: Theme.of(context).primaryColor,
          child: UserAccountsDrawerHeader(
            accountName: Text('Favourite: ${drawerState.dogBreedName}', style: const TextStyle(fontSize: 18.0)),
            accountEmail: Text('Likes: ${drawerState.likes}', style: const TextStyle(fontSize: 18.0)),
            currentAccountPictureSize: const Size.square(62.0),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                size: 40,
                color: Colors.blue,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 0),
            otherAccountsPictures: <Widget>[
              CircleAvatar(
                child: IconButton(
                  onPressed: () => _navigateToSettingsPage(context),
                  icon: const Icon(Icons.settings),
                ),
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: () => _navigateToInfoPage(context),
                  icon: const Icon(Icons.info),
                ),
              ),
            ],
          ),
        );

        final drawerItems = ListView(
          controller: scrollController,
          children: <Widget>[
            drawerHeader,
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings),
              minLeadingWidth: 0,
              title: const Text('Settings', style: TextStyle(fontSize: 18.0)),
              onTap: () => _navigateToSettingsPage(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              minLeadingWidth: 0,
              title: const Text('Info', style: TextStyle(fontSize: 18.0)),
              onTap: () => _navigateToInfoPage(context),
            ),
          ],
        );

        return SafeArea(
          child: Drawer(
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 10,
              radius: const Radius.circular(6),
              child: drawerItems,
            ),
          ),
        );
      },
    );
  }
}
