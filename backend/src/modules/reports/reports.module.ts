import { Module } from '@nestjs/common';
import { SalesModule } from '../sales/sales.module';
import { MedicinesModule } from '../medicines/medicines.module';
import { ReportsService } from './reports.service';
import { ReportsController } from './reports.controller';

@Module({
  imports: [SalesModule, MedicinesModule],
  providers: [ReportsService],
  controllers: [ReportsController],
})
export class ReportsModule {}
