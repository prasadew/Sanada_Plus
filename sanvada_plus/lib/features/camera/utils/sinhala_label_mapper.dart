class SinhalaLabelMapper {
  static const Map<String, String> englishToSinhala = {
    'a': 'අ',
    'ba': 'බ',
    'bha': 'භ',
    'ga': 'ග',
    'ka': 'ක',
    'ma': 'ම',
    'na': 'න',
    'pa': 'ප',
    'ra': 'ර',
    'sa': 'ස',
    'sha': 'ශ',
    'ta': 'ට',
    'tha': 'ත',
    'va': 'ව',
    'ya': 'ය',
    'ch': 'ච',
    'chah': 'ඡ',
    'da': 'ද',
    'dha': 'ධ',
    'fa': 'ෆ',
    'ha': 'හ',
    'ja': 'ජ',
    'kha': 'ඛ',
    'la': 'ල',
    'nga': 'ඟ',
    'pha': 'ඵ',
  };

  static String toSinhala(String englishLabel) {
    final normalized = englishLabel.trim().toLowerCase();
    return englishToSinhala[normalized] ?? englishLabel;
  }
}
