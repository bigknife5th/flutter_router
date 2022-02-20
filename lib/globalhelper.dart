import 'package:flutter/material.dart';

import 'test/localization_test.dart';

class gh {
  static String getlzString(BuildContext c, String s) {
    return AppLocalizations.of(c).getString(s);
  }
}
