# Documentação de Melhorias do Projeto

## 1. Descrição dos problemas identificados no sistema original

Após a análise do sistema, foram identificados os seguintes problemas intencionais:
1. **Falta de organização arquitetural:** O arquivo `main.dart` concentrava a inicialização do app, a UI, as regras de negócio, a modelagem (`Product`) e as requisições API diretamente nos Widgets. Isso gerenciava muita responsabilidade no mesmo local (Strong Coupling) e prejudicava manutenção e testes.
2. **Latência Injustificada:** Havia um atraso artificial de 2 segundos imposto a cada requisição (`Future.delayed`), prejudicando severamente a experiência do usuário.
3. **Experiência de Loading Bloqueante:** A interface inteira era bloqueada por um `CircularProgressIndicator` durante o carregamento de dados, impedindo que o uso parecesse fluido, mesmo em momentos em que já poderia haver dados antigos na tela (como em pulls text para refresh).
4. **Falta de Gerenciamento de Estado / Recarregamento excessivo:** Sempre que o usuário voltava da tela de detalhes (`ProductDetailPage`) para a tela de listagem, o método `loadProducts` era chamado explicitamente, causando um recarregamento total sem necessidade (desperdício de rede e de processamento do dispositivo).
5. **Má Gestão e Ausência de Cache de Imagens:** As imagens usavam `Image.network` sem uma estratégia confiável de cache em disco ou de otimização entre sessões. Embora o Flutter retenha em RAM o que exibe em _NetworkImage_, recarregar e voltar recarrega a dependência repetidas vezes. Além disso, havia uma falta de _placeholders_ agradáveis enquanto as imagens eram carregadas, deixando a tela exposta apenas à versão final de forma síncrona visualmente.

## 2. Explicação das mudanças realizadas

Para evoluir a aplicação, foram implementadas as seguintes soluções:
* **Refatoração para Clean Architecture:** Separação do código fonte em quatro camadas principais dentro da pasta `lib/`:
    * `core/`: Utilitários compartilhados como classes de exceção customizadas (`AppException`).
    * `domain/`: Camada de domínio puro contendo as entidades (`Product`, `User`) e as interfaces abstratas dos repositórios (`AuthRepository`, `ProductRepository`). Esta camada não possui dependência de pacotes externos.
    * `data/`: Camada de dados contendo os datasources (chamadas HTTP), models (parse JSON que estendem as entidades), implementações concretas dos repositórios e o serviço de sessão (`AuthSession`).
    * `presentation/`: Camada de apresentação contendo as páginas da interface (`LoginPage`, `ProductListPage`, `ProductDetailPage`) e os ViewModels com estados imutáveis (`AuthViewModel`, `ProductViewModel`).
* **Padrão MVVM com States Imutáveis:** Criação de classes de estado imutáveis (`AuthState`, `ProductState`) com método `copyWith()`, permitindo atualizações previsíveis e rastreáveis do estado da aplicação.
* **Injeção de Dependências:** O `http.Client` é injetado nos datasources via construtor, permitindo substituição por mocks em testes unitários. As dependências são criadas no `main.dart` e propagadas via `MultiProvider`.
* **Separação Entity vs Model:** As entidades do domínio (`Product`, `User`) são classes puras sem lógica de serialização. Os models (`ProductModel`, `UserModel`) estendem as entidades e adicionam `fromJson`/`toJson`.
* **Interfaces Abstratas de Repository:** Os repositórios são definidos como classes abstratas no `domain/`, com implementações concretas no `data/`. Isso permite substituir a fonte de dados sem alterar a lógica de negócio.
* **Implementação de Gerência de Estado com Provider:** Adição do pacote `provider` para injetar os ViewModels na árvore de Widget via `MultiProvider`.
* **Remoção de Latência Artificial:** O `.delayed` de 2 segundos foi retirado para focar na latência real da API.
* **Componente de Atualização Fluída:** Introdução de `RefreshIndicator` com atualização na chamada do `loadProducts`, que evita que a lista pisque e dê block num loop caso ela já tenha dados velhos para ler na interface.
* **Implementação de Cache de Imagens robusto:** Uso da dependência `cached_network_image`.

## 3. Justificativa técnica relacionando cada mudança aos problemas

* **Clean Architecture (Domain/Data/Presentation):** A separação em camadas isola "como os dados são buscados" (data) de "quais são as regras do domínio" (domain) e de "como os dados são exibidos" (presentation). Essa separação (SoC - Separation of Concerns) torna o App testável via Mock (graças às interfaces e injeção de `http.Client`), reutilizável (vários widgets podem compartilhar o acesso ao produto sem repetição de Request http) e modular.
* **States Imutáveis com copyWith:** O uso de classes de estado imutáveis (`ProductState`, `AuthState`) garante que as transições de estado sejam previsíveis e rastreáveis. Cada atualização cria uma nova instância do estado, evitando mutações acidentais e facilitando debugging.
* **Atualização via Provider sem Recarregamento Forçado no `pop`:** Uma vez que os dados foram buscados, eles ficam armazenados na memória pelo `ProductViewModel`. Ao realizar o Pop da tela "Detalhes", nada aciona o banco. Isso corrige a dupla requisição ao voltar, economiza rede, corta totalmente a sensação de lentidão e melhora drasticamente a responsividade, usando Cache em Memória.
* **Cache de Imagens com `cached_network_image`:** Diferente do `Image.network`, este pacote guarda fisicamente as imagens baixadas no armazenamento (cache persistente do dispositivo). Com isso, mesmo quando o aplicativo é encerrado e aberto novamente o carregamento das texturas é imediato economizando banda. A inclusão de `placeholder` proporciona também feedback visual com `CircularProgressIndicator` pontuais para cada imagem em vez de bloquear a visualização (aumenta o UX index e resposividade sob lentidão de rede).
* **Remoção das interrupções obstrutivas globais no recarregamento:** Com o uso conjunto do `context.watch` do Provider, o app apenas exibe loading central quando a lista está vazia, proporcionando visões instantâneas ao cache sem flash-refresh destrutivos na tela (o RefreshIndicator apenas rola o progress e traz novos dados por baixo do pano de modo assíncrono).

## 4. Justificativa para a escolha do Provider como gerenciador de estado

O **Provider** foi escolhido como solução de gerenciamento de estado por ser a recomendação oficial do Flutter para projetos de pequeno e médio porte. Entre as razões técnicas para essa escolha:

* **Simplicidade e baixa curva de aprendizado:** O Provider utiliza o padrão `ChangeNotifier` nativo do Flutter, não exigindo aprendizado de conceitos adicionais como Streams (BLoC) ou geradores de código (Riverpod com code generation).
* **Integração nativa com o ciclo de vida dos Widgets:** O `ChangeNotifierProvider` se integra diretamente à árvore de widgets do Flutter, liberando recursos automaticamente quando o widget é descartado (`dispose`).
* **Baixo boilerplate:** Comparado ao BLoC, que exige a criação de Events, States e Blocs separados para cada funcionalidade, o Provider permite gerenciar estado com classes simples que estendem `ChangeNotifier`, reduzindo significativamente a quantidade de código necessário.
* **Reatividade granular com Consumer e context.watch:** O uso de `Consumer<T>` e `context.watch<T>()` permite reconstruir apenas os widgets que dependem de um estado específico, evitando rebuilds desnecessários da árvore inteira.
* **Adequação ao escopo do projeto:** Para um catálogo de produtos com autenticação, favoritos e listagem, o Provider oferece a complexidade ideal — suficiente para separar responsabilidades sem adicionar overhead arquitetural desnecessário que seria mais apropriado para aplicações de grande escala.

O `setState` puro foi descartado por não escalar bem entre múltiplas telas que compartilham estado (ex: favoritos precisam refletir entre lista e detalhes). O Riverpod e o BLoC, embora mais robustos, introduziriam complexidade desproporcional ao tamanho deste projeto.

## 5. Sistema de Favoritos

Foi implementado um sistema completo de controle de favoritos, permitindo ao usuário:

* **Marcar produtos como favoritos** tocando no ícone de coração (❤️) presente em cada item da lista e na tela de detalhes.
* **Remover produtos dos favoritos** tocando novamente no ícone, que alterna entre preenchido (favoritado) e vazio (não favoritado).
* **Filtrar apenas favoritos** usando o botão de coração no AppBar da tela principal, que alterna entre exibir todos os produtos ou apenas os favoritados.
* **Atualização automática da interface:** Ao marcar/desmarcar um favorito, a UI é atualizada automaticamente em todas as telas via `notifyListeners()` do `ProductViewModel`, sem necessidade de recarregar a página.
* **Persistência local:** Os favoritos são salvos em `SharedPreferences`, garantindo que a lista de favoritos seja mantida entre sessões do aplicativo.

A implementação dos favoritos está integrada ao `ProductViewModel`, que gerencia tanto a listagem de produtos quanto o estado de favoritos em um único ViewModel. A entidade `Product` possui o campo `isFavorite` que é preenchido dinamicamente com base nos IDs salvos em `SharedPreferences`, seguindo o padrão de estado imutável via `copyWith()`.