import { Controller, Post, Get, Body, Query, UseGuards, Request } from '@nestjs/common';
import { SalesService } from './sales.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@Controller('sales')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SalesController {
  constructor(private readonly salesService: SalesService) {}

  @Post()
  @Roles('Admin', 'Pharmacien', 'Caissier')
  async createSale(@Body('items') items: any[], @Request() req: any) {
    const userId = req.user._id || req.user.id;
    const sale = await this.salesService.createSale(items, userId);
    return { success: true, message: 'Vente enregistrée avec succès.', sale };
  }

  @Get()
  @Roles('Admin', 'Pharmacien')
  async getAllSales(@Query() query: any) {
    const sales = await this.salesService.findAll(query);
    return { success: true, sales };
  }
}
