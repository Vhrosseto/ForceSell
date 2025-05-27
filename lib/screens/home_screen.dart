import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'usuarios_screen.dart';
import 'clientes_screen.dart';
import 'produtos_screen.dart';
import 'pedidos_screen.dart';
import 'sync_screen.dart';
import 'configuracao_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForceSell'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade600,
                      child: Text(
                        usuario.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo, ${usuario.nome}!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Sistema de Vendas',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Usuários',
                    Icons.people,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsuariosScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Clientes',
                    Icons.person,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientesScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Produtos',
                    Icons.inventory,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProdutosScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Pedidos',
                    Icons.shopping_cart,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PedidosScreen(usuario: usuario),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Sincronização',
                    Icons.sync,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Configurações',
                    Icons.settings,
                    Colors.grey,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfiguracaoScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
