import 'package:hive/hive.dart';
part 'favorite.g.dart';
@HiveType(typeId: 1)
class Favorite extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String movieId;

  Favorite({required this.userId, required this.movieId});
  
}