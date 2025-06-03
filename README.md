<div align="center">
  <img src="assets/logo.png" alt="ForceSell Logo" width="200"/>
  
  <h1>ForceSell</h1>
  <h3>Sistema de Gestão de Vendas Offline-First</h3>
  
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
    <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS"/>
  </p>
</div>

<hr/>

<div align="center">
  <h2>📋 Índice</h2>
  <p>
    <a href="#sobre">Sobre</a> •
    <a href="#funcionalidades">Funcionalidades</a> •
    <a href="#tecnologias">Tecnologias</a> •
    <a href="#arquitetura">Arquitetura</a> •
    <a href="#instalacao">Instalação</a> •
    <a href="#uso">Como Usar</a> •
    <a href="#contribuicao">Contribuição</a> •
    
  </p>
</div>

<hr/>

<h2 id="sobre">📖 Sobre o Projeto</h2>

<p>
  O ForceSell é um sistema de gestão de vendas desenvolvido em Flutter que opera principalmente offline, 
  com capacidade de sincronização automática quando há conexão com o servidor. O sistema foi projetado 
  para funcionar em ambientes com conectividade instável, garantindo que as operações continuem 
  funcionando mesmo sem internet.
</p>

<h3>🎯 Objetivos</h3>

<ul>
  <li>Fornecer uma solução robusta para gestão de vendas offline</li>
  <li>Garantir sincronização confiável dos dados</li>
  <li>Oferecer interface intuitiva e responsiva</li>
  <li>Manter alta performance mesmo em dispositivos de baixo custo</li>
</ul>

<hr/>

<h2 id="funcionalidades">🚀 Funcionalidades</h2>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
  <div>
    <h3>👥 Gestão de Usuários</h3>
    <ul>
      <li>Cadastro e autenticação</li>
      <li>Controle de permissões</li>
      <li>Sincronização entre dispositivos</li>
      <li>Histórico de atividades</li>
    </ul>
  </div>

  <div>
    <h3>👤 Gestão de Clientes</h3>
    <ul>
      <li>Cadastro PF/PJ completo</li>
      <li>Histórico de compras</li>
      <li>Endereçamento automático</li>
      <li>Validação de documentos</li>
    </ul>
  </div>

  <div>
    <h3>📦 Gestão de Produtos</h3>
    <ul>
      <li>Controle de estoque</li>
      <li>Código de barras</li>
      <li>Preços e custos</li>
      <li>Status ativo/inativo</li>
    </ul>
  </div>

  <div>
    <h3>🛍️ Gestão de Pedidos</h3>
    <ul>
      <li>Criação offline</li>
      <li>Múltiplos pagamentos</li>
      <li>Histórico de vendas</li>
      <li>Relatórios gerenciais</li>
    </ul>
  </div>
</div>

<hr/>

<h2 id="tecnologias">🛠️ Tecnologias</h2>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
  <div>
    <h3>Frontend</h3>
    <ul>
      <li>Flutter</li>
      <li>Material Design</li>
      <li>Provider (Gerenciamento de Estado)</li>
    </ul>
  </div>

  <div>
    <h3>Backend</h3>
    <ul>
      <li>SQLite (Local)</li>
      <li>HTTP (Comunicação)</li>
      <li>REST API</li>
    </ul>
  </div>

  <div>
    <h3>Ferramentas</h3>
    <ul>
      <li>Git (Versionamento)</li>
      <li>VS Code (IDE)</li>
      <li>Insomnia (Testes API)</li>
    </ul>
  </div>
</div>

<hr/>

<h2 id="arquitetura">🏗️ Arquitetura</h2>

<h3>Estrutura do Projeto</h3>

<pre>
lib/
├── controllers/     # Lógica de negócio
│   ├── usuario_controller.dart
│   ├── cliente_controller.dart
│   ├── produto_controller.dart
│   └── pedido_controller.dart
├── database/        # Configuração SQLite
│   └── database_helper.dart
├── models/          # Modelos de dados
│   ├── usuario.dart
│   ├── cliente.dart
│   ├── produto.dart
│   └── pedido.dart
├── screens/         # Interface do usuário
│   ├── login/
│   ├── home/
│   ├── clientes/
│   ├── produtos/
│   └── pedidos/
└── services/        # Serviços externos
    └── sync_service.dart
</pre>

<h3>Sistema de Sincronização</h3>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
  <div>
    <h4>1. Operação Local</h4>
    <ul>
      <li>Dados salvos primeiro no SQLite</li>
      <li>Marcados com timestamp</li>
      <li>Disponíveis offline</li>
    </ul>
  </div>

  <div>
    <h4>2. Sincronização</h4>
    <ul>
      <li>Envio de dados novos</li>
      <li>Atualizações recentes</li>
      <li>Exclusões pendentes</li>
    </ul>
  </div>

  <div>
    <h4>3. Resolução de Conflitos</h4>
    <ul>
      <li>Baseado em timestamps</li>
      <li>Soft delete</li>
      <li>Log de operações</li>
    </ul>
  </div>
</div>

<hr/>

<h2 id="instalacao">📦 Instalação</h2>

<h3>Pré-requisitos</h3>

<ul>
  <li>Flutter SDK (versão 3.0.0 ou superior)</li>
  <li>Dart SDK (versão 2.17.0 ou superior)</li>
  <li>Android Studio / VS Code</li>
  <li>Git</li>
</ul>

<h3>Passos para Instalação</h3>

<ol>
  <li>
    <strong>Clone o repositório</strong>
    <pre>git clone https://github.com/seu-usuario/forcesell.git</pre>
  </li>
  
  <li>
    <strong>Instale as dependências</strong>
    <pre>flutter pub get</pre>
  </li>
  
  <li>
    <strong>Configure o ambiente</strong>
    <pre>flutter doctor</pre>
  </li>
  
  <li>
    <strong>Execute o projeto</strong>
    <pre>flutter run</pre>
  </li>
</ol>

<hr/>

<h2 id="uso">📱 Como Usar</h2>

<h3>Primeiro Acesso</h3>

<ol>
  <li>Use as credenciais padrão:
    <ul>
      <li>Usuário: admin</li>
      <li>Senha: admin</li>
    </ul>
  </li>
  <li>Configure o servidor de sincronização</li>
  <li>Execute a primeira sincronização</li>
</ol>

<h3>Operações Principais</h3>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
  <div>
    <h4>Cadastros</h4>
    <ul>
      <li>Clientes (PF/PJ)</li>
      <li>Produtos</li>
      <li>Usuários</li>
    </ul>
  </div>

  <div>
    <h4>Vendas</h4>
    <ul>
      <li>Criar pedido</li>
      <li>Adicionar itens</li>
      <li>Registrar pagamentos</li>
    </ul>
  </div>

  <div>
    <h4>Sincronização</h4>
    <ul>
      <li>Enviar dados</li>
      <li>Receber atualizações</li>
      <li>Verificar erros</li>
    </ul>
  </div>
</div>

<hr/>

<h2 id="contribuicao">🤝 Contribuição</h2>

<p>
  Contribuições são sempre bem-vindas! Para contribuir com o projeto:
</p>

<ol>
  <li>Faça um Fork do projeto</li>
  <li>Crie uma Branch para sua Feature (<code>git checkout -b feature/AmazingFeature</code>)</li>
  <li>Commit suas mudanças (<code>git commit -m 'Add some AmazingFeature'</code>)</li>
  <li>Push para a Branch (<code>git push origin feature/AmazingFeature</code>)</li>
  <li>Abra um Pull Request</li>
</ol>

<h3>Padrões de Código</h3>

<ul>
  <li>Siga o guia de estilo do Flutter</li>
  <li>Documente novas funcionalidades</li>
  <li>Adicione testes quando possível</li>
  <li>Mantenha o código limpo e organizado</li>
</ul>

<hr/>

<div align="center">
  <h2 id="desenvolvedores">👥 Desenvolvedores</h2>
<table>
  <tr>
    <th>Nome</th>
    <th>Matrícula</th>
  </tr>
  <tr>
    <td>Victor Hugo Paulo Rosseto</td>
    <td>123100013</td>
  </tr>
  <tr>
    <td>Gabriel Dondoni Pecly</td>
    <td>123100010</td>
  </tr>
</table>
