# Mobile Arquitetura 01 — Catálogo de Produtos Flutter

Projeto Flutter desenvolvido como entrega da **Atividade 12 — Autenticação e Troca de API**, consistindo na análise e evolução de uma aplicação Flutter com problemas intencionais de latência, responsividade e ausência de cache.

## Sobre o Projeto

Este repositório contém a versão **evoluída** da aplicação, com correções arquiteturais e melhorias de experiência do usuário. O projeto original apresentava problemas como: acoplamento entre UI e infraestrutura, latência artificial, ausência de cache de imagens e recarregamento desnecessário.

## Funcionalidades

- **Autenticação** — Login com validação de campos e tratamento de erros via API DummyJSON
- **Sessão persistente** — Sessão do usuário mantida entre sessões do app via SharedPreferences
- **Bloqueio sem login** — Acesso à tela de produtos bloqueado para usuários não autenticados
- **Catálogo de produtos** — Listagem com título, preço, categoria e imagem (thumbnail)
- **Detalhes do produto** — Tela com nome, preço, descrição, avaliação e galeria de imagens
- **Sistema de favoritos** — Marcar/desmarcar produtos como favoritos com persistência local
- **Logout** — Encerramento da sessão com redirecionamento para tela de login
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

O projeto segue o padrão **MVC + Repository** com gerenciamento de estado via **Provider**:

```
lib/
├── main.dart                          # Ponto de entrada e configuração do MultiProvider
├── models/
│   ├── product.dart                   # Modelo de dados Product
│   └── user.dart                      # Modelo de dados User
├── repositories/
│   ├── auth_repository.dart           # Chamadas à API de autenticação
│   └── product_repository.dart        # Chamadas à API de produtos
├── controllers/
│   ├── product_controller.dart        # Estado e lógica da listagem de produtos
│   └── favorite_controller.dart       # Estado e lógica de favoritos
├── services/
│   └── session_service.dart           # Gerenciamento de sessão do usuário
└── screens/
    ├── login_page.dart                # Tela de login
    ├── product_list_page.dart         # Tela principal com lista de produtos
    └── product_detail_page.dart       # Tela de detalhes do produto
```

## Justificativa do Provider

O **Provider** foi escolhido como gerenciador de estado por ser a recomendação oficial do Flutter para projetos de pequeno e médio porte. Entre os motivos:

- Simplicidade e baixa curva de aprendizado utilizando `ChangeNotifier`
- Integração nativa com o ciclo de vida dos Widgets
- Baixo boilerplate comparado ao BLoC
- Reatividade granular com `Consumer<T>`
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
