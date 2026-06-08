import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/permiso_model.dart';

/// Contrato del origen de datos remoto de permisos de salud.
abstract class PermisosRemoteDataSource {
  /// Envía un [PermisoModel] a la colección `permisos` en Firestore.
  /// Retorna el ID del documento creado.
  /// Lanza [ServerException] ante cualquier error de red o Firestore.
  Future<String> enviarPermiso(PermisoModel permiso);
}

class PermisosRemoteDataSourceImpl implements PermisosRemoteDataSource {
  final FirebaseFirestore _firestore;

  const PermisosRemoteDataSourceImpl(this._firestore);

  @override
  Future<String> enviarPermiso(PermisoModel permiso) async {
    try {
      final docRef = _firestore.collection('permisos').doc();
      final data = permiso.toJson();
      data['fechaSolicitud'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Error de Firestore inesperado.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
