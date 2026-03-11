import { Controller, Get, Post, Body, Param, UseGuards, Query } from '@nestjs/common';
import { LotsService } from './lots.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@Controller('stock')
@UseGuards(JwtAuthGuard, RolesGuard)
export class LotsController {
  constructor(private readonly lotsService: LotsService) {}

  @Post('entry')
  @Roles('Admin', 'Pharmacien')
  async createEntry(@Body() body: any) {
    const lot = await this.lotsService.createEntry(body);
    return { success: true, message: 'Entrée en stock enregistrée avec succès.', lot };
  }

  @Get('expiring')
  @Roles('Admin', 'Pharmacien')
  async getExpiring(@Query('days') days?: string) {
    // CORRECTION: convertir explicitement en number (les query params sont des strings)
    const daysNumber = days ? parseInt(days, 10) : 30;
    const lots = await this.lotsService.findExpiring(daysNumber);
    return { success: true, count: lots.length, lots };
  }

  @Get('medicine/:id')
  @Roles('Admin', 'Pharmacien', 'Caissier')
  async getMedicineLots(@Param('id') id: string) {
    const lots = await this.lotsService.getMedicineLots(id);
    return { success: true, lots };
  }
}
