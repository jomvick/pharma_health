import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ActivityLog, ActivityLogDocument } from './activity-log.schema';

@Injectable()
export class ActivityLogsService {
  constructor(@InjectModel(ActivityLog.name) private activityLogModel: Model<ActivityLogDocument>) {}

  async create(data: Partial<ActivityLog>): Promise<ActivityLogDocument> {
    const log = new this.activityLogModel(data);
    return log.save();
  }

  async findAll(page: number = 1, limit: number = 50): Promise<{ data: ActivityLogDocument[]; total: number }> {
    const skip = (page - 1) * limit;
    const total = await this.activityLogModel.countDocuments();
    const data = await this.activityLogModel.find().populate('user', 'username email').sort({ createdAt: -1 }).skip(skip).limit(limit).exec();
    return { data, total };
  }
}
