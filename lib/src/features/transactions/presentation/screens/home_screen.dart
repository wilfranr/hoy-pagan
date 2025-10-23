import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipu/src/features/transactions/presentation/widgets/new_transaction_modal.dart';
import 'package:kipu/src/features/theme_selector/presentation/screens/theme_selector_screen.dart';
import 'package:kipu/src/features/user_profile/presentation/screens/registro_usuario_screen.dart';
import 'package:kipu/src/features/transactions/presentation/screens/categorias_screen.dart';
import 'package:kipu/src/features/auth/application/auth_service.dart';
import 'package:kipu/src/features/firestore/application/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  User? _user;
  int _selectedIndex = 2; // 2 = Inicio

  @override
  void initState() {
    super.initState();
    _user = _authService.authStateChanges.first.then((user) => setState(() => _user = user)) as User?;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleUserMenuSelection(String value) {
    switch (value) {
      case 'perfil':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistroUsuarioScreen(),
          ),
        );
        break;
      case 'tema':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ThemeSelectorScreen(),
          ),
        );
        break;
      case 'categorias':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriasScreen(),
          ),
        );
        break;
      case 'cerrar_sesion':
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const Center(child: Text('Ingresos')), // Placeholder
      const Center(child: Text('Gastos')), // Placeholder
      _buildHomeTab(context), // Inicio
      const Center(child: Text('Pagos')), // Placeholder
      const Center(child: Text('Espacios')), // Placeholder
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.trending_up, 'Ingresos', 0),
                _buildNavItem(context, Icons.trending_down, 'Gastos', 1),
                _buildNavItem(context, Icons.home, 'Inicio', 2),
                _buildNavItem(context, Icons.credit_card, 'Pagos', 3),
                _buildNavItem(context, Icons.grid_view, 'Espacios', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildGradientHeader(context),
          Expanded(
            child: _user == null
                ? const Center(child: CircularProgressIndicator())
                : _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const NewTransactionModal(tipo: 'gasto'),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2EA198), Color(0xFF0A3834)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text('Personal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: _handleUserMenuSelection,
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'perfil',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Mi Perfil'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'tema',
                        child: Row(
                          children: [
                            Icon(Icons.palette, color: Colors.grey),
                            SizedBox(width: 8),
                            Text("Tema"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'categorias',
                        child: Row(
                          children: [
                            Icon(Icons.category, color: Colors.grey),
                            SizedBox(width: 8),
                            Text("Categorías"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'cerrar_sesion',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  '\$0', // TODO: Calcular el saldo
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTransactionsStream(_user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionItem(context, transactions[index]);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, DocumentSnapshot transaction) {
    final data = transaction.data() as Map<String, dynamic>;
    final isIncome = data['tipo'] == 'ingreso';
    final amountColor = isIncome ? Theme.of(context).primaryColor : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);

    return ListTile(
      leading: const Icon(Icons.swap_horiz),
      title: Text(data['descripcion'] ?? 'Sin descripción'),
      subtitle: Text(DateFormat('dd/MM/yyyy').format((data['fecha'] as Timestamp).toDate())),
      trailing: Text(
        '$amountPrefix${currencyFormat.format(data['monto'])}',
        style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    Color getSelectedColor() {
      switch (index) {
        case 0: return const Color(0xFF00C896);
        case 1: return Colors.red;
        case 3: return const Color(0xFF3B82F6);
        default: return Theme.of(context).primaryColor;
      }
    }
    
    final color = isSelected ? getSelectedColor() : Theme.of(context).textTheme.bodySmall?.color;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}