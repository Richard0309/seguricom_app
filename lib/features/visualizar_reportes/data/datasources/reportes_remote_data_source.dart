import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/reporte_model.dart';

abstract class ReportesRemoteDataSource {
  Future<List<ReporteModel>> getReportes(String idAlumno);
}

class ReportesRemoteDataSourceImpl implements ReportesRemoteDataSource {
  final FirebaseFirestore _firestore;

  const ReportesRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ReporteModel>> getReportes(String idAlumno) async {
    try {
      final snapshot = await _firestore
          .collection('reportes')
          .where('idAlumno', isEqualTo: idAlumno)
          .orderBy('fecha', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReporteModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        throw ServerException(
          'Se requiere un índice compuesto en Firestore (idAlumno + fecha). '
          'Consulta los logs de la consola para el link de creación automática.',
        );
      }
      throw ServerException('Error al obtener reportes: $e');
    }
  }
}