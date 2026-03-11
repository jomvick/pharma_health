import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { MedicinesService } from './medicines.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@Controller('medicines')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MedicinesController {
  constructor(private readonly medicinesService: MedicinesService) {}

  @Get()
  @Roles('Admin', 'Pharmacien', 'Caissier')
  async getAll(@Query('page') page = 1, @Query('limit') limit = 20, @Query() query: any) {
    const result = await this.medicinesService.findAll(Number(page), Number(limit), query);
    return {
      success: true,
      page: Number(page),
      totalPages: Math.ceil(result.total / limit),
      total: result.total,
      medicines: result.data,
    };
  }

  @Get(':id')
  @Roles('Admin', 'Pharmacien', 'Caissier')
  async getOne(@Param('id') id: string) {
    const medicine = await this.medicinesService.findOne(id);
    return { success: true, medicine };
  }

  @Post()
  @Roles('Admin', 'Pharmacien')
  async create(@Body() body: any) {
    const medicine = await this.medicinesService.create(body);
    return { success: true, message: 'Médicament créé avec succès.', medicine };
  }

  @Put(':id')
  @Roles('Admin', 'Pharmacien')
  async update(@Param('id') id: string, @Body() body: any) {
    const medicine = await this.medicinesService.update(id, body);
    return { success: true, message: 'Médicament mis à jour.', medicine };
  }

  @Delete(':id')
  @Roles('Admin')
  async remove(@Param('id') id: string) {
    await this.medicinesService.softDelete(id);
    return { success: true, message: 'Médicament supprimé avec succès.' };
  }
}
