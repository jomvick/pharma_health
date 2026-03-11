import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';

// Modules
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { MedicinesModule } from './modules/medicines/medicines.module';
import { LotsModule } from './modules/lots/lots.module';
import { SalesModule } from './modules/sales/sales.module';
import { AlertsModule } from './modules/alerts/alerts.module';
import { ActivityLogsModule } from './modules/activity-logs/activity-logs.module';
import { ReportsModule } from './modules/reports/reports.module';

import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true, // makes env variables accessible everywhere
    }),
    MongooseModule.forRoot(process.env.MONGO_URI || 'mongodb://localhost:27017/pharmaci'),
    AuthModule,
    UsersModule,
    MedicinesModule,
    LotsModule,
    SalesModule,
    AlertsModule,
    ActivityLogsModule,
    ReportsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
