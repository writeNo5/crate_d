import 'package:isar/isar.dart';

part 'vinyl.g.dart';

@collection
class Vinyl {
  Id id;
  
  final String title;
  final String artist;
  final String coverUrl;
  final double? minPrice;
  final double? avgPrice;
  final double? maxPrice;
  final String genre;
  final int year;
  
  @Index(type: IndexType.value)
  DateTime? addedAt;

  Vinyl({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.minPrice,
    this.avgPrice,
    this.maxPrice,
    required this.genre,
    required this.year,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
