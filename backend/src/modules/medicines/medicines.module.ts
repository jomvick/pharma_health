import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Medicine, MedicineSchema } from './medicine.schema';
import { Lot, LotSchema } from '../lots/lot.schema';
import { Alert, AlertSchema } from '../alerts/alert.schema';
import { MedicinesService } from './medicines.service';
import { MedicinesController } from './medicines.controller';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Medicine.name, schema: MedicineSchema },
      { name: Lot.name, schema: LotSchema },
      { name: Alert.name, schema: AlertSchema }
    ])
  ],
  providers: [MedicinesService],
  controllers: [MedicinesController],
  exports: [MedicinesService, MongooseModule],
})
export class MedicinesModule {}
