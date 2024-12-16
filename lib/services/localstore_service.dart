import 'package:localstore/localstore.dart';

class LocalStoreService {
  static final LocalStoreService _instance = LocalStoreService._internal();
  factory LocalStoreService() => _instance;
  LocalStoreService._internal();

  // Get an instance of Localstore
  final _db = Localstore.instance;

  // Save a document to a specific collection
  Future<void> saveDocument(
      {required String collection,
      required String documentId,
      required Map<String, dynamic> data}) async {
    try {
      await _db.collection(collection).doc(documentId).set(data);
    } catch (e) {
      print('Error saving document: $e');
    }
  }

  // Retrieve a single document from a collection
  Future<Map<String, dynamic>?> getDocument(
      {required String collection, required String documentId}) async {
    try {
      return await _db.collection(collection).doc(documentId).get();
    } catch (e) {
      print('Error retrieving document: $e');
      return null;
    }
  }
}
