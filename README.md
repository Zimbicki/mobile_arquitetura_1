# Mobile Arquitetura 01 — Catálogo de Produtos Flutter

Projeto Flutter desenvolvido como entrega da **Atividade 12 — Autenticação e Troca de API**, consistindo na análise e evolução de uma aplicação Flutter com problemas intencionais de latência, responsividade e ausência de cache.

## Sobre o Projeto

Este repositório contém a versão **evoluída** da aplicação, com correções arquiteturais e melhorias de experiência do usuário. O projeto original apresentava problemas como: acoplamento entre UI e infraestrutura, latência artificial, ausência de cache de imagens e recarregamento desnecessário.

## Funcionalidades

- **Autenticação** — Login com validação de campos, toggle de visibilidade de senha e tratamento de erros via API DummyJSON
- **Sessão persistente** — Sessão do usuário mantida entre sessões do app via SharedPreferences
- **Bloqueio sem login** — Acesso à tela de produtos bloqueado para usuários não autenticados
- **Catálogo de produtos** — Listagem com título, preço, categoria e imagem (thumbnail)
- **Detalhes do produto** — Tela com nome, preço, descrição, avaliação e galeria de imagens
- **Sistema de favoritos** — Marcar/desmarcar produtos como favoritos com persistência local
- **Filtro de favoritos** — Botão no AppBar para exibir apenas produtos favoritados
- **Logout com confirmação** — Diálogo de confirmação antes de encerrar a sessão
- **Cache de imagens** — Armazenamento em disco via `cached_network_image`
- **Pull-to-refresh** — Atualização da lista sem bloquear a interface

## API Utilizada

O projeto consome a API pública [DummyJSON](https://dummyjson.com):

| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/auth/login` | POST | Autenticação de usuário |
| `/products` | GET | Listagem de produtos |
| `/products/{id}` | GET | Detalhes de um produto |

## Arquitetura

O projeto segue o padrão **Clean Architecture** com gerenciamento de estado via **Provider (ChangeNotifier + MVVM)**:

```
lib/
├── main.dart                                      # Ponto de entrada e injeção de dependências
├── core/
│   └── errors/
│       └── app_exception.dart                     # Exceção customizada da aplicação
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart            # Chamadas HTTP de autenticação
│   │   └── product_remote_datasource.dart         # Chamadas HTTP de produtos
│   ├── models/
│   │   ├── product_model.dart                     # Model com parse JSON (estende Product)
│   │   └── user_model.dart                        # Model com parse JSON (estende User)
│   ├── repositories/
│   │   ├── auth_repository_impl.dart              # Implementação do contrato AuthRepository
│   │   └── product_repository_impl.dart           # Implementação do contrato ProductRepository
│   └── session/
│       └── auth_session.dart                      # Gerenciamento de sessão (SharedPreferences)
├── domain/
│   ├── entities/
│   │   ├── product.dart                           # Entidade pura Product (sem JSON)
│   │   └── user.dart                              # Entidade pura User (sem JSON)
│   └── repositories/
│       ├── auth_repository.dart                   # Interface abstrata de autenticação
│       └── product_repository.dart                # Interface abstrata de produtos
└── presentation/
    ├── pages/
    │   ├── login_page.dart                        # Tela de login
    │   ├── product_list_page.dart                 # Tela principal com lista de produtos
    │   └── product_detail_page.dart               # Tela de detalhes do produto
    └── viewmodel/
        ├── auth_state.dart                        # Estado imutável de autenticação
        ├── auth_viewmodel.dart                    # ViewModel de autenticação
        ├── product_state.dart                     # Estado imutável de produtos
        └── product_viewmodel.dart                 # ViewModel de produtos e favoritos
```

### Camadas

| Camada | Responsabilidade |
|--------|------------------|
| **core** | Utilitários compartilhados (exceções, constantes) |
| **domain** | Entidades puras e interfaces abstratas de repositories — sem dependência de pacotes externos |
| **data** | Implementações concretas: datasources (HTTP), models (JSON), repositories e sessão |
| **presentation** | UI (pages) e lógica de apresentação (viewmodels com estados imutáveis) |

## Justificativa do Provider

O **Provider** foi escolhido como gerenciador de estado por ser a recomendação oficial do Flutter para projetos de pequeno e médio porte. Entre os motivos:

- Simplicidade e baixa curva de aprendizado utilizando `ChangeNotifier`
- Integração nativa com o ciclo de vida dos Widgets
- Baixo boilerplate comparado ao BLoC
- Reatividade granular com `Consumer<T>` e `context.watch`
- Adequação ao escopo do projeto

A justificativa completa está disponível no arquivo [DOCUMENTACAO.md](DOCUMENTACAO.md).

## Dependências

| Pacote | Versão | Finalidade |
|--------|--------|------------|
| `http` | ^1.2.1 | Requisições HTTP à API |
| `provider` | ^6.1.2 | Gerenciamento de estado |
| `cached_network_image` | ^3.3.1 | Cache de imagens em disco |
| `shared_preferences` | ^2.2.3 | Persistência local (sessão e favoritos) |

## Como Executar

```bash
flutter pub get
flutter run
```

### Credenciais de teste (API DummyJSON)

| Usuário | Senha |
|---------|-------|
| `emilys` | `emilyspass` |

## Documentação

A análise completa dos problemas identificados, as mudanças realizadas e a justificativa técnica de cada decisão estão detalhadas no arquivo [DOCUMENTACAO.md](DOCUMENTACAO.md).
