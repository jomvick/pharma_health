import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AlertDocument = Alert & Document;

@Schema({ timestamps: true })
export class Alert {
  @Prop({ required: true, enum: ['stock_bas', 'expiration'] })
  type: string;

  @Prop({ type: Types.ObjectId, ref: 'Medicine', required: true })
  medicine: Types.ObjectId;

  @Prop({ required: true })
  valeur: string; // e.g., '5 left', or 'Expires in 10 days'

  @Prop({ default: false })
  lu: boolean;
}

export const AlertSchema = SchemaFactory.createForClass(Alert);
