# mi_primer_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Publicidades

Las creatividades se guardan fuera de `lib/`, en `assets/advertisements/`,
separadas por marca y tamaño (`mobile` y `desktop`). Flutter las empaqueta
localmente para que se puedan mostrar sin conexión. El diálogo elige una marca
al azar y abre el sitio correspondiente en el navegador si se toca la imagen.

## Motor de juego

La partida usa Flame para renderizar e interpretar las interacciones del tablero
de cartas. Flutter conserva las pantallas, controles y diálogos de la aplicación,
y `GameCubit` sigue gestionando las reglas, el puntaje, el tiempo y el progreso.

## Audio

Los archivos de audio se guardan en `assets/audio/`. La implementación con
`audioplayers` está en la capa de datos y se accede desde el dominio mediante
`AudioRepository`. El ambiente cambia entre `sonido_dia.mp3` y
`sonido_noche.mp3` según el tema; `correcto.mp3` e `incorrecto.mp3` acompañan
los resultados de los pares y `sonido_ganador.mp3` acompaña el diálogo de
victoria hasta que se cierra o comienza otra partida. El ambiente se reproduce
en bucle a volumen bajo, se inicia al pulsar «¡Jugar!» y se pausa cuando la
aplicación va a segundo plano. La configuración permite activar o desactivar el
sonido ambiente (incluido el de victoria) y los efectos de pares por separado.
La activación PRO de demostración desbloquea las temáticas Pradera, Montañas y
Tundra, y elimina la publicidad. Las temáticas exclusivas muestran una invitación
a activar PRO cuando se seleccionan desde una cuenta básica.
