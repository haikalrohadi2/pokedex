/// Fungsi bantu kecil untuk memformat teks.
library;

/// 25 -> "#025"
String formatNumber(int id) => '#${id.toString().padLeft(3, '0')}';

/// "mr-mime" -> "Mr Mime"
String prettyName(String raw) {
  return raw
      .split('-')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// Nama stat dari API -> label yang mudah dibaca.
String statLabel(String apiName) {
  switch (apiName) {
    case 'hp':
      return 'HP';
    case 'attack':
      return 'Attack';
    case 'defense':
      return 'Defense';
    case 'special-attack':
      return 'Special Attack';
    case 'special-defense':
      return 'Special Defense';
    case 'speed':
      return 'Speed';
    default:
      return prettyName(apiName);
  }
}
