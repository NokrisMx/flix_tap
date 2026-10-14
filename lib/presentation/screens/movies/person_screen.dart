import 'package:animate_do/animate_do.dart';
import 'package:flix_tap/config/helpers/human_formats.dart';
import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/presentation/providers/movies/initial_loading_provider.dart';
import 'package:flix_tap/presentation/providers/persons/persons_provider.dart';
import 'package:flix_tap/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonScreen extends ConsumerWidget {
  static const name = 'person-screen';

  final String personId;

  const PersonScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = InitialLoadRequest.person(personId);
    final loadState = ref.watch(initialLoadingProvider(request));

    return InitialLoadView(
      state: loadState,
      loadingTitle: 'Cargando persona',
      loadingSubtitle: 'Preparando su información.',
      errorTitle: 'No se pudo cargar la información',
      onRetry: () => ref.read(initialLoadingProvider(request).notifier).retry(),
      builder: (context) {
        final Person person = ref.watch(personInfoProvider)[personId]!;

        return Scaffold(
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              _PersonSliverAppBar(person: person),
              SliverToBoxAdapter(child: _PersonDetails(person: person)),
            ],
          ),
        );
      },
    );
  }
}

class _PersonSliverAppBar extends StatelessWidget {
  final Person person;

  const _PersonSliverAppBar({required this.person});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: backgroundColor,
      foregroundColor: colors.onSurface,
      expandedHeight: size.height * 0.55,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          person.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (person.profilePath.isNotEmpty)
              Image.network(
                person.profilePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return FadeIn(child: child);
                },
                errorBuilder: (context, error, stackTrace) =>
                    _PersonImagePlaceholder(),
              )
            else
              _PersonImagePlaceholder(),
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    stops: [0.0, 0.3],
                    colors: [backgroundColor, Colors.transparent],
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                  colors: [Colors.transparent, backgroundColor],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonImagePlaceholder extends StatelessWidget {
  const _PersonImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: 96,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PersonDetails extends StatelessWidget {
  final Person person;

  const _PersonDetails({required this.person});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final birthday = _formatDate(person.birthday);
    final deathday = _formatDate(person.deathday);
    final homepage = person.homepage;
    final gender = _genderLabel(person.gender);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(person.name, style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PersonMetricCard(
                  icon: Icons.trending_up_rounded,
                  label: 'POPULARIDAD',
                  value: HumanFormats.number(person.popularity, 1),
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PersonMetricCard(
                  icon: Icons.work_outline_rounded,
                  label: 'ÁREA',
                  value: person.knownForDepartment.isNotEmpty
                      ? person.knownForDepartment
                      : 'Sin especificar',
                  color: colors.secondary,
                ),
              ),
            ],
          ),
          if (birthday != null || gender != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (birthday != null)
                  Expanded(
                    child: _PersonInfoCard(
                      icon: Icons.cake_outlined,
                      label: deathday == null ? 'NACIMIENTO' : 'VIDA',
                      value: birthday,
                      detail: deathday == null
                          ? null
                          : 'Fallecimiento: $deathday',
                    ),
                  ),
                if (birthday != null && gender != null)
                  const SizedBox(width: 12),
                if (gender != null)
                  Expanded(
                    child: _PersonInfoCard(
                      icon: Icons.person_outline_rounded,
                      label: 'GÉNERO',
                      value: gender,
                    ),
                  ),
              ],
            ),
          ],
          if (person.placeOfBirth.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PersonInfoCard(
              icon: Icons.place_outlined,
              label: 'LUGAR DE NACIMIENTO',
              value: person.placeOfBirth,
              fullWidth: true,
            ),
          ],
          if (person.biography.isNotEmpty) ...[
            const SizedBox(height: 24),
            _PersonSectionTitle(
              icon: Icons.menu_book_outlined,
              title: 'Biografía',
            ),
            const SizedBox(height: 10),
            Text(
              person.biography,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (person.alsoKnownAs.isNotEmpty) ...[
            const SizedBox(height: 24),
            _PersonSectionTitle(
              icon: Icons.badge_outlined,
              title: 'También conocido como',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: person.alsoKnownAs
                  .where((name) => name.trim().isNotEmpty)
                  .map(
                    (name) => Chip(
                      avatar: Icon(
                        Icons.person_outline,
                        size: 16,
                        color: colors.primary,
                      ),
                      label: Text(name),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (homepage is String && homepage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _PersonHomepage(url: homepage),
            ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  String? _formatDate(Object? value) {
    if (value is DateTime) return HumanFormats.date(value);
    return null;
  }

  String? _genderLabel(int gender) {
    switch (gender) {
      case 1:
        return 'Mujer';
      case 2:
        return 'Hombre';
      case 3:
        return 'No binario';
      default:
        return null;
    }
  }
}

class _PersonMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PersonMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final bool fullWidth;

  const _PersonInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: fullWidth ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 3),
                    Text(detail!, style: textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PersonSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _PersonHomepage extends StatelessWidget {
  final String url;

  const _PersonHomepage({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _openHomepage(context),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Visitar sitio web'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _openHomepage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasAuthority ||
        !['http', 'https'].contains(uri.scheme.toLowerCase())) {
      messenger.showSnackBar(
        const SnackBar(content: Text('El enlace no es válido.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el sitio web.')),
        );
      }
    } on PlatformException {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el sitio web.')),
        );
      }
    }
  }
}
