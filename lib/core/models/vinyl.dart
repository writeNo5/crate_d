class Vinyl {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final double? minPrice;
  final double? avgPrice;
  final double? maxPrice;
  final String genre;
  final int year;

  Vinyl({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.minPrice,
    this.avgPrice,
    this.maxPrice,
    required this.genre,
    required this.year,
  });
}
