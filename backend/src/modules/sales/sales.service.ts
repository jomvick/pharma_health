import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Sale, SaleDocument, SaleItem } from './sale.schema';
import { Lot, LotDocument } from '../lots/lot.schema';
import { Medicine, MedicineDocument } from '../medicines/medicine.schema';
import { AlertsService } from '../alerts/alerts.service';
import { ActivityLogsService } from '../activity-logs/activity-logs.service';

@Injectable()
export class SalesService {
  constructor(
    @InjectModel(Sale.name) private saleModel: Model<SaleDocument>,
    @InjectModel(Lot.name) private lotModel: Model<LotDocument>,
    @InjectModel(Medicine.name) private medicineModel: Model<MedicineDocument>,
    private readonly alertsService: AlertsService,
    private readonly activityLogsService: ActivityLogsService,
  ) {}

  async createSale(items: any[], caissierId: string): Promise<SaleDocument> {
    const saleItems: SaleItem[] = [];
    let totalAmount = 0;

    for (const item of items) {
      const medicine = await this.medicineModel.findById(item.medicine);
      if (!medicine) {
        throw new NotFoundException(`Médicament introuvable : ${item.medicine}`);
      }

      // Find valid lots (not expired, qty > 0) ordered by expiration date (FIFO)
      const now = new Date();
      // CORRECTION: medicine._id est déjà un ObjectId puisque retourné par findById
      const medId = medicine._id;
      
      const validLots = await this.lotModel.find({
        medicine: medId,
        dateExpiration: { $gt: now },
        quantite: { $gt: 0 }
      }).sort({ dateExpiration: 1 }).exec();

      console.log(`[SalesService] Medicine: ${medicine.nom} (ID used in query: ${medId})`);
      console.log(`[SalesService] Query: { medicine: ${medId}, dateExpiration: { $gt: ${now} }, quantite: { $gt: 0 } }`);
      console.log(`[SalesService] Found ${validLots.length} valid lots in DB for this query`);

      console.log(`[SalesService] Medicine: ${medicine.nom} (${medicine._id})`);
      console.log(`[SalesService] Found ${validLots.length} valid lots`);
      validLots.forEach(l => console.log(` - Lot ${l.numeroLot}: ${l.quantite} (Exp: ${l.dateExpiration})`));

      let remainingQuantityToDeduct = item.quantity;

      // Verify if total stock across valid lots is enough
      const totalAvailable = validLots.reduce((acc, lot) => acc + lot.quantite, 0);
      console.log(`[SalesService] Total available: ${totalAvailable}, Requested: ${remainingQuantityToDeduct}`);

      if (totalAvailable < remainingQuantityToDeduct) {
        throw new BadRequestException(`Stock insuffisant pour "${medicine.nom}". Disponible : ${totalAvailable}, demandé : ${remainingQuantityToDeduct}.`);
      }

      // Deduct from lots
      for (const lot of validLots) {
        if (remainingQuantityToDeduct <= 0) break;

        const quantityToDeductFromThisLot = Math.min(lot.quantite, remainingQuantityToDeduct);
        lot.quantite -= quantityToDeductFromThisLot;
        await lot.save();

        saleItems.push({
          medicine: medicine._id as any,
          lot: lot._id as any,
          quantite: quantityToDeductFromThisLot,
          prixUnitaire: medicine.prixVente,
        });

        totalAmount += medicine.prixVente * quantityToDeductFromThisLot;
        remainingQuantityToDeduct -= quantityToDeductFromThisLot;
      }

      // Check for low stock alert after deduction
      const remainingTotalStock = await this.lotModel.find({
        medicine: medicine._id as any,
        quantite: { $gt: 0 }
      }).then(lots => lots.reduce((acc, l) => acc + l.quantite, 0));

      if (remainingTotalStock <= medicine.seuilAlerte) {
        await this.alertsService.create({
          type: 'stock_bas',
          medicine: medicine._id as any,
          valeur: `Quantité restante: ${remainingTotalStock} (Seuil: ${medicine.seuilAlerte})`
        });
      }
    }

    const sale = new this.saleModel({
      items: saleItems,
      total: parseFloat(totalAmount.toFixed(2)),
      caissierRef: caissierId,
    });
    const savedSale = await sale.save();

    // Log Activity
    await this.activityLogsService.create({
      user: caissierId as any,
      action: 'VENTE',
      details: `Vente #${savedSale._id} d'un montant de ${totalAmount} FCFA`
    });

    return savedSale;
  }

  async findAll(query: any): Promise<SaleDocument[]> {
    return this.saleModel.find(query)
      .populate('items.medicine', 'nom categorie')
      .populate('caissierRef', 'username role')
      .sort({ createdAt: -1 })
      .exec();
  }
}
