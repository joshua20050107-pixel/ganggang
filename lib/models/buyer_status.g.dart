// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuyerStatusAdapter extends TypeAdapter<BuyerStatus> {
  @override
  final int typeId = 1;

  @override
  BuyerStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuyerStatus(
      name: fields[0] as String,
      isPaid: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BuyerStatus obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
