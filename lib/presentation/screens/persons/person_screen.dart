import 'package:animate_do/animate_do.dart';
import 'package:flix_tap/config/helpers/human_formats.dart';
import 'package:flix_tap/domain/entities/person.dart';
import 'package:flix_tap/presentation/providers/persons/persons_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonScreen extends ConsumerStatefulWidget {
  static const name = 'person-screen';

  final String personId;

  const PersonScreen({super.key, required this.personId});

  @override
  PersonScreenState createState() => PersonScreenState();
}

class PersonScreenState extends ConsumerState<PersonScreen> {
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  @override
  void didUpdateWidget(covariant PersonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.personId != widget.personId) {
      _loadError = null;
      _loadPerson();
    }
  }

  Future<void> _loadPerson({bool isRetry = false}) async {
    if (isRetry) {
      setState(() => _loadError = null);
    }

    final personId = widget.personId;
    try {
      await ref.read(personInfoProvider.notifier).loadPerson(personId);
    } catch (error) {
      if (!mounted || personId != widget.personId) return;
      setState(() => _loadError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(personInfoProvider)[widget.personId];

    if (person == null) {
      return Scaffold(
        body: Center(
          child: _loadError == null
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudo cargar la información.'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _loadPerson(isRetry: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _PersonSliverAppBar(person: person),
          SliverToBoxAdapter(child: _PersonDetails(person: person)),
        ],
      ),
    );
  }
}

class _PersonSliverAppBar extends StatelessWidget {
  final Person person;

  const _PersonSliverAppBar({required this.person});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      expandedHeight: size.height * 0.62,
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
                    colors: [Colors.black87, Colors.transparent],
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
                  colors: [Colors.transparent, Colors.black87],
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
    return const ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Icon(Icons.person_outline, size: 96, color: Colors.white54),
      ),
    );
  }
}

class _PersonDetails extends StatelessWidget {
  final Person person;

  const _PersonDetails({required this.person});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final birthday = _formatDate(person.birthday);
    final deathday = _formatDate(person.deathday);
    final homepage = person.homepage;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (person.knownForDepartment.isNotEmpty)
            Text(person.knownForDepartment, style: textStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (birthday != null)
                _PersonInfoChip(
                  icon: Icons.cake_outlined,
                  label: deathday == null
                      ? 'Nacimiento: $birthday'
                      : '$birthday – $deathday',
                ),
              if (person.placeOfBirth.isNotEmpty)
                _PersonInfoChip(
                  icon: Icons.place_outlined,
                  label: person.placeOfBirth,
                ),
              _PersonInfoChip(
                icon: Icons.star_outline,
                label: 'Popularidad ${HumanFormats.number(person.popularity)}',
              ),
              if (person.gender > 0)
                _PersonInfoChip(
                  icon: Icons.person_outline,
                  label: _genderLabel(person.gender),
                ),
            ],
          ),
          if (person.biography.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Biografía', style: textStyles.titleLarge),
            const SizedBox(height: 8),
            Text(person.biography, style: textStyles.bodyMedium),
          ],
          if (person.alsoKnownAs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('También conocido como', style: textStyles.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: person.alsoKnownAs
                  .where((name) => name.trim().isNotEmpty)
                  .map((name) => Chip(label: Text(name)))
                  .toList(),
            ),
          ],
          if (homepage is String && homepage.isNotEmpty)
            _PersonHomepage(url: homepage),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String? _formatDate(dynamic value) {
    if (value is DateTime) return HumanFormats.date(value);
    return null;
  }

  String _genderLabel(int gender) {
    switch (gender) {
      case 1:
        return 'Mujer';
      case 2:
        return 'Hombre';
      case 3:
        return 'No binario';
      default:
        return 'No especificado';
    }
  }
}

class _PersonInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PersonInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _PersonHomepage extends StatelessWidget {
  final String url;

  const _PersonHomepage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _openHomepage(context),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Sitio web'),
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
