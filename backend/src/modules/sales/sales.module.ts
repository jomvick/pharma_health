import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Sale, SaleSchema } from './sale.schema';
import { SalesService } from './sales.service';
import { SalesController } from './sales.controller';
import { LotsModule } from '../lots/lots.module';
import { MedicinesModule } from '../medicines/medicines.module';
import { AlertsModule } from '../alerts/alerts.module';
import { ActivityLogsModule } from '../activity-logs/activity-logs.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Sale.name, schema: SaleSchema }]),
    LotsModule,
    MedicinesModule,
    AlertsModule,
    ActivityLogsModule,
  ],
  providers: [SalesService],
  controllers: [SalesController],
  exports: [SalesService],
})
export class SalesModule {}
