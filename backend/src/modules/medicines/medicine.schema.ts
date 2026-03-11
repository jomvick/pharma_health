import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type MedicineDocument = Medicine & Document;

@Schema({ 
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
})
export class Medicine {
  @Prop({ required: true, trim: true })
  nom: string;

  @Prop({ trim: true })
  dci: string; // Dénomination Commune Internationale

  @Prop({ trim: true })
  forme: string; // e.g., 'Comprimé', 'Sirop'

  @Prop({ trim: true })
  dosage: string;

  @Prop({ required: true, trim: true, default: 'Général' })
  categorie: string;

  @Prop({ unique: true, sparse: true, trim: true })
  codeBarre: string;

  @Prop({ trim: true })
  fournisseur: string;

  @Prop({ required: true, min: 0 })
  prixVente: number;

  @Prop({ min: 0 })
  prixAchat: number;

  @Prop({ default: 10, min: 0 })
  seuilAlerte: number;

  @Prop({ default: null })
  deletedAt: Date; // Soft delete
}

export const MedicineSchema = SchemaFactory.createForClass(Medicine);

MedicineSchema.virtual('lots', {
  ref: 'Lot',
  localField: '_id',
  foreignField: 'medicine'
});
