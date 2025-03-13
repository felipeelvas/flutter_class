import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:facilite_app/models/pendencias.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facilite_app/models/auth.dart';
import 'package:facilite_app/providers/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

/// Set up a fake secure storage by intercepting the method channel calls.
void setupFakeSecureStorage() {
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  // Use a simple map to store key/value pairs.
  final Map<String, String?> storageValues = <String, String?>{};

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'read':
        final key = methodCall.arguments['key'];
        return storageValues[key];
      case 'write':
        final key = methodCall.arguments['key'];
        final value = methodCall.arguments['value'];
        storageValues[key] = value;
        return null;
      case 'delete':
        final key = methodCall.arguments['key'];
        storageValues.remove(key);
        return null;
      default:
        return null;
    }
  });
}

/// --- FakeHttpOverrides and Supporting Classes ---
class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

class FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest(url);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientRequest implements HttpClientRequest {
  final Uri url;
  FakeHttpClientRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    print("URL chamada: ${url.toString()}");
    if (url.toString().contains("authenticate")) {
      final jsonResponse = jsonEncode({"id_token": "fake-token"});
      final stream = Stream<List<int>>.fromIterable([utf8.encode(jsonResponse)]);
      return FakeHttpClientResponse(200, stream);
    }
    // Otherwise, simulate a 404 Not Found.
    final stream = Stream<List<int>>.fromIterable([utf8.encode('Not Found')]);
    return FakeHttpClientResponse(404, stream);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final int statusCode;
  final Stream<List<int>> _stream;
  FakeHttpClientResponse(this.statusCode, this._stream);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FailingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FailingHttpClient();
  }
}

class FailingHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FailingHttpClientRequest(url);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FailingHttpClientRequest implements HttpClientRequest {
  final Uri url;
  FailingHttpClientRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    if (url.toString().contains("authenticate")) {
      final jsonResponse = jsonEncode({"error": "Unauthorized"});
      final stream = Stream<List<int>>.fromIterable([utf8.encode(jsonResponse)]);
      return FailingHttpClientResponse(401, stream);
    }
    final stream = Stream<List<int>>.fromIterable([utf8.encode('Not Found')]);
    return FailingHttpClientResponse(404, stream);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FailingHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final int statusCode;
  final Stream<List<int>> _stream;
  FailingHttpClientResponse(this.statusCode, this._stream);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Fake que simula um armazenamento simples usando um Map interno.
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _fakeStorage = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions, // parâmetro adicionado
  }) async {
    return _fakeStorage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions, // parâmetro adicionado
  }) async {
    if (value == null) {
      _fakeStorage.remove(key);
    } else {
      _fakeStorage[key] = value;
    }
  }
}

/// Fake que simula uma exceção na leitura e escrita do storage.
class ThrowingSecureStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions, // parâmetro adicionado
  }) async {
    throw Exception("Simulated exception");
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions, // parâmetro adicionado
  }) async {
    throw Exception("Simulated exception on write");
  }
}

/// Subclasse do AuthProvider que sobrescreve o getter `storage` para usar
/// um FlutterSecureStorage fake.
class FakeAuthProviderForCredentials extends AuthProvider {
  final FlutterSecureStorage _fakeStorage;

  FakeAuthProviderForCredentials(this._fakeStorage);

  @override
  FlutterSecureStorage get storage => _fakeStorage;
}

/// Subclasse para testes que sobrescreve os getters 'acessos' e 'token'
/// utilizando os campos públicos 'testAcessos' e 'testToken'.
class TestableAuthProvider extends AuthProvider {
  List<Acesso>? testAcessos;
  String? testToken;

  @override
  List<Acesso> get acessos => testAcessos ?? [];

  @override
  String? get token => testToken;
}

/// Função auxiliar para criar instâncias de Acesso.
Acesso createAcesso({
  required int estadoId,
  required int id,
  String razaoSocial = 'Empresa Teste',
  int regimeTributarioId = 0,
  bool empresaEmProcessoAbertura = false,
  String? situacao,
}) {
  return Acesso(
    estadoId: estadoId,
    id: id,
    razaoSocial: razaoSocial,
    regimeTributarioId: regimeTributarioId,
    empresaEmProcessoAbertura: empresaEmProcessoAbertura,
    situacao: situacao,
  );
}

class FakeAcesso extends Acesso {
  final bool fakeIsBrasilOrEmpty;

  FakeAcesso({
    required int estadoId,
    required int id,
    String razaoSocial = 'Empresa Teste',
    int regimeTributarioId = 0,
    bool empresaEmProcessoAbertura = false,
    String? situacao,
    required this.fakeIsBrasilOrEmpty,
  }) : super(
    estadoId: estadoId,
    id: id,
    razaoSocial: razaoSocial,
    regimeTributarioId: regimeTributarioId,
    empresaEmProcessoAbertura: empresaEmProcessoAbertura,
    situacao: situacao,
  );

  @override
  bool get isBrasilOrEmpty => fakeIsBrasilOrEmpty;
}

class FakeAuthProvider extends AuthProvider {
  bool fakeLoginTourValue = false;
  String? fakeTokenValue;

  @override
  bool get isAuth => fakeLoginTourValue || fakeTokenValue != null;

  set fakeLoginTour(bool value) {
    fakeLoginTourValue = value;
  }

  set fakeToken(String? value) {
    fakeTokenValue = value;
  }
}

/// FakeLoadAcessosHttpOverrides intercepta as chamadas HTTP para carregar os acessos.
class FakeLoadAcessosHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeLoadAcessosHttpClient();
  }
}

class FakeLoadAcessosHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeLoadAcessosHttpClientRequest(url);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeLoadAcessosHttpClientRequest implements HttpClientRequest {
  final Uri url;
  FakeLoadAcessosHttpClientRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    // Verifica se a URL contém "acessos" (o endpoint usado em account.loadAcessos).
    if (url.toString().contains("acessos")) {
      // Simula uma resposta com sucesso contendo um JSON array com um objeto Acesso.
      final jsonResponse = jsonEncode([
        {
          "id": 1,
          "estadoId": 1,
          "razaoSocial": "Empresa Teste",
          // Outros campos podem ser incluídos, conforme necessário.
        }
      ]);
      final stream =
      Stream<List<int>>.fromIterable([utf8.encode(jsonResponse)]);
      return FakeHttpClientResponse(200, stream);
    }
    final stream = Stream<List<int>>.fromIterable([utf8.encode('Not Found')]);
    return FakeHttpClientResponse(404, stream);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeAuthenticatePost extends Mock implements InterceptedClient {

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Map<String, dynamic>? params, Object? body, Encoding? encoding}) {
    const retornoEsperado = '{"id_token":"fake-token"}';
    final uri = Uri.parse('http://localhost:8083/api/authenticate');
    final fakeResponse = http.Response(
      retornoEsperado,
      200,
      request: http.Request('POST', uri),
    );
    return  Future(() async => fakeResponse);
  }
}

class MockHttpClientInterceptor extends Mock implements InterceptedClient {

  Future<http.Response> get(Uri url, {Map<String, String>? headers, Map<String, dynamic>? params, Object? body, Encoding? encoding}) {
    var retornoEsperado = (jsonEncode(

        {
          "documentosNaoLidos": 0,
          "certificadoValido": true,
          "taxasImpostosPendentes": 0,
          "temRecalculoTaxasImpostos": true,
          "cobrancasPendentes": 0,
          "preencheuOrigem": true,
          "precisaPreencherAvaliacaoMensal": true,
          "precisaAparecerAvisoEmissaoNotaFiscal": true,
          "precisaAparecerAvisoClassificacaoExtrato": true,
          "contratoFaciliteAssinado": true,
          "temExtratosParaClassificar": true
        }
    ));
    return Future.value(http.Response(
      retornoEsperado,
      200,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    ));
  }
}

class MockAcesso extends Mock implements Acesso {
  @override
  Pendencias? get pendencias => super.noSuchMethod(
    Invocation.getter(#pendencias),
    returnValue: Pendencias(
      documentosNaoLidos: 0,
      certificadoValido: true,
      taxasImpostosPendentes: 0,
      temRecalculoTaxasImpostos: true,
      cobrancasPendentes: 0,
      preencheuOrigem: true,
      precisaPreencherAvaliacaoMensal: true,
      precisaAparecerAvisoEmissaoNotaFiscal: true,
      precisaAparecerAvisoClassificacaoExtrato: true,
      contratoFaciliteAssinado: true,
      temExtratosParaClassificar: true,
    ),
  );

  @override
  bool get isEmpresaOuProcesso => super.noSuchMethod(
    Invocation.getter(#isEmpresaOuProcesso),
    returnValue: false,
    returnValueForMissingStub: false,
  );

  @override
  void informouPagamentoCobranca() => super.noSuchMethod(
    Invocation.method(#informouPagamentoCobranca, []),
    returnValue: null,
  );
}
class MockStorageService extends Mock {
  Future<String?> read({required String key}) async {
    return super.noSuchMethod(
      Invocation.method(#read, [key]),
      returnValue: Future.value(null),
    );
  }
}

class MockAuthProvider extends Mock implements AuthProvider {
  @override
  Future<void> atualizarPendencias(Acesso acesso) async {
    return super.noSuchMethod(
      Invocation.method(#atualizarPendencias, [acesso]),
      returnValue: Future.value(),
    );
  }
}

