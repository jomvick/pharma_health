import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type LotDocument = Lot & Document;

@Schema({ timestamps: true })
export class Lot {
  @Prop({ type: Types.ObjectId, ref: 'Medicine', required: true })
  medicine: Types.ObjectId;

  @Prop({ required: true, trim: true })
  numeroLot: string;

  @Prop({ required: true, min: 0 })
  quantite: number;

  @Prop({ required: true })
  dateExpiration: Date;

  @Prop({ trim: true })
  fournisseur: string;

  @Prop()
  prixAchat: number;

  @Prop({ default: Date.now })
  dateEntree: Date;
}

export const LotSchema = SchemaFactory.createForClass(Lot);
