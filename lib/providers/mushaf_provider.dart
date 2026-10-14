import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/mushaf_models.dart';
import '../data/repositories/mushaf_repository.dart';

final mushafConfigProvider = FutureProvider<MushafConfig>((ref) async {
  return MushafRepository.instance.load();
});
