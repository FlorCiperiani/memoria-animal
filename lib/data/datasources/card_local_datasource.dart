import 'dart:math';

import '../../domain/entities/game_style.dart';

/// Fuente de datos local con los símbolos de las fichas según el estilo y modo (claro/oscuro).
class CardLocalDataSource {
  const CardLocalDataSource();

  static const Map<GameStyle, Map<bool, List<String>>> _symbolsByStyleAndMode =
      {
        GameStyle.classic: {
          false: ['🐶', '🐱', '🐼', '🐸', '🐨', '🦊', '🐰', '🦁', '🐯'],
          true: ['🦉', '🦇', '🦝', '🦡', '🐺', '🦊', '🐈‍⬛', '🦔', '🦨'],
        },
        GameStyle.desert: {
          false: ['🐪', '🦎', '🐢', '🐫', '🐦', '🦅', '🦤', '🪲', '🦂'],
          true: ['🦂', '🕷️', '🦊', '🐁', '🐈', '🐍', '🦇', '🪱', '🐪'],
        },
        GameStyle.jungle: {
          false: ['🐒', '🦜', '🦋', '🐘', '🦚', '🦧', '🦎', '🦍', '🐅'],
          true: ['🦥', '🐊', '🦇', '🐍', '🐸', '🐆', '🦟', '🦗', '🐒'],
        },
        GameStyle.savanna: {
          false: ['🦁', '🦒', '🦓', '🦏', '🦛', '🐃', '🐘', '🦩', '🐆'],
          true: ['🐆', '🦔', '🦇', '🐈', '🦡', '🐺', '🦊', '🦝', '🦁'],
        },
        GameStyle.forest: {
          false: ['🐝', '🐞', '🦃', '🐻', '🦌', '🐿️', '🦋', '🐦', '🦊'],
          true: ['🦉', '🦦', '🦝', '🦡', '🦔', '🦇', '🦊', '🐺', '🐻'],
        },
        GameStyle.prairie: {
          false: ['🦬', '🐎', '🦌', '🐿️', '🦫', '🦅', '🐇', '🐝', '🦨'],
          true: ['🐺', '🦡', '🦊', '🦉', '🐁', '🐍', '🦨', '🐈', '🦬'],
        },
        GameStyle.mountains: {
          false: ['🐐', '🐂', '🦙', '🦅', '🐿️', '🐏', '🐻', '🦃', '🐆'],
          true: ['🐆', '🐈‍⬛', '🐈', '🦇', '🦦', '🦝', '🐺', '🦊', '🐐'],
        },
        GameStyle.tundra: {
          false: ['🦌', '🐂', '🐻‍❄️', '🐋', '🐟', '🪿', '🦭', '🐇', '🦊'],
          true: ['🐺', '🦊', '🦉', '🐁', '🐇', '🦡', '🐻', '🦭', '🐋'],
        },
      };

  static const Map<GameStyle, Map<bool, List<String>>>
  _additionalSymbolsByStyleAndMode = {
    GameStyle.classic: {
      false: ['🐬', '🦩', '🦀', '🦢'],
      true: ['🦑', '🦞', '🐠', '🐒'],
    },
    GameStyle.desert: {
      false: ['🐦', '🦌', '🐤', '🦅'],
      true: ['🦊', '🐁', '🐈', '🐍'],
    },
    GameStyle.jungle: {
      false: ['🦎', '🦏', '🐦', '🦍'],
      true: ['🦇', '🐍', '🐸', '🐆'],
    },
    GameStyle.savanna: {
      false: ['🐘', '🐦', '🐗', '🐒'],
      true: ['🐜', '🐒', '🐈', '🦔'],
    },
    GameStyle.forest: {
      false: ['🦌', '🐿️', '🦋', '🐦'],
      true: ['🦡', '🐀', '🦔', '🦝'],
    },
    GameStyle.prairie: {
      false: ['🐇', '🦋', '🐦', '🐝'],
      true: ['🐦', '🦨', '🐈', '🐀'],
    },
    GameStyle.mountains: {
      false: ['🐻', '🐐', '🐿️', '🦃'],
      true: ['🐆', '🐈', '🐁', '🐇'],
    },
    GameStyle.tundra: {
      false: ['🦭', '🫎', '🪿', '🐇'],
      true: ['🐁', '🐻', '🦭', '🐻‍❄️'],
    },
  };

  static const Map<GameStyle, Map<bool, Map<String, String>>>
  _additionalAnimalNamesByStyleAndMode = {
    GameStyle.classic: {
      false: {
        '🐬': 'Delfín nariz de botella',
        '🦩': 'Flamenco',
        '🦀': 'Cangrejo violinista',
        '🦢': 'Cisne',
      },
      true: {
        '🦑': 'Calamar',
        '🦞': 'Langosta',
        '🐠': 'Pez león',
        '🐒': 'Lémur nocturno',
      },
    },
    GameStyle.desert: {
      false: {
        '🐦': 'Correcaminos',
        '🦌': 'Addax',
        '🐤': 'Alondra del desierto',
        '🦅': 'Buitre egipcio',
      },
      true: {
        '🦊': 'Zorro fénec',
        '🐁': 'Jerbo',
        '🐈': 'Gato de las arenas',
        '🐍': 'Víbora cornuda del desierto',
      },
    },
    GameStyle.jungle: {
      false: {
        '🦎': 'Iguana verde',
        '🦏': 'Rinoceronte de Sumatra',
        '🐦': 'Tucán',
        '🦍': 'Gorila',
      },
      true: {
        '🦇': 'Murciélago frutero',
        '🐍': 'Boa',
        '🐸': 'Rana arborícola',
        '🐆': 'Jaguar',
      },
    },
    GameStyle.savanna: {
      false: {
        '🐘': 'Elefante africano',
        '🐦': 'Avestruz',
        '🐗': 'Facóquero',
        '🐒': 'Babuino',
      },
      true: {
        '🐜': 'Hormiga nocturna de la sabana',
        '🐒': 'Gálago',
        '🐈': 'Caracal',
        '🦔': 'Puercoespín africano',
      },
    },
    GameStyle.forest: {
      false: {
        '🦌': 'Ciervo rojo',
        '🐿️': 'Ardilla roja',
        '🦋': 'Mariposa macaón',
        '🐦': 'Pájaro carpintero',
      },
      true: {
        '🦡': 'Tejón europeo',
        '🐀': 'Lirón gris',
        '🦔': 'Erizo europeo',
        '🦝': 'Mapache',
      },
    },
    GameStyle.prairie: {
      false: {
        '🐇': 'Liebre de cola negra',
        '🦋': 'Mariposa de la pradera',
        '🐦': 'Alondra de las praderas',
        '🐝': 'Abejorro',
      },
      true: {
        '🐦': 'Chotacabras de las praderas',
        '🦨': 'Zorrino rayado',
        '🐈': 'Gato montés',
        '🐀': 'Topillo de la pradera',
      },
    },
    GameStyle.mountains: {
      false: {
        '🐻': 'Oso pardo',
        '🐐': 'Íbice alpino',
        '🐿️': 'Marmota alpina',
        '🦃': 'Perdiz nival',
      },
      true: {
        '🐆': 'Gato de Pallas',
        '🐈': 'Lince ibérico',
        '🐁': 'Comadreja de montaña',
        '🐇': 'Liebre de montaña',
      },
    },
    GameStyle.tundra: {
      false: {
        '🦭': 'Foca anillada',
        '🫎': 'Alce boreal',
        '🪿': 'Ganso nival',
        '🐇': 'Liebre ártica',
      },
      true: {
        '🐁': 'Musaraña ártica',
        '🐻': 'Glotón',
        '🦭': 'Morsa',
        '🐻‍❄️': 'Oso polar',
      },
    },
  };

  static const Map<GameStyle, Map<bool, Map<String, String>>>
  _animalNamesByStyleAndMode = {
    GameStyle.prairie: {
      false: {
        '🦬': 'Bisonte americano',
        '🐎': 'Mustang',
        '🦌': 'Berrendo',
        '🐿️': 'Perrito de la pradera',
        '🦫': 'Marmota de las praderas',
        '🦅': 'Aguilucho real',
      },
      true: {
        '🐺': 'Coyote',
        '🦡': 'Tejón americano',
        '🦊': 'Zorro veloz',
        '🦉': 'Búho campestre',
        '🐁': 'Ratón de campo',
        '🐍': 'Serpiente de cascabel',
      },
    },
    GameStyle.mountains: {
      false: {
        '🐐': 'Cabra montés',
        '🐂': 'Yak',
        '🦙': 'Llama',
        '🦅': 'Cóndor andino',
        '🐿️': 'Pika',
        '🐏': 'Argali',
      },
      true: {
        '🐆': 'Puma',
        '🐈‍⬛': 'Leopardo de las nieves',
        '🐈': 'Lince boreal',
        '🦇': 'Murciélago de montaña',
        '🦦': 'Marta',
        '🦝': 'Gineta',
      },
    },
    GameStyle.tundra: {
      false: {
        '🦌': 'Caribú',
        '🐂': 'Buey almizclero',
        '🐻‍❄️': 'Oso polar',
        '🐋': 'Ballena beluga',
        '🐟': 'Trucha ártica',
        '🪿': 'Ganso nival',
      },
      true: {
        '🐺': 'Lobo ártico',
        '🦊': 'Zorro ártico',
        '🦉': 'Búho nival',
        '🐁': 'Lemming',
        '🐇': 'Liebre ártica',
        '🦡': 'Armiño',
      },
    },
  };

  static const Map<GameStyle, Map<String, String>> _animalFactsByStyle = {
    GameStyle.classic: {
      '🐶': 'Los perros pueden aprender a reconocer muchas palabras.',
      '🐱': 'Los bigotes ayudan a los gatos a calcular si caben en un lugar.',
      '🐼': 'Los pandas pasan muchas horas comiendo bambú.',
      '🐸': 'Muchas ranas beben agua a través de su piel.',
      '🐨': 'Los koalas duermen hasta unas 20 horas al día.',
      '🦤': 'El dodo era un ave que no podía volar.',
      '🐷': 'Los cerdos son animales muy inteligentes.',
      '🐔': 'Las gallinas pueden reconocer a otras gallinas de su grupo.',
      '🦆': 'Las plumas de los patos ayudan a mantenerlos secos.',
      '🐑': 'La lana de las ovejas crece continuamente.',
      '🐙': 'Los pulpos tienen tres corazones.',
      '🐹': 'A los hámsteres les gusta guardar comida en sus mejillas.',
    },
    GameStyle.desert: {
      '🐪': 'Los camellos pueden pasar mucho tiempo sin beber agua.',
      '🦎': 'Algunos lagartos pueden desprenderse de la cola para escapar.',
      '🦂': 'Los escorpiones brillan bajo una luz ultravioleta.',
      '🐢': 'El caparazón de una tortuga forma parte de su esqueleto.',
      '🐫': 'El camello bactriano tiene dos jorobas.',
      '🐜': 'Las hormigas dejan rastros de olor para guiar a sus compañeras.',
      '🕷️': 'Las arañas tienen ocho patas.',
      '🪲': 'Muchos escarabajos tienen un caparazón duro que protege sus alas.',
      '🪰': 'Las moscas prueban los alimentos con sus patas.',
      '🐌': 'Los caracoles llevan su concha a cuestas.',
      '🪱': 'Las lombrices ayudan a airear y enriquecer la tierra.',
    },
    GameStyle.jungle: {
      '🐒': 'Los monos usan sus manos para agarrar ramas y alimentos.',
      '🦜': 'Algunos loros pueden imitar sonidos que escuchan.',
      '🦋': 'Las mariposas prueban sabores con sus patas.',
      '🐘': 'Las orejas grandes ayudan a los elefantes a refrescarse.',
      '🦚': 'El pavo real despliega su cola en forma de abanico.',
      '🦧': 'Los orangutanes construyen nidos para dormir en los árboles.',
      '🦥': 'Los perezosos se mueven despacio y viven en los árboles.',
      '🐊': 'Los cocodrilos tienen ojos y fosas nasales en la parte alta de la cabeza.',
      '🦟': 'Solo las hembras de mosquito pican para obtener sangre.',
      '🐛': 'Las orugas comen mucho antes de convertirse en mariposas.',
      '🦗': 'Los grillos producen su canto frotando sus alas.',
      '🪳': 'Las cucarachas usan sus antenas para explorar lo que las rodea.',
    },
    GameStyle.savanna: {
      '🦁': 'Los leones viven en grupos llamados manadas.',
      '🦒': 'Cada jirafa tiene un patrón de manchas único.',
      '🦓': 'Las rayas de cada cebra son diferentes, como una huella.',
      '🦏': 'El cuerno del rinoceronte está hecho de queratina, como nuestras uñas.',
      '🦛': 'Los hipopótamos pasan gran parte del día en el agua.',
      '🐃': 'Los búfalos viven en grupos que se protegen entre sí.',
      '🦔': 'Los erizos tienen púas que les sirven de protección.',
    },
    GameStyle.forest: {
      '🐝': 'Las abejas ayudan a polinizar muchas plantas y flores.',
      '🐞': 'Las mariquitas comen pulgones que dañan las plantas.',
      '🦃': 'Los pavos pueden correr rápido aunque no vuelen muy lejos.',
      '🐻': 'Los osos tienen un olfato muy desarrollado.',
      '🦉': 'Muchas lechuzas pueden volar casi sin hacer ruido.',
      '🦦': 'Las nutrias marinas a veces se toman de las patas para no separarse.',
      '🦝': 'Los mapaches tienen patas muy hábiles para explorar objetos.',
      '🦨': 'Los zorrinos usan un olor intenso para defenderse.',
    },
    GameStyle.prairie: {
      '🦬': 'Los bisontes se revuelcan en el polvo para cuidar su pelaje.',
      '🐎': 'Los caballos pueden dormir de pie durante ratos cortos.',
      '🦌': 'Los berrendos son corredores muy veloces.',
      '🐿️': 'Los perritos de la pradera viven en madrigueras conectadas.',
      '🦫': 'Los castores construyen refugios con ramas y barro.',
      '🦅': 'Las aves rapaces tienen una vista excelente para encontrar alimento.',
      '🐺': 'Los coyotes se comunican con aullidos y otros sonidos.',
      '🦡': 'Los tejones excavan madrigueras con sus fuertes garras.',
      '🦊': 'El zorro veloz puede correr rápidamente por la pradera.',
      '🦉': 'El búho campestre suele buscar alimento en espacios abiertos.',
      '🐁': 'Los ratones usan sus bigotes para orientarse en lugares oscuros.',
      '🐍': 'Las serpientes de cascabel avisan con su cola cuando se sienten amenazadas.',
    },
    GameStyle.mountains: {
      '🐐': 'Las cabras monteses trepan por rocas empinadas con sus pezuñas.',
      '🐂': 'Los yaks tienen un pelaje grueso que los protege del frío de altura.',
      '🦙': 'Las llamas viven en las montañas de los Andes.',
      '🦅': 'Los cóndores andinos planean aprovechando las corrientes de aire.',
      '🐿️': 'Las pikas guardan plantas para tener comida durante el invierno.',
      '🐏': 'Los argalíes son ovejas salvajes que viven en montañas de Asia.',
      '🐆': 'Los pumas pueden saltar grandes distancias.',
      '🐈‍⬛': 'Los leopardos de las nieves tienen patas anchas que les ayudan sobre la nieve.',
      '🐈': 'Los linces tienen mechones de pelo en las puntas de las orejas.',
      '🦇': 'Los murciélagos se orientan usando sonidos y sus ecos.',
      '🦦': 'Las martas pueden moverse con agilidad entre árboles y rocas.',
      '🦝':
          'Las ginetas son trepadoras ágiles y suelen estar activas de noche.',
    },
    GameStyle.tundra: {
      '🦌': 'Los caribúes recorren largas distancias durante sus migraciones.',
      '🐂': 'El buey almizclero tiene un abrigo espeso para soportar el frío.',
      '🐻‍❄️': 'La piel del oso polar es negra bajo su pelaje claro.',
      '🐋': 'Las belugas se comunican con muchos sonidos diferentes.',
      '🐟': 'La trucha ártica puede vivir en aguas muy frías.',
      '🪿': 'Los gansos nivales viajan en bandadas durante sus migraciones.',
      '🐺': 'El lobo ártico tiene un pelaje que lo abriga en el frío.',
      '🦊': 'El zorro ártico cambia de pelaje según la estación.',
      '🦉': 'El búho nival tiene plumas en las patas para protegerse del frío.',
      '🐁': 'Los lemmings hacen túneles bajo la nieve.',
      '🐇': 'La liebre ártica tiene un pelaje que la camufla en la nieve.',
      '🦡': 'El armiño cambia a un pelaje blanco en invierno.',
    },
  };

  List<String> getSymbols(GameStyle style, bool isDark, int pairsCount) {
    final existingSymbols =
        _symbolsByStyleAndMode[style]?[isDark] ??
        _symbolsByStyleAndMode[GameStyle.classic]![false]!;
    final additionalSymbols =
        _additionalSymbolsByStyleAndMode[style]?[isDark] ?? const <String>[];
    final availableSymbols = [...existingSymbols, ...additionalSymbols];
    if (pairsCount < 1 || pairsCount > availableSymbols.length) {
      throw ArgumentError.value(
        pairsCount,
        'pairsCount',
        'Debe estar entre 1 y ${availableSymbols.length}',
      );
    }
    return availableSymbols.take(pairsCount).toList();
  }

  String? getAnimalName(GameStyle style, bool isDark, String symbol) =>
      _additionalAnimalNamesByStyleAndMode[style]?[isDark]?[symbol] ??
      _animalNamesByStyleAndMode[style]?[isDark]?[symbol];

  String? getRandomAnimalFact(GameStyle style, List<String> symbols) {
    final facts = _animalFactsByStyle[style];
    if (facts == null) return null;
    final addedSymbols = {
      ...?_additionalSymbolsByStyleAndMode[style]?[false],
      ...?_additionalSymbolsByStyleAndMode[style]?[true],
    };

    final availableFacts = symbols
        .where((symbol) => !addedSymbols.contains(symbol))
        .map((symbol) => facts[symbol])
        .whereType<String>()
        .toList();
    if (availableFacts.isEmpty) return null;

    return availableFacts[Random().nextInt(availableFacts.length)];
  }
}
