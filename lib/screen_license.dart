import 'package:flutter/material.dart';

import 'oss_licenses.dart';
import 'screen_about_app.i18n.dart';

class LicenseDisclaimerPage extends StatelessWidget {
  static const String routeName = 'license';

  static final Map<String, String> licenseOverrides = {
    'apple_sign_in': 'MIT License',
  };

  static final Map<String, String> additionalLicenses = {
    'Avatar User': 'By endang firmansyah. '
        'Creative Commons (Attribution 3.0 Unported). '
        'https://www.iconfinder.com/iconsets/avatar-user'
  };

  static final Set<String> testOnlyDependencies = {
    'sqflite_common_ffi',
  };

  Widget createSection(
      String packageKey, Map<String, dynamic> libraryCopyright) {
    var license = licenseOverrides.containsKey(packageKey)
        ? licenseOverrides[packageKey]
        : libraryCopyright['license'] as String;
    if (license.contains('TODO: Add your license')) {
      license = 'unknown';
    }

    return LibraryLicenseSection(libraryCopyright['name'] as String, license);
  }

  List<Widget> createLibrarySections() {
    final ossLicensesMap = ossLicenses;
    final ret = <Widget>[];
    for (final packageKey in additionalLicenses.keys) {
      ret.add(
          LibraryLicenseSection(packageKey, additionalLicenses[packageKey]));
    }
    for (final packageKey in ossLicensesMap.keys) {
      if (testOnlyDependencies.contains(packageKey)) {
        continue;
      }
      ret.add(createSection(
          packageKey, ossLicensesMap[packageKey] as Map<String, dynamic>));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      const SizedBox(height: 8),
      Text(thankYouOss.i18n),
      ...createLibrarySections()
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Copyright'.i18n),
        actions: const <Widget>[],
      ),
      body: Builder(builder: (BuildContext context) {
        const margin = 16.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: margin),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: sections,
          ),
        );
      }),
    );
  }
}

class LibraryLicenseSection extends StatelessWidget {
  const LibraryLicenseSection(this.name, this.license);
  final String name;
  final String license;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            name,
            style: textTheme.headline6,
          ),
          Text(
            license,
            style: textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
