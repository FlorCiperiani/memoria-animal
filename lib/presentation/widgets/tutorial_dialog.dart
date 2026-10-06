import 'package:flutter/material.dart';

Future<void> showTutorialDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const _TutorialDialog(),
);

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  static const _steps = <(IconData, String, String)>[
    (
      Icons.pets_rounded,
      '¡Bienvenido a Memoria Animal!',
      'El objetivo es encontrar todas las parejas de animales antes de que se '
          'termine el tiempo.',
    ),
    (
      Icons.palette_rounded,
      'Elegí cómo jugar',
      'Seleccioná una temática y una dificultad. La dificultad define cuánto '
          'tiempo ves las cartas al comienzo de la partida.',
    ),
    (
      Icons.flag_rounded,
      'Elegí un nivel',
      'Cada nivel suma pares de cartas. Cuando estés listo, tocá el botón '
          '“¡Jugar!” para empezar.',
    ),
    (
      Icons.touch_app_rounded,
      'Encontrá las parejas',
      'Memorizá dónde está cada animal y tocá dos cartas iguales. Si no forman '
          'un par, se darán vuelta para que puedas intentarlo de nuevo.',
    ),
    (
      Icons.lightbulb_rounded,
      'Usá las ayudas',
      'Durante la partida podés pausar, reiniciar o empezar otra. Las ayudas '
          'de la parte inferior revelan una carta, encuentran un par o agregan '
          'tiempo a cambio de diamantes.',
    ),
  ];

  var _step = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, title, description) = _steps[_step];

    return PopScope(
      canPop: false,
      child: Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth.clamp(0, 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 44, color: colors.primary),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_step + 1} de ${_steps.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Omitir tutorial'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            if (_step == _steps.length - 1) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _step++);
                            }
                          },
                          icon: Icon(
                            _step == _steps.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            _step == _steps.length - 1
                                ? 'Terminar'
                                : 'Siguiente',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
