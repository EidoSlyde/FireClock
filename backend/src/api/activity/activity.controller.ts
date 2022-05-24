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
}
