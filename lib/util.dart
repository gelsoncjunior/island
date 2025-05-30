import 'dart:math';
import 'dart:ui';

/// Classe responsável por gerar cores neutras aleatórias
/// Ideal para headers de calendário e interfaces elegantes
/// Aplica o Princípio da Responsabilidade Única (SRP)
class NeutralColorGenerator {
  static final Random _random = Random();

  /// Lista de cores neutras e elegantes em formato hexadecimal
  /// Perfeitas para headers de calendário (D S T QQ SS)
  static const List<int> _neutralColors = [
    0xFF2C3E50, // Azul escuro elegante
    0xFF34495E, // Azul acinzentado
    0xFF5D6D7E, // Cinza azulado
    0xFF566573, // Cinza médio
    0xFF708090, // Cinza ardósia
    0xFF778899, // Cinza claro azulado
    0xFF95A5A6, // Cinza prateado
    0xFF85929E, // Cinza suave
    0xFF6C7B7F, // Cinza esverdeado
    0xFF5F6A6A, // Cinza escuro suave
    0xFF515A5A, // Cinza chumbo
    0xFF424949, // Cinza antracite
    0xFF37474F, // Azul acinzentado escuro
    0xFF455A64, // Azul cinza
    0xFF546E7A, // Azul cinza médio
    0xFF607D8B, // Azul cinza claro
  ];

  /// Retorna uma cor neutra aleatória
  ///
  /// Returns:
  ///   Color: Uma cor neutra selecionada aleatoriamente
  ///
  /// Example:
  /// ```dart
  /// Color headerColor = NeutralColorGenerator.getRandomNeutralColor();
  /// ```
  static Color getRandomNeutralColor() {
    final int randomIndex = _random.nextInt(_neutralColors.length);
    return Color(_neutralColors[randomIndex]);
  }

  /// Retorna múltiplas cores neutras aleatórias únicas
  ///
  /// Parameters:
  ///   count: Número de cores a serem geradas (máximo: 16)
  ///
  /// Returns:
  ///
  /// Throws:
  ///   ArgumentError: Se count for menor que 1 ou maior que 16
  static List<Color> getMultipleRandomNeutralColors(int count) {
    if (count < 1 || count > _neutralColors.length) {
      throw ArgumentError(
          'O número de cores deve estar entre 1 e ${_neutralColors.length}');
    }

    final List<int> shuffledColors = List.from(_neutralColors)
      ..shuffle(_random);
    return shuffledColors
        .take(count)
        .map((colorValue) => Color(colorValue))
        .toList();
  }

  /// Retorna cores específicas para os dias da semana do calendário
  /// Ideal para headers: D S T QQ SS
  ///
  /// Returns:
  static List<Color> getCalendarHeaderColors() {
    return [
      Color(0xFF2C3E50), // Domingo - Azul escuro elegante
      Color(0xFF34495E), // Segunda - Azul acinzentado
      Color(0xFF566573), // Terça - Cinza médio
      Color(0xFF5D6D7E), // Quarta - Cinza azulado
      Color(0xFF708090), // Quinta - Cinza ardósia
      Color(0xFF778899), // Sexta - Cinza claro azulado
      Color(0xFF85929E), // Sábado - Cinza prateado
    ];
  }

  /// Retorna o número total de cores neutras disponíveis
  static int get availableColorsCount => _neutralColors.length;
}

/// Função utilitária para obter uma cor neutra aleatória
/// Wrapper simples para facilitar o uso em headers de calendário
Color getRandomNeutralColor() {
  return NeutralColorGenerator.getRandomNeutralColor();
}

/// Função específica para obter cores de header de calendário
/// Retorna as 7 cores ideais para os dias da semana
List<Color> getCalendarHeaderColors() {
  return NeutralColorGenerator.getCalendarHeaderColors();
}
