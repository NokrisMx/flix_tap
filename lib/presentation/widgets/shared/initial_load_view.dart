import 'package:dio/dio.dart';
import 'package:flix_tap/presentation/widgets/shared/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitialLoadView extends StatelessWidget {
  final AsyncValue<void> state;
  final WidgetBuilder builder;
  final String loadingTitle;
  final String loadingSubtitle;
  final String errorTitle;
  final VoidCallback onRetry;

  const InitialLoadView({
    super.key,
    required this.state,
    required this.builder,
    required this.loadingTitle,
    required this.loadingSubtitle,
    required this.errorTitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => FullScreenLoader(
        title: loadingTitle,
        subtitle: loadingSubtitle,
      ),
      error: (error, stackTrace) {
        final hasNoConnection = _isConnectionError(error);

        return FullScreenLoader(
          isLoading: false,
          icon: hasNoConnection
              ? Icons.cloud_off_outlined
              : Icons.error_outline_rounded,
          title: errorTitle,
          subtitle: hasNoConnection
              ? 'No hay conexión a internet. Revisa tu conexión e inténtalo de nuevo.'
              : 'Ocurrió un problema al cargar la información. Inténtalo de nuevo.',
          action: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        );
      },
      data: (_) => builder(context),
    );
  }

  bool _isConnectionError(Object error) {
    if (error is! DioException) return false;

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };
  }
}
