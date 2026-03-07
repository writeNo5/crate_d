import '../../../core/models/vinyl.dart';

class MockData {
  static List<Vinyl> getVinyls() {
    final List<Map<String, String>> premiumVinyls = [
      {'title': 'Midnight Echoes', 'artist': 'The Jazz Quintet', 'image': 'assets/images/jazz.png'},
      {'title': 'Synth Wave City', 'artist': 'Neon Arch', 'image': 'assets/images/electronic.png'},
      {'title': 'Golden Horizon', 'artist': 'Desert Rockers', 'image': 'assets/images/rock.png'},
      {'title': 'Ethereal Drift', 'artist': 'Ambient Soul', 'image': 'assets/images/ambient.png'},
    ];

    return List.generate(100, (index) {
      final p = premiumVinyls[index % premiumVinyls.length];
      return Vinyl(
        id: 'v$index',
        title: p['title']!,
        artist: p['artist']!,
        coverUrl: p['image']!,
        minPrice: 20.0 + (index % 10),
        avgPrice: 35.0 + (index % 10),
        maxPrice: 50.0 + (index % 10),
        genre: index % 4 == 0 ? 'Jazz' : (index % 4 == 1 ? 'Electronic' : (index % 4 == 2 ? 'Rock' : 'Ambient')),
        year: 1970 + (index % 50),
      );
    });
  }
}
