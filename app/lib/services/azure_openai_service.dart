import 'dart:convert';

import 'package:http/http.dart' as http;

import 'catalog_service.dart';

class AzureOpenAIConfig {
  static const endpoint = String.fromEnvironment('AZURE_OPENAI_ENDPOINT');
  static const apiKey = String.fromEnvironment('AZURE_OPENAI_API_KEY');
  static const deployment = String.fromEnvironment('AZURE_OPENAI_DEPLOYMENT');
  static const apiVersion = String.fromEnvironment(
    'AZURE_OPENAI_API_VERSION',
    defaultValue: '2024-02-15-preview',
  );

  static bool get isConfigured =>
      endpoint.trim().isNotEmpty && apiKey.trim().isNotEmpty && deployment.trim().isNotEmpty;
}

class AzureOpenAIService {
  final CatalogData data;

  const AzureOpenAIService({required this.data});

  Uri _buildUri() {
    final base = AzureOpenAIConfig.endpoint.trim();
    final normalized = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final path =
        '$normalized/openai/deployments/${AzureOpenAIConfig.deployment}/chat/completions?api-version=${AzureOpenAIConfig.apiVersion}';
    return Uri.parse(path);
  }

  String _catalogContext() {
    final zones = data.zones.map((z) => z.nombre).join(', ');
    final exercises = data.exercises.take(60).map((e) {
      final zoneName = data.zones
          .firstWhere(
            (z) => z.id == e.zonaId,
            orElse: () => data.zones.isEmpty ? throw StateError('No zones') : data.zones.first,
          )
          .nombre;
      return '- ${e.nombre} | zona: $zoneName | ${e.series}x${e.repeticiones}';
    }).join('\n');

    return 'Zonas disponibles: $zones\n\nEjercicios (muestra):\n$exercises';
  }

  Future<String> reply({
    required String userText,
    List<Map<String, String>> history = const [],
  }) async {
    if (!AzureOpenAIConfig.isConfigured) {
      throw StateError('Azure OpenAI no configurado.');
    }

    final uri = _buildUri();
    final system = [
      'Eres un asistente de fisioterapia amigable y educativo para una app de ejercicios.',
      '',
      'Tu rol principal:',
      '- Responder CUALQUIER pregunta sobre fisioterapia, lesiones, ejercicios, prevención, anatomía.',
      '- Ofrecer consejos prácticos basados en evidencia.',
      '- Cuando sea relevante, recomendar ejercicios específicos del catálogo de la app.',
      '- Generar rutinas personalizadas cuando el usuario las solicite.',
      '',
      'Preguntas comunes que deberías responder bien:',
      '- Sobre molestias/lesiones comunes: esguinces, tendinitis, dolor de espalda, etc.',
      '- Prevención de lesiones durante deportes o actividades.',
      '- Diferencia entre distintos ejercicios o técnicas.',
      '- Recuperación post-lesión o post-cirugía (general, no diagnóstico).',
      '- Mejora de flexibilidad, fuerza, resistencia.',
      '',
      'Guardrails de seguridad:',
      '- Da información educativa general; NO diagnostiques específicamente.',
      '- Si el usuario describe SEÑALES DE ALARMA (dolor intenso, hormigueo persistente, pérdida de fuerza, inflamación importante, fiebre), menciona consultar un profesional UNA SOLA VEZ.',
      '- No repeatas avisos de alarma en respuestas posteriores.',
      '',
      'Cuando uses el catálogo:',
      '- Para ejercicios o rutinas, usa SOLO los ejercicios disponibles en la app.',
      '- Si no tenemos lo que pide, explica qué tenemos y pregunta qué zona le interesa.',
      '',
      'Estilo de respuesta:',
      '- Sé claro, breve y educativo.',
      '- Usa lenguaje accesible (evita jerga médica innecesaria).',
      '- SIEMPRE responde en español.',
      '- Muestra entusiasmo por ayudar a mejorar la salud y el bienestar.',
      '- Cuando recomiendes algo del catálogo, destaca cómo puede ayudar.',
      '',
      'Catálogo disponible en la app:',
      _catalogContext(),
    ].join('\n');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': system},
      ...history.where(
        (m) =>
            (m['role'] == 'user' || m['role'] == 'assistant') &&
            (m['content'] ?? '').trim().isNotEmpty,
      ),
      {'role': 'user', 'content': userText},
    ];

    final body = {
      'messages': messages,
      'temperature': 0.2,
      'max_tokens': 350,
    };

    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'api-key': AzureOpenAIConfig.apiKey,
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw StateError('Azure OpenAI error ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = (decoded['choices'] as List?) ?? const [];
    if (choices.isEmpty) {
      throw StateError('Respuesta vacía de Azure OpenAI.');
    }

    final msg = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    final content = msg?['content'] as String?;
    final text = content?.trim();
    if (text == null || text.isEmpty) {
      throw StateError('Respuesta vacía de Azure OpenAI.');
    }

    return text;
  }
}
