import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateActivityDto, UpdateActivityDto } from './activity.dto';
import { Activity } from './activity.entity';

@Injectable()
export class ActivityService {
  getActivitiesOfTask(id: number): Promise<Activity[]> {
    return this.repository.find({ where: { task_id: id } });
  }
  @InjectRepository(Activity)
  private readonly repository: Repository<Activity>;

  public getActivity(id: number): Promise<Activity> {
    return this.repository.findOne({ where: { activity_id: id } });
  }

  public getActivityTotalTime(id: number): Promise<Activity> {
    return this.repository.query(
      `SELECT SUM(duration) FROM activity WHERE task_id = ${id}`,
    );
  }

  public getActivityTotalTimeInInterval(
    id: number,
    start: string,
    end: string,
  ): Promise<number> {
    return this.repository.query(
      `SELECT SUM(duration) FROM activity WHERE task_id = ${id} AND start_date BETWEEN '${start}' AND '${end}'`,
    );
  }

  public createActivity(body: CreateActivityDto): Promise<Activity> {
    const activity: Activity = new Activity();

    activity.task_id = body.task_id;
    activity.start_date = body.start_date;
    activity.end_date = body.end_date;

    return this.repository.save(activity);
  }

  public async updateActivity(
    id: number,
    body: UpdateActivityDto,
  ): Promise<Activity> {
    const activity: Activity = await this.repository.findOne({
      where: { activity_id: id },
    });

    if (!!body.task_id) activity.task_id = body.task_id;
    if (!!body.start_date) activity.start_date = body.start_date;
    if (!!body.end_date) activity.end_date = body.end_date;

    console.log(body);

    return this.repository.save(activity);
  }

  public async deleteActivity(id: number): Promise<Activity> {
    return this.repository.remove(await this.getActivity(id));
  }
}
