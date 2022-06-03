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

    activity.task_id = body.task_id;
    activity.start_date = body.start_date;
    activity.duration = body.duration;

    return this.repository.save(activity);
  }

  public updateActivity(
    id: number,
    body: CreateActivityDto,
  ): Promise<Activity> {
    const activity: Activity = new Activity();

    activity.activity_id = id;
    activity.task_id = body.task_id;
    activity.start_date = body.start_date;
    activity.duration = body.duration;

    return this.repository.save(activity);
  }

  public deleteActivity(id: number): Promise<Activity> {
    return this.repository.delete({ activity_id: id });
  }
}
