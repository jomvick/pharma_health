import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Alert, AlertSchema } from './alert.schema';
import { AlertsService } from './alerts.service';
import { AlertsController } from './alerts.controller';
import { LotsModule } from '../lots/lots.module';
import { MedicinesModule } from '../medicines/medicines.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Alert.name, schema: AlertSchema }]),
    LotsModule,
    MedicinesModule
  ],
  providers: [AlertsService],
  controllers: [AlertsController],
  exports: [AlertsService]
})
export class AlertsModule {}
