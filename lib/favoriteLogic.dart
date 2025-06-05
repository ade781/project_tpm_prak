import 'package:hive/hive.dart';
import 'package:project_tpm_prak/models/boxes.dart';
import 'package:project_tpm_prak/models/favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favoritelogic {
  late Box<Favorite> favBox;
  List<Favorite> userFavorites = [];
  String? userId;

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('username') ?? 'User';

    favBox = Hive.box<Favorite>(HiveBox.favorites);
    loadFavorites();
  }

  void loadFavorites() {
    final allFavs = favBox.values.toList();
    userFavorites = allFavs.where((f) => f.userId == userId).toList();
  }

  bool isFavorited(String movId) {
    return userFavorites.any((f) => f.movieId == movId);
  }

  void toggleFavorite(String movId) async {
    final match =
        favBox.values.where((f) => f.userId == userId && f.movieId == movId);
    final existing = match.isNotEmpty ? match.first : null;

    if (existing != null) {
      await existing.delete(); // Jika sudah ada, hapus
    } else {
      await favBox.add(
          Favorite(userId: userId!, movieId: movId)); // Jika belum, tambahkan
    }

    loadFavorites(); // Refresh tampilan
  }
}
