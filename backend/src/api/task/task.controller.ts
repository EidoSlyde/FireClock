import {
  Body,
  Controller,
  Get,
  Inject,
  Param,
  ParseIntPipe,
  Post,
} from '@nestjs/common';
import { CreateTaskDto } from './task.dto';
import { Task } from './task.entity';
import { TaskService } from './task.service';

@Controller('task')
export class TaskController {
  @Inject(TaskService)
  private readonly service: TaskService;

  @Get(':id')
  public getTask(@Param('id', ParseIntPipe) id: number): Promise<Task> {
    return this.service.getTask(id);
  }

  @Post()
  public createTask(@Body() body: CreateTaskDto): Promise<Task> {
    return this.service.createTask(body);
  }
}
