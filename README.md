# ForceSell - Sistema de Vendas

Sistema de vendas desenvolvido em Flutter com banco de dados SQLite local e sincronização com servidor.

## Funcionalidades

### 1. Autenticação

- Tela de login com validação
- Usuário padrão: `admin` / Senha: `admin`

### 2. Cadastros (CRUD Completo)

- **Usuários**: Gerenciamento de usuários do sistema
- **Clientes**: Cadastro de clientes (Pessoa Física/Jurídica) com validação de CPF/CNPJ
- **Produtos**: Cadastro de produtos com controle de estoque
- **Pedidos**: Criação de pedidos com itens e pagamentos

### 3. Funcionalidades Especiais

- **Consulta CEP**: Integração com API ViaCEP para preenchimento automático de endereços
- **Validações**: CPF, CNPJ, campos obrigatórios
- **Sincronização**: Envio e recebimento de dados do servidor
- **Configurações**: Configuração do servidor de sincronização

## Estrutura do Banco de Dados

### Tabelas

- `usuarios` - Dados dos usuários do sistema
- `clientes` - Cadastro de clientes
- `produtos` - Catálogo de produtos
- `pedidos` - Cabeçalho dos pedidos
- `pedido_itens` - Itens dos pedidos
- `pedido_pagamentos` - Formas de pagamento dos pedidos
- `configuracoes` - Configurações do sistema

### Campos de Controle

Todas as tabelas possuem o campo `data_ultima_alteracao` para controle de sincronização.

## Regras de Negócio

### Pedidos

- Deve ter pelo menos 1 item e 1 pagamento
- Soma dos pagamentos deve ser igual ao total dos itens
- Validação de consistência antes de salvar

### Sincronização

- Registros novos (sem `data_ultima_alteracao`) são enviados ao servidor
- Registros do servidor com data mais recente atualizam os locais
- Controle de erros por entidade

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0
  http: ^1.1.0
  path: ^1.8.3
```

## Como Executar

1. Clone o repositório
2. Execute `flutter pub get` para instalar as dependências
3. Execute `flutter run` para iniciar o aplicativo

## APIs Utilizadas

- **ViaCEP**: `https://viacep.com.br/ws/{cep}/json/` - Consulta de CEP
- **Servidor Local**: `localhost:8080` - Sincronização de dados

## Endpoints de Sincronização

### GET (Buscar dados do servidor)

- `/usuarios`
- `/clientes`
- `/produtos`

### POST (Enviar dados para o servidor)

- `/usuarios`
- `/clientes`
- `/produtos`
- `/pedidos`

## Estrutura do Projeto

```
lib/
├── controllers/          # Controladores (DAOs)
├── database/            # Helper do banco SQLite
├── models/              # Modelos de dados
├── screens/             # Telas do aplicativo
├── services/            # Serviços (CEP, Sync)
└── main.dart           # Arquivo principal
```

## Telas Implementadas

### ✅ **Telas Completas com CRUD**

1. **Login** - Autenticação de usuários

   - Validação de credenciais
   - Usuário padrão: admin/admin
   - Navegação para tela principal

2. **Home** - Menu principal com navegação

   - Cards de navegação para todas as funcionalidades
   - Interface moderna e intuitiva
   - Informações do usuário logado

3. **Usuários** - Gerenciamento completo de usuários

   - ✅ Listagem com busca
   - ✅ Formulário de cadastro/edição
   - ✅ Validações (nome único, campos obrigatórios)
   - ✅ Exclusão com confirmação
   - ✅ CRUD completo

4. **Clientes** - Cadastro completo de clientes

   - ✅ Listagem com busca por nome
   - ✅ Formulário completo (PF/PJ)
   - ✅ Integração com API ViaCEP
   - ✅ Validação de CPF/CNPJ
   - ✅ Campos de endereço completos
   - ✅ CRUD completo

5. **Produtos** - Catálogo completo de produtos

   - ✅ Listagem com filtro (ativos/todos)
   - ✅ Formulário com todas as validações
   - ✅ Controle de estoque e preços
   - ✅ Status ativo/inativo
   - ✅ Código de barras opcional
   - ✅ CRUD completo

6. **Pedidos** - Gestão de pedidos (básico)

   - ✅ Listagem de pedidos
   - ✅ Visualização de detalhes
   - ✅ Exclusão de pedidos
   - ✅ Formulário de criação (pendente)

7. **Sincronização** - Controle completo de sincronização

   - ✅ Interface de sincronização
   - ✅ Relatório de erros por entidade
   - ✅ Indicadores de progresso
   - ✅ Integração com SyncService

8. **Configurações** - Configurações do sistema
   - ✅ Configuração do servidor
   - ✅ Teste de conexão
   - ✅ Documentação dos endpoints
   - ✅ Validação de URLs

### 🎯 **Funcionalidades Implementadas**

- **Autenticação**: Login funcional com usuário padrão
- **Banco de Dados**: SQLite com todas as tabelas
- **Validações**: CPF, CNPJ, campos obrigatórios
- **API Externa**: Integração com ViaCEP
- **Sincronização**: Sistema completo de sync
- **Interface**: Material Design moderno
- **Navegação**: Fluxo completo entre telas

### 📋 **Próximos Passos**

Para completar 100% do sistema:

1. **Formulário de Pedidos Completo**

   - Seleção de cliente e produtos
   - Adição/remoção de itens
   - Múltiplas formas de pagamento
   - Validação de totais

2. **Melhorias Opcionais**
   - Relatórios e dashboards
   - Backup/restore de dados
   - Configurações avançadas
   - Temas personalizados

## Tecnologias

- **Flutter** - Framework de desenvolvimento
- **SQLite** - Banco de dados local
- **HTTP** - Comunicação com servidor
- **Material Design** - Interface do usuário
