// lib/servicios/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// Ajusta la ruta si es necesario para llegar a tarjeta_eventos.dart desde aquí.
// Si firestore_service.dart está en lib/servicios/ y tarjeta_eventos.dart está en lib/widgets/,
// la ruta '../widgets/' es correcta.
import '../widgets/tarjeta_eventos.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Define la ruta de la colección para los eventos de un usuario específico
  String _rutaEventosUsuario(String userId) {
    // Guardará los eventos en: /usuarios/{userId}/eventos_calendario/{eventoId}
    return 'usuarios/$userId/eventos_calendario';
  }

  // Agregar un nuevo evento a Firestore
  Future<void> agregarEvento(TarjetaEventos evento, String userId) async {
    if (userId.isEmpty) {
      print("FirestoreService: No se puede agregar evento, userId está vacío.");
      throw Exception("UserID vacío al intentar agregar evento.");
    }
    try {
      await _db
          .collection(_rutaEventosUsuario(userId))
          .doc(evento.id) // Usar el ID pre-generado del evento
          .set(evento.toMap()); // Usar el método toMap() de TarjetaEventos
    } catch (e) {
      print('Error al agregar evento a Firestore: $e');
      rethrow; // Re-lanzar el error para que sea manejado por quien llame
    }
  }

  // Actualizar un evento existente en Firestore
  Future<void> actualizarEvento(TarjetaEventos evento, String userId) async {
    if (userId.isEmpty) {
      print(
        "FirestoreService: No se puede actualizar evento, userId está vacío.",
      );
      throw Exception("UserID vacío al intentar actualizar evento.");
    }
    try {
      await _db
          .collection(_rutaEventosUsuario(userId))
          .doc(evento.id)
          .update(evento.toMap());
    } catch (e) {
      print('Error al actualizar evento en Firestore: $e');
      rethrow;
    }
  }

  // Eliminar un evento de Firestore
  Future<void> eliminarEvento(String eventoId, String userId) async {
    if (userId.isEmpty) {
      print(
        "FirestoreService: No se puede eliminar evento, userId está vacío.",
      );
      throw Exception("UserID vacío al intentar eliminar evento.");
    }
    try {
      await _db.collection(_rutaEventosUsuario(userId)).doc(eventoId).delete();
    } catch (e) {
      print('Error al eliminar evento de Firestore: $e');
      rethrow;
    }
  }

  // Obtener un Stream de la lista de eventos de un usuario.
  // El Stream se actualizará automáticamente cuando los datos cambien en Firestore.
  Stream<List<TarjetaEventos>> obtenerEventosStream(String userId) {
    if (userId.isEmpty) {
      print(
        "FirestoreService: No se puede obtener stream de eventos, userId está vacío.",
      );
      return Stream.value([]); // Devuelve un stream vacío si no hay userId
    }
    try {
      return _db
          .collection(_rutaEventosUsuario(userId))
          .snapshots() // snapshots() devuelve un Stream<QuerySnapshot>
          .map((snapshot) {
            // Mapea cada QuerySnapshot a List<TarjetaEventos>
            try {
              return snapshot.docs.map((doc) {
                // Asegúrate de que TarjetaEventos.fromMap maneje correctamente los datos
                // y cualquier campo que pueda ser null.
                return TarjetaEventos.fromMap(doc.data());
              }).toList();
            } catch (e) {
              print("Error al mapear documentos del stream de eventos: $e");
              return []; // Lista vacía en caso de error de mapeo
            }
          });
    } catch (e) {
      print('Error al obtener stream de eventos de Firestore: $e');
      return Stream.error(
        e,
      ); // O Stream.value([]) si prefieres no propagar el error así
    }
  }

  // Opcional: Obtener la lista de eventos una sola vez (como un Future)
  Future<List<TarjetaEventos>> obtenerEventosFuture(String userId) async {
    if (userId.isEmpty) {
      print(
        "FirestoreService: No se puede obtener future de eventos, userId está vacío.",
      );
      return [];
    }
    try {
      final snapshot = await _db.collection(_rutaEventosUsuario(userId)).get();

      return snapshot.docs.map((doc) {
        return TarjetaEventos.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print('Error al obtener future de eventos de Firestore: $e');
      return []; // Devolver lista vacía en caso de error
    }
  }
}
