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
* **Refatoração da Arquitetura:** Separação do código fonte em quatro camadas principais de domínio dentro da pasta `lib/`:
    * `models/`: Armazena a estrutura de dados de `Product`.
    * `repositories/`: Centraliza as chamadas à Web API e parse manual (padrão Repository) em `ProductRepository`.
    * `controllers/`: Guarda a regra de apresentação e gestão de estado em `ProductController` (herdando de `ChangeNotifier`).
    * `screens/`: Fica com as páginas da interface (`ProductListPage`, `ProductDetailPage`).
* **Implementação de Gerência de Estado com Provider:** Adição do pacote `provider` para injetar o `ProductController` na árvore de Widget. Isso torna o estado da lista de produtos facilmente alcançável em qualquer local (não dependendendo de recarregar a página ao retornar da aba de detalhes).
* **Remoção de Latência Artificial:** O `.delayed` de 2 segundos foi retirado para focar na latência real da API.
* **Componente de Atualização Fluída:** Introdução de `RefreshIndicator` com atualização na chamada do `loadProducts`, que evita que a lista pisque e dê block num loop caso ela já tenha dados velhos para ler na interface.
* **Implementação de Cache de Imagens robusto:** Uso da dependência `cached_network_image`.

## 3. Justificativa técnica relacionando cada mudança aos problemas

* **Arquitetura (MVC & Repository Pattern com Provider):** A mudança isola "como os dados são buscados" de "como os dados são exibidos". Essa separação (SoC - Separation of Concerns) torna o App testável via Mock, reutilizável (vários widgets podem compartilhar o acesso ao produto sem repetição de Request http) e modular.
* **Atualização via Provider sem Recarregamento Forçado no `pop`:** Uma vez que os dados foram buscados, eles ficam armazenados na memória pelo `ProductController`. Ao realizar o Pop da tela "Detalhes", nada aciona o banco. Isso corrige a dupla requisição ao voltar, economiza rede, corta totalmente a sensação de lentidão e melhora drasticamente a responsividade, usando Cache em Memória.
* **Cache de Imagens com `cached_network_image`:** Diferente do `Image.network`, este pacote guarda fisicamente as imagens baixadas no armazenamento (cache persistente do dispositivo). Com isso, mesmo quando o aplicativo é encerrado e aberto novamente o carregamento das texturas é imediato economizando banda. A inclusão de `placeholder` proporciona também feedback visual com `CircularProgressIndicator` pontuais para cada imagem em vez de bloquear a visualização (aumenta o UX index e resposividade sob lentidão de rede).
* **Remoção das interrupções obstrutivas globais no recarregamento:** Com o uso conjunto do Consumer de State do provider o app apenas exibe Single Loading quando o produto real está Empty na lista, proporcionando visões instantâneas ao cache sem flash-refresh destrutivos na tela (o RefreshIndicator apenas rola o progress e traz novos dados por baixo do pano de modo assíncrono).