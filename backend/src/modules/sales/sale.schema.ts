import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SaleDocument = Sale & Document;

@Schema({ _id: false })
export class SaleItem {
  @Prop({ type: Types.ObjectId, ref: 'Medicine', required: true })
  medicine: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Lot' }) // Optional, to trace which lots were touched specifically
  lot: Types.ObjectId;

  @Prop({ required: true, min: 1 })
  quantite: number;

  @Prop({ required: true, min: 0 })
  prixUnitaire: number;
}
export const SaleItemSchema = SchemaFactory.createForClass(SaleItem);

@Schema({ timestamps: true })
export class Sale {
  @Prop({ type: [SaleItemSchema], required: true, validate: (v: any) => Array.isArray(v) && v.length > 0 })
  items: SaleItem[];

  @Prop({ required: true, min: 0 })
  total: number;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  caissierRef: Types.ObjectId;

  @Prop({ default: Date.now })
  horodatage: Date;

  @Prop({ enum: ['valide', 'annule'], default: 'valide' })
  statut: string;
}

export const SaleSchema = SchemaFactory.createForClass(Sale);
