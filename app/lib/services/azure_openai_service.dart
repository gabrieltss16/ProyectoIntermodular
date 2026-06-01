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
    final exercises = data.exercises.map((e) {
      final zoneName = data.zones
          .firstWhere(
            (z) => z.id == e.zonaId,
            orElse: () => data.zones.isEmpty ? throw StateError('No zones') : data.zones.first,
          )
          .nombre;
      final tagStr = e.tags.isNotEmpty ? ' [${e.tags.join(', ')}]' : '';
      return '- ${e.nombre} | zona: $zoneName | ${e.series}x${e.repeticiones}$tagStr';
    }).join('\n');

    return 'Zonas disponibles: $zones\n\nEjercicios del catálogo (nombre | zona | series×reps | [condiciones/tipo/nivel]):\n$exercises';
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
      'Eres FisioIA, el asistente de fisioterapia de esta app. Eres cercano, empático y motivador.',
      'Tu objetivo es acompañar al usuario en su recuperación o prevención mediante ejercicios terapéuticos personalizados.',
      '',
      '## Cómo respondes cuando el usuario menciona una molestia o pide ejercicios',
      'La app ya muestra automáticamente una tarjeta con la rutina debajo de tu mensaje. Por eso NUNCA debes listar los ejercicios en tu texto.',
      'Tu respuesta tiene exactamente esta estructura en 3 partes, sin usar listas ni numeración:',
      '',
      '1. EMPATÍA (1-2 frases): Reacciona de forma humana y natural al mensaje. Reconoce cómo se siente, valida su situación.',
      '   Ejemplo: "Vaya, ese tipo de molestia en el codo puede ser bastante incómoda, sobre todo si afecta al día a día."',
      '',
      '2. JUSTIFICACIÓN de la rutina (2-3 frases): Explica brevemente POR QUÉ la rutina es adecuada para su condición específica, sin nombrar ejercicios concretos.',
      '   Ejemplo: "Te he preparado una rutina pensada para tendinitis del codo, con trabajo excéntrico y estiramientos que ayudan a reducir la carga en el tendón."',
      '',
      '3. PREGUNTA de personalización (1 frase): Haz UNA sola pregunta para ajustar mejor la rutina en el siguiente mensaje.',
      '   Ejemplos: "¿El dolor aparece más al coger cosas o también en reposo?" / "¿Cuánto tiempo llevas con esta molestia?" / "¿Tienes banda elástica en casa?"',
      '',
      '## Cuándo NO mostrar rutina',
      '- Si la pregunta es puramente informativa (anatomía, conceptos, prevención general), responde brevemente sin mencionar rutina.',
      '- Si el usuario responde a tu pregunta de personalización, adapta la justificación y vuelve a preguntar algo más específico.',
      '',
      '## Selección interna de ejercicios (solo para contexto, no escribas esto en tu respuesta)',
      'El catálogo tiene etiquetas por condición. Úsalas mentalmente para justificar la rutina:',
      '- Dolor agudo/reciente → etiquetas "agudo", "inicial", isométricos y movilidad suave.',
      '- Dolor crónico → etiquetas "cronico", "moderado", fuerza y estabilización.',
      '- Tendinitis → excéntricos, etiquetas "tendinitis", "epicondilitis", "tendinitis_aquilea".',
      '- Hernia lumbar → McKenzie, etiquetas "hernia", "discal".',
      '- Artrosis → bajo impacto, etiquetas "artrosis", "movilidad".',
      '- Hombro congelado → movilidad suave, etiquetas "hombro_congelado".',
      '- Manguito rotador → rotaciones, etiqueta "manguito_rotador".',
      '- Túnel carpiano → deslizamientos de nervio, etiqueta "tunel_carpiano".',
      '- Esguince/inestabilidad → propiocepción, etiquetas "esguince", "propiocepcion".',
      '',
      '## Estilo',
      '- Responde siempre en español.',
      '- Tutea al usuario.',
      '- Tono cálido y cercano, como un fisioterapeuta de confianza.',
      '- Máximo 4-5 frases en total. Nada de listas.',
      '- Nunca repitas la misma advertencia de seguridad dos veces en la misma conversación.',
      '',
      '## Seguridad',
      '- Información educativa general, nunca diagnósticos concretos.',
      '- Ante señales de alarma graves (dolor repentino intenso, hormigueo, pérdida de fuerza, fiebre), recomienda acudir al médico UNA sola vez y con naturalidad.',
      '',
      '## Catálogo de la app',
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
      'temperature': 0.5,
      'max_tokens': 600,
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
