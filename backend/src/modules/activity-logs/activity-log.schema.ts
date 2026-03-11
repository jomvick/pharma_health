import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types, Schema as MongooseSchema } from 'mongoose';

export type ActivityLogDocument = ActivityLog & Document;

@Schema({ timestamps: true })
export class ActivityLog {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user: Types.ObjectId;

  @Prop({ required: true })
  action: string; // e.g., 'CREATE_SALE', 'DELETE_MEDICINE'

  @Prop({ required: true })
  entity: string; // e.g., 'Sale', 'Medicine'

  @Prop({ type: Types.ObjectId })
  entityId: Types.ObjectId;

  @Prop({ type: MongooseSchema.Types.Mixed })
  details: any; // Extra info about the action

  @Prop()
  ipAddress: string;
}

export const ActivityLogSchema = SchemaFactory.createForClass(ActivityLog);
