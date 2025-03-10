import 'package:dartz/dartz.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';
import '../../../../core/errors/failure.dart';
class GetSaleById {
  final SaleRepository repository;

  GetSaleById(this.repository);

  Future<Either<Failure, Sale>> call(String id) async {
    return await repository.getSaleById(id);
  }
}