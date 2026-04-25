class CountryCode {
  final String name;
  final String dialCode;
  final String code;
  final String flag;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.code,
    required this.flag,
  });
}

const List<CountryCode> countryCodes = [
  CountryCode(name: 'Sri Lanka', dialCode: '+94', code: 'LK', flag: '🇱🇰'),
  CountryCode(name: 'India', dialCode: '+91', code: 'IN', flag: '🇮🇳'),
  CountryCode(name: 'United States', dialCode: '+1', code: 'US', flag: '🇺🇸'),
  CountryCode(name: 'United Kingdom', dialCode: '+44', code: 'GB', flag: '🇬🇧'),
  CountryCode(name: 'Australia', dialCode: '+61', code: 'AU', flag: '🇦🇺'),
  CountryCode(name: 'Canada', dialCode: '+1', code: 'CA', flag: '🇨🇦'),
  CountryCode(name: 'Germany', dialCode: '+49', code: 'DE', flag: '🇩🇪'),
  CountryCode(name: 'France', dialCode: '+33', code: 'FR', flag: '🇫🇷'),
  CountryCode(name: 'Japan', dialCode: '+81', code: 'JP', flag: '🇯🇵'),
  CountryCode(name: 'China', dialCode: '+86', code: 'CN', flag: '🇨🇳'),
  CountryCode(name: 'South Korea', dialCode: '+82', code: 'KR', flag: '🇰🇷'),
  CountryCode(name: 'Singapore', dialCode: '+65', code: 'SG', flag: '🇸🇬'),
  CountryCode(name: 'Malaysia', dialCode: '+60', code: 'MY', flag: '🇲🇾'),
  CountryCode(name: 'Thailand', dialCode: '+66', code: 'TH', flag: '🇹🇭'),
  CountryCode(name: 'Indonesia', dialCode: '+62', code: 'ID', flag: '🇮🇩'),
  CountryCode(name: 'Philippines', dialCode: '+63', code: 'PH', flag: '🇵🇭'),
  CountryCode(name: 'Pakistan', dialCode: '+92', code: 'PK', flag: '🇵🇰'),
  CountryCode(name: 'Bangladesh', dialCode: '+880', code: 'BD', flag: '🇧🇩'),
  CountryCode(name: 'Nepal', dialCode: '+977', code: 'NP', flag: '🇳🇵'),
  CountryCode(name: 'Maldives', dialCode: '+960', code: 'MV', flag: '🇲🇻'),
  CountryCode(name: 'United Arab Emirates', dialCode: '+971', code: 'AE', flag: '🇦🇪'),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', code: 'SA', flag: '🇸🇦'),
  CountryCode(name: 'Qatar', dialCode: '+974', code: 'QA', flag: '🇶🇦'),
  CountryCode(name: 'Kuwait', dialCode: '+965', code: 'KW', flag: '🇰🇼'),
  CountryCode(name: 'Oman', dialCode: '+968', code: 'OM', flag: '🇴🇲'),
  CountryCode(name: 'Bahrain', dialCode: '+973', code: 'BH', flag: '🇧🇭'),
  CountryCode(name: 'Italy', dialCode: '+39', code: 'IT', flag: '🇮🇹'),
  CountryCode(name: 'Spain', dialCode: '+34', code: 'ES', flag: '🇪🇸'),
  CountryCode(name: 'Netherlands', dialCode: '+31', code: 'NL', flag: '🇳🇱'),
  CountryCode(name: 'Sweden', dialCode: '+46', code: 'SE', flag: '🇸🇪'),
  CountryCode(name: 'Norway', dialCode: '+47', code: 'NO', flag: '🇳🇴'),
  CountryCode(name: 'Denmark', dialCode: '+45', code: 'DK', flag: '🇩🇰'),
  CountryCode(name: 'Switzerland', dialCode: '+41', code: 'CH', flag: '🇨🇭'),
  CountryCode(name: 'Brazil', dialCode: '+55', code: 'BR', flag: '🇧🇷'),
  CountryCode(name: 'Mexico', dialCode: '+52', code: 'MX', flag: '🇲🇽'),
  CountryCode(name: 'South Africa', dialCode: '+27', code: 'ZA', flag: '🇿🇦'),
  CountryCode(name: 'Nigeria', dialCode: '+234', code: 'NG', flag: '🇳🇬'),
  CountryCode(name: 'Kenya', dialCode: '+254', code: 'KE', flag: '🇰🇪'),
  CountryCode(name: 'Egypt', dialCode: '+20', code: 'EG', flag: '🇪🇬'),
  CountryCode(name: 'Russia', dialCode: '+7', code: 'RU', flag: '🇷🇺'),
  CountryCode(name: 'Turkey', dialCode: '+90', code: 'TR', flag: '🇹🇷'),
  CountryCode(name: 'New Zealand', dialCode: '+64', code: 'NZ', flag: '🇳🇿'),
  CountryCode(name: 'Ireland', dialCode: '+353', code: 'IE', flag: '🇮🇪'),
  CountryCode(name: 'Portugal', dialCode: '+351', code: 'PT', flag: '🇵🇹'),
  CountryCode(name: 'Poland', dialCode: '+48', code: 'PL', flag: '🇵🇱'),
];
