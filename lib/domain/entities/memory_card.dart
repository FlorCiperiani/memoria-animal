import 'package:equatable/equatable.dart';

/// Estado visual/lógico de una ficha.
enum CardStatus {
  /// Boca abajo.
  hidden,

  /// Boca arriba (seleccionada o en la vista previa).
  revealed,

  /// Boca arriba y marcada en rojo porque no era par.
  mismatched,

  /// Par encontrado: desaparece del tablero.
  matched,
}

class MemoryCard extends Equatable {
  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.symbol,
    this.customAnimalName,
    this.status = CardStatus.hidden,
  });

  /// Identificador único de la ficha en el tablero.
  final int id;

  /// Identificador compartido por las dos fichas que forman un par.
  final int pairId;

  /// Emoji que se muestra en la cara de la ficha.
  final String symbol;
  final String? customAnimalName;

  String get animalName =>
      customAnimalName ??
      switch (symbol) {
        '🐶' => 'Perro',
        '🐱' => 'Gato',
        '🦊' => 'Zorro',
        '🐼' => 'Panda',
        '🐸' => 'Rana',
        '🐒' => 'Mono',
        '🦁' => 'León',
        '🐯' => 'Tigre',
        '🐅' => 'Tigre',
        '🐨' => 'Koala',
        '🐧' => 'Pingüino',
        '🐰' => 'Conejo',
        '🐻' => 'Oso',
        '🐪' => 'Camello',
        '🐫' => 'Camello bactriano',
        '🦎' => 'Lagarto',
        '🦅' => 'Águila',
        '🐢' => 'Tortuga',
        '🐇' => 'Liebre',
        '🐍' => 'Serpiente',
        '🐿️' => 'Ardilla',
        '🦡' => 'Tejón',
        '🦘' => 'Canguro',
        '🦝' => 'Mapache',
        '🐝' => 'Abeja',
        '🦩' => 'Flamenco',
        '🦉' => 'Búho',
        '🦂' => 'Escorpión',
        '🦇' => 'Murciélago',
        '🕷️' => 'Araña',
        '🪲' => 'Escarabajo',
        '🪰' => 'Mosca',
        '🐌' => 'Caracol',
        '🪱' => 'Lombriz',
        '🦟' => 'Mosquito',
        '🐛' => 'Oruga',
        '🦗' => 'Grillo',
        '🪳' => 'Cucaracha',
        '🐁' => 'Ratón',
        '🐺' => 'Lobo',
        '🦨' => 'Zorrino',
        '🐈' => 'Gato montés',
        '🦔' => 'Erizo',
        '🐆' => 'Leopardo',
        '🦜' => 'Loro',
        '🦋' => 'Mariposa',
        '🐘' => 'Elefante',
        '🦥' => 'Perezoso',
        '🐊' => 'Cocodrilo',
        '🦚' => 'Pavo real',
        '🦧' => 'Orangután',
        '🦒' => 'Jirafa',
        '🦓' => 'Cebra',
        '🦏' => 'Rinoceronte',
        '🦛' => 'Hipopótamo',
        '🐃' => 'Búfalo',
        '🐦' => 'Pájaro',
        '🦌' => 'Ciervo',
        '🐵' => 'Mono',
        '🐷' => 'Cerdo',
        '🐔' => 'Gallina',
        '🦆' => 'Pato',
        '🐑' => 'Oveja',
        '🐙' => 'Pulpo',
        '🐹' => 'Hámster',
        '🐜' => 'Hormiga',
        '🦬' => 'Bisonte',
        '🐎' => 'Caballo',
        '🦙' => 'Llama',
        '🐏' => 'Carnero',
        '🐈‍⬛' => 'Gato negro',
        '🐂' => 'Buey',
        '🐋' => 'Ballena',
        '🐟' => 'Pez',
        '🪿' => 'Ganso',
        '🦤' => 'Dodo',
        '🐞' => 'Mariquita',
        '🦃' => 'Pavo',
        '🦦' => 'Nutria',
        '🦫' => 'Castor',
        '🐻‍❄️' => 'Oso polar',
        '🦭' => 'Foca',
        '🫎' => 'Alce',
        '🦢' => 'Cisne',
        '🐬' => 'Delfín',
        '🦀' => 'Cangrejo',
        '🦑' => 'Calamar',
        '🦞' => 'Langosta',
        '🐠' => 'Pez tropical',
        '🦍' => 'Gorila',
        _ => 'Animal desconocido',
      };

  final CardStatus status;

  bool get isFaceUp => status != CardStatus.hidden;
  bool get isMatched => status == CardStatus.matched;

  MemoryCard copyWith({CardStatus? status}) {
    return MemoryCard(
      id: id,
      pairId: pairId,
      symbol: symbol,
      customAnimalName: customAnimalName,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, pairId, symbol, customAnimalName, status];
}
