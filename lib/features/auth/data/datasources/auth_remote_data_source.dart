import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';

/// Contrato del origen de datos remoto de autenticación.
abstract class AuthRemoteDataSource {
  /// Autentica con Firebase Auth y retorna el `rol` del usuario desde Firestore.
  ///
  /// Lanza [ServerException] si las credenciales son incorrectas,
  /// el perfil no existe o el rol no está definido.
  Future<String> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const AuthRemoteDataSourceImpl(this._auth, this._firestore);

  @override
  Future<String> login(String email, String password) async {
    try {
      // ── 1. Autenticar con Firebase Auth ─────────────────────────────────
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw const ServerException('No se pudo obtener el ID del usuario.');
      }

      // ── 2. Obtener el perfil desde Firestore ─────────────────────────────
      final userDoc =
          await _firestore.collection('usuarios').doc(uid).get();

      if (!userDoc.exists) {
        throw const ServerException(
          'Perfil de usuario no encontrado. Contacta al administrador.',
        );
      }

      // ── 3. Extraer y validar el rol ──────────────────────────────────────
      final rol = userDoc.data()?['rol'] as String?;
      if (rol == null || rol.isEmpty) {
        throw const ServerException(
          'El usuario no tiene un rol asignado. Contacta al administrador.',
        );
      }

      return rol;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapAuthError(e.code));
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Error de Firestore inesperado.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _mapAuthError(String code) => switch (code) {
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Correo o contraseña incorrectos.',
        'user-disabled' => 'Esta cuenta ha sido deshabilitada.',
        'too-many-requests' =>
          'Demasiados intentos fallidos. Inténtalo más tarde.',
        'network-request-failed' =>
          'Sin conexión a internet. Verifica tu red.',
        _ => 'Error de autenticación ($code).',
      };
}
