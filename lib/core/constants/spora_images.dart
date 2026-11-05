/// Real football imagery served from the Unsplash CDN (hot-linkable, stable).
/// Used for all mock photos so screens match the Figma's real-photo look.
const _kBase = 'https://images.unsplash.com/';

const sporaFootballPhotos = <String>[
  'photo-1522778119026-d647f0596c20', // player striking ball
  'photo-1579952363873-27f3bade9f55', // stadium floodlights
  'photo-1574629810360-7efbbe195018', // stadium aerial
  'photo-1560272564-c83b66b1ad12', // player dribbling
  'photo-1553778263-73a83bab9b0c', // ball on pitch
  'photo-1431324155629-1a6deb1dec8d', // kids playing match
  'photo-1606925797300-0b35e9d1794e', // goalkeeper
  'photo-1556056504-5c7696c4c28d', // match action
  'photo-1459865264687-595d652de67e', // kick on grass
  'photo-1517466787929-bc90951d0974', // pitch
  'photo-1526232761682-d26e03ac148e', // ball close-up
];

String sporaImage(Object? seed, {int w = 800, int h = 600}) {
  final i = (seed?.hashCode ?? 0).abs() % sporaFootballPhotos.length;
  return '$_kBase${sporaFootballPhotos[i]}?w=$w&h=$h&fit=crop&auto=format&q=80';
}
