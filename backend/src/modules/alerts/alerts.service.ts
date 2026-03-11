import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Alert, AlertDocument } from './alert.schema';

@Injectable()
export class AlertsService {
  constructor(@InjectModel(Alert.name) private alertModel: Model<AlertDocument>) {}

  async create(data: Partial<Alert>): Promise<AlertDocument> {
    const alert = new this.alertModel(data);
    return alert.save();
  }

  async findUnread(): Promise<AlertDocument[]> {
    return this.alertModel.find({ lu: false }).populate('medicine', 'nom categorie seuilAlerte').sort({ createdAt: -1 }).exec();
  }

  // AJOUT: vérification d'existence pour éviter les alertes dupliquées
  async existsUnread(type: string, medicineId: any): Promise<boolean> {
    const existing = await this.alertModel.findOne({ type, medicine: medicineId, lu: false }).exec();
    return !!existing;
  }

  async markAsRead(id: string): Promise<AlertDocument> {
    return this.alertModel.findByIdAndUpdate(id, { lu: true }, { new: true }).exec();
  }
}
