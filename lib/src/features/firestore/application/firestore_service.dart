import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- TRANSACCIONES ---

  // Obtener el stream de transacciones de un usuario para que se actualice en tiempo real
  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Añadir una nueva transacción
  Future<void> addTransaction(String userId, Map<String, dynamic> transactionData) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add(transactionData);
  }

  // Añadir una nueva transacción recurrente
  Future<void> addRecurringTransaction(String userId, Map<String, dynamic> transactionData) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .add(transactionData);
  }

  // --- CATEGORÍAS ---

  // Obtener el stream de categorías de un usuario
  Stream<QuerySnapshot> getCategoriesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots();
  }

  // Añadir una nueva categoría
  Future<void> addCategory(String userId, Map<String, dynamic> categoryData) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .add(categoryData);
  }
}
