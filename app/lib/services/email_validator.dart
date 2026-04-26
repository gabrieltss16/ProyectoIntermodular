class AppEmailValidator {
  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  static const Map<String, String> _commonDomainTypos = {
    'gmial.com': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.co': 'gmail.com',
    'hotnail.com': 'hotmail.com',
    'hotmai.com': 'hotmail.com',
    'outlok.com': 'outlook.com',
    'outllok.com': 'outlook.com',
  };

  static String? validate(String? rawValue) {
    final value = (rawValue ?? '').trim().toLowerCase();
    if (value.isEmpty) return 'Introduce un email.';

    final atCount = '@'.allMatches(value).length;
    if (atCount != 1) return 'Email no válido.';

    final parts = value.split('@');
    if (parts.length != 2) return 'Email no válido.';

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty || domain.isEmpty) return 'Email no válido.';

    final suggested = _commonDomainTypos[domain];
    if (suggested != null) {
      return '¿Querías decir $localPart@$suggested?';
    }

    if (!_emailRegex.hasMatch(value)) return 'Email no válido.';

    return null;
  }
}
