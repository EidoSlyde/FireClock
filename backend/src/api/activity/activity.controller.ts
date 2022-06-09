import {
  Body,
  Controller,
  Get,
  Inject,
  Param,
  ParseIntPipe,
  Post,
} from '@nestjs/common';
import { CreateActivityDto } from './activity.dto';
import { Activity } from './activity.entity';
import { ActivityService } from './activity.service';

@Controller('activity')
export class ActivityController {
  @Inject(ActivityService)
  private readonly service: ActivityService;

  @Get(':id')
  public getActivity(@Param('id', ParseIntPipe) id: number): Promise<Activity> {
    return this.service.getActivity(id);
  }

  @Post()
  public createActivity(@Body() body: CreateActivityDto): Promise<Activity> {
    return this.service.createActivity(body);
  }

  @Post()
  public updateActivity(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: CreateActivityDto,
  ): Promise<Activity> {
    return this.service.updateActivity(id, body);
  }

  @Post()
  public deleteActivity(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<Activity> {
    return this.service.deleteActivity(id);
  }

  @Post()
  public getActivityTotalTime(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<Activity> {
    return this.service.getActivityTotalTime(id);
  }

  @Post()
  public getActivityTotalTimeInInterval(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: any,
  ): Promise<number> {
    return this.service.getActivityTotalTimeInInterval(
      id,
      body.start,
      body.end,
    );
  }
}
