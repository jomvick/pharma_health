import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Lot, LotDocument } from './lot.schema';
import { MedicinesService } from '../medicines/medicines.service';

@Injectable()
export class LotsService {
  constructor(
    @InjectModel(Lot.name) private lotModel: Model<LotDocument>,
    private medicinesService: MedicinesService
  ) {}

  async createEntry(data: any): Promise<LotDocument> {
    console.log(`[LotsService] Creating entry for medicine: ${data.medicine}`);
    const medicine = await this.medicinesService.findOne(data.medicine);
    if (!medicine) {
      throw new NotFoundException('Médicament introuvable');
    }

    // Explicitly cast medicine ID
    const lotData = { ...data };
    if (typeof data.medicine === 'string') {
        lotData.medicine = new Types.ObjectId(data.medicine);
    }

    const newLot = new this.lotModel(lotData);
    const saved = await newLot.save();
    console.log(`[LotsService] Saved lot: ${saved.numeroLot} for med: ${saved.medicine}`);
    return saved;
  }

  async findExpiring(days: number = 30): Promise<LotDocument[]> {
    const futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + days);

    return this.lotModel.find({
      dateExpiration: { $lte: futureDate },
      quantite: { $gt: 0 }
    }).populate('medicine', 'nom categorie').exec();
  }

  async getMedicineLots(medicineId: string): Promise<LotDocument[]> {
    return this.lotModel.find({ medicine: new Types.ObjectId(medicineId), quantite: { $gt: 0 } }).sort({ dateExpiration: 1 }).exec();
  }
}
