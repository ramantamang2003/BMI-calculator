import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../models/gender.dart';
import '../services/bmi_history_service.dart';
import '../utils/app_routes.dart';
import '../utils/bmi_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const double _minHeight = 120;
  static const double _maxHeight = 220;

  final BmiHistoryService _historyService = BmiHistoryService();

  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Gender? _selectedGender;
  int _age = 24;
  int _weight = 68;
  double _height = 172;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onCalculatePressed() async {
    final String? validationError = BmiUtils.validateInputs(
      gender: _selectedGender,
      age: _age,
      weightKg: _weight,
      heightCm: _height,
    );

    if (validationError != null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    final BmiResult result = BmiUtils.calculate(
      weightKg: _weight,
      heightCm: _height,
    );

    final BmiRecord record = BmiRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gender: _selectedGender!.name,
      age: _age,
      heightCm: _height,
      weightKg: _weight,
      bmi: result.value,
      category: result.category,
      message: result.message,
      createdAtIso: DateTime.now().toIso8601String(),
    );

    await _historyService.saveRecord(record);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      buildSmoothRoute(
        ResultScreen(
          result: result,
          onRecalculate: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(buildSmoothRoute(HistoryScreen(historyService: _historyService)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF121722), Color(0xFF0B101A)]
                : const [Color(0xFFF3F6FB), Color(0xFFE7EEF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'View history',
                          onPressed: _openHistory,
                          icon: const Icon(Icons.history_rounded),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: isDarkMode
                              ? 'Switch to light mode'
                              : 'Switch to dark mode',
                          onPressed: widget.onToggleTheme,
                          icon: Icon(
                            isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BMI Calculator',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'BMI = weight (kg) / height (m)^2',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderCard(
                            label: 'Male',
                            icon: Icons.male_rounded,
                            selected: _selectedGender == Gender.male,
                            onTap: () =>
                                setState(() => _selectedGender = Gender.male),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _GenderCard(
                            label: 'Female',
                            icon: Icons.female_rounded,
                            selected: _selectedGender == Gender.female,
                            onTap: () =>
                                setState(() => _selectedGender = Gender.female),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionTitle(title: 'Age'),
                          const SizedBox(height: 10),
                          _NumberStepper(
                            value: '$_age',
                            suffix: 'years',
                            onAdd: () => setState(() {
                              if (_age < 120) {
                                _age++;
                              }
                            }),
                            onRemove: () => setState(() {
                              if (_age > 1) {
                                _age--;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionTitle(title: 'Height'),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Text(
                              '${_height.round()} cm',
                              key: ValueKey<int>(_height.round()),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Slider(
                            min: _minHeight,
                            max: _maxHeight,
                            divisions: (_maxHeight - _minHeight).toInt(),
                            value: _height,
                            onChanged: (value) =>
                                setState(() => _height = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionTitle(title: 'Weight'),
                          const SizedBox(height: 10),
                          _NumberStepper(
                            value: '$_weight',
                            suffix: 'kg',
                            onAdd: () => setState(() {
                              if (_weight < 300) {
                                _weight++;
                              }
                            }),
                            onRemove: () => setState(() {
                              if (_weight > 1) {
                                _weight--;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Calculate BMI',
                      icon: Icons.calculate_rounded,
                      onPressed: _onCalculatePressed,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.tune_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFF1F3C88), Color(0xFF2A7DAF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: isDark
                    ? const [Color(0xFF1A2332), Color(0xFF141D2A)]
                    : const [Colors.white, Color(0xFFF4F7FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: selected
              ? const Color(0xFF2A7DAF)
              : (isDark ? const Color(0x1FFFFFFF) : const Color(0x19000000)),
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? const Color(0x331F3C88)
                : (isDark ? const Color(0x10000000) : const Color(0x12000000)),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(icon, size: 36, color: selected ? Colors.white : null),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.value,
    required this.suffix,
    required this.onAdd,
    required this.onRemove,
  });

  final String value;
  final String suffix;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StepperButton(icon: Icons.remove_rounded, onPressed: onRemove),
        Column(
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              suffix,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        _StepperButton(icon: Icons.add_rounded, onPressed: onAdd),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 26,
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B2433)
              : const Color(0xFFE8EEF8),
        ),
        child: Icon(icon),
      ),
    );
  }
}
