import { Injectable } from '@nestjs/common';
import { SalesService } from '../sales/sales.service';
import { MedicinesService } from '../medicines/medicines.service';

@Injectable()
export class ReportsService {
  constructor(
    private salesService: SalesService,
    private medicinesService: MedicinesService
  ) {}

  async generateInventoryReport() {
    // In a real app, use exceljs or pdfkit here.
    // For now, return the data structure.
    const { data: medicines } = await this.medicinesService.findAll(1, 1000, {});
    return medicines;
  }

  async generateSalesReport(startDate: Date, endDate: Date) {
    // CORRECTION: utiliser `createdAt` (généré par timestamps:true) et non `horodatage`
    const sales = await this.salesService.findAll({
      createdAt: { $gte: startDate, $lte: endDate }
    });
    return sales;
  }
}
