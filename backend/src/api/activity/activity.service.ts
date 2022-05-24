import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateActivityDto } from './activity.dto';
import { Activity } from './activity.entity';

@Injectable()
export class ActivityService {
  @InjectRepository(Activity)
  private readonly repository: Repository<Activity>;

  public getActivity(id: number): Promise<Activity> {
    return this.repository.findOne({ where: { activity_id: id } });
  }

  public createActivity(body: CreateActivityDto): Promise<Activity> {
    const activity: Activity = new Activity();

    activity.name = body.name;
    activity.user_id = body.user_id;
    activity.parent = body.parent;

    return this.repository.save(activity);
  }
}
