import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@Controller('reports')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('inventory')
  @Roles('Admin', 'Pharmacien')
  async getInventoryReport() {
    const data = await this.reportsService.generateInventoryReport();
    return { success: true, data };
  }

  @Get('sales')
  @Roles('Admin')
  async getSalesReport(
    @Query('start') start?: string,
    @Query('end') end?: string,
    @Query('period') period?: string
  ) {
    console.log(`[ReportsController] start: ${start}, end: ${end}, period: ${period}`);
    
    let startDate = new Date();
    let endDate = new Date();

    if (period === 'today') {
        startDate.setHours(0, 0, 0, 0);
        endDate.setHours(23, 59, 59, 999);
    } else if (period === 'week') {
        startDate.setDate(startDate.getDate() - 7);
    } else if (period === 'month') {
        startDate.setMonth(startDate.getMonth() - 1);
    } else if (start || end) {
        if (start) startDate = new Date(start);
        if (end) endDate = new Date(end);
    } else {
        // Default to today if nothing provided
        startDate.setHours(0, 0, 0, 0);
        endDate.setHours(23, 59, 59, 999);
    }

    // Safety check
    if (isNaN(startDate.getTime())) startDate = new Date();
    if (isNaN(endDate.getTime())) endDate = new Date();

    console.log(`[ReportsController] Parsed: \${startDate.toISOString()} to \${endDate.toISOString()}`);

    const data = await this.reportsService.generateSalesReport(startDate, endDate);
    return { success: true, data, period: period || 'custom' };
  }
}
