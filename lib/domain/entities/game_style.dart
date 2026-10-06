enum GameStyle {
  classic,
  desert,
  jungle,
  savanna,
  forest,
  prairie,
  mountains,
  tundra,
}

extension GameStyleLabel on GameStyle {
  String get label => switch (this) {
    GameStyle.classic => 'Clásico',
    GameStyle.desert => 'Desierto',
    GameStyle.jungle => 'Selva',
    GameStyle.savanna => 'Sabana',
    GameStyle.forest => 'Bosque',
    GameStyle.prairie => 'Pradera',
    GameStyle.mountains => 'Montañas',
    GameStyle.tundra => 'Tundra',
  };

  String get emoji => switch (this) {
    GameStyle.classic => '🐯',
    GameStyle.desert => '🐪',
    GameStyle.jungle => '🐒',
    GameStyle.savanna => '🦁',
    GameStyle.forest => '🦊',
    GameStyle.prairie => '🦬',
    GameStyle.mountains => '🏔️',
    GameStyle.tundra => '🐻‍❄️',
  };

  String get description => switch (this) {
    GameStyle.classic => 'Animales variados y divertidos',
    GameStyle.desert => 'Día y noche en el árido desierto',
    GameStyle.jungle => 'Vida salvaje en la espesa selva',
    GameStyle.savanna => 'Animales majestuosos de la sabana',
    GameStyle.forest => 'Naturaleza y fauna del bosque',
    GameStyle.prairie => 'Fauna de las grandes praderas',
    GameStyle.mountains => 'Animales de las altas montañas',
    GameStyle.tundra => 'Fauna de las regiones heladas',
  };
}
