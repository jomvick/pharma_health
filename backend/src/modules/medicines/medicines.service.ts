import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Medicine, MedicineDocument } from './medicine.schema';
import { Lot, LotDocument } from '../lots/lot.schema';
import { Alert, AlertDocument } from '../alerts/alert.schema';

@Injectable()
export class MedicinesService {
  constructor(
    @InjectModel(Medicine.name) private medicineModel: Model<MedicineDocument>,
    @InjectModel(Lot.name) private lotModel: Model<LotDocument>,
    @InjectModel(Alert.name) private alertModel: Model<AlertDocument>,
  ) {}

  async findAll(page: number, limit: number, query: any): Promise<{ data: MedicineDocument[]; total: number }> {
    const skip = (page - 1) * limit;
    const filter: any = { deletedAt: null };

    if (query.categorie) filter.categorie = query.categorie;
    if (query.nom) filter.nom = new RegExp(query.nom, 'i');

    const total = await this.medicineModel.countDocuments(filter);
    const data = await this.medicineModel.find(filter)
      .populate('lots')
      .skip(skip)
      .limit(limit)
      .sort({ nom: 1 })
      .exec();

    return { data, total };
  }

  async findOne(id: string): Promise<MedicineDocument> {
    const medicine = await this.medicineModel.findOne({ _id: id, deletedAt: null }).populate('lots');
    if (!medicine) throw new NotFoundException('Médicament introuvable');
    return medicine;
  }

  async create(data: any): Promise<MedicineDocument> {
    // Mapping for backward compatibility with English field names
    const mappedData: any = { ...data };
    if (data.name) mappedData.nom = data.name;
    if (data.category) mappedData.categorie = data.category;
    if (data.price) mappedData.prixVente = data.price;
    if (data.min_threshold) mappedData.seuilAlerte = data.min_threshold;
    if (data.buying_price) mappedData.prixAchat = data.buying_price;

    const newMed = new this.medicineModel(mappedData);
    const savedMed = await newMed.save();

    // If initial stock is provided, create an initial lot
    if (data.stock_quantity && data.stock_quantity > 0) {
      await new this.lotModel({
        medicine: savedMed._id,
        numeroLot: 'INITIAL-' + Date.now().toString().slice(-6),
        quantite: data.stock_quantity,
        dateExpiration: data.expiry_date || new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // Default 1 year if not provided
        prixAchat: data.buying_price || 0
      }).save();
    }

    // CORRECTION: ne déclencher l'alerte que si un stock est explicitement fourni
    // ET qu'il est strictement en dessous du seuil (évite l'alerte parasite à la création)
    const stockQuantity = data.stock_quantity ?? 0;
    const threshold = mappedData.seuilAlerte ?? 10;
    if (data.stock_quantity !== undefined && stockQuantity < threshold) {
        await new this.alertModel({
            type: 'stock_bas',
            medicine: savedMed._id,
            valeur: `Stock critique à la création: ${stockQuantity} (seuil: ${threshold})`,
            lu: false
        }).save();
    }

    return savedMed;
  }

  async update(id: string, data: Partial<Medicine>): Promise<MedicineDocument> {
    const updated = await this.medicineModel.findOneAndUpdate(
      { _id: id, deletedAt: null },
      data,
      { new: true }
    );
    if (!updated) throw new NotFoundException('Médicament introuvable');
    return updated;
  }

  async softDelete(id: string): Promise<MedicineDocument> {
    const deleted = await this.medicineModel.findByIdAndUpdate(id, { deletedAt: new Date() }, { new: true });
    if (!deleted) throw new NotFoundException('Médicament introuvable');
    return deleted;
  }
}
