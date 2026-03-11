import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Lot, LotSchema } from './lot.schema';
import { LotsService } from './lots.service';
import { LotsController } from './lots.controller';
import { MedicinesModule } from '../medicines/medicines.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Lot.name, schema: LotSchema }]),
    MedicinesModule
  ],
  providers: [LotsService],
  controllers: [LotsController],
  exports: [LotsService, MongooseModule], // Export MongooseModule for LotModel access in Sales
})
export class LotsModule {}
