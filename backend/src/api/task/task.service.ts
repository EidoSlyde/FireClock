import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateTaskDto, UpdateTaskDto } from './task.dto';
import { Task } from './task.entity';

@Injectable()
export class TaskService {
  @InjectRepository(Task)
  private readonly repository: Repository<Task>;

  public getTask(id: number): Promise<Task> {
    return this.repository.findOne({ where: { task_id: id } });
  }

  public getTasksOfUser(user_id: number): Promise<Task[]> {
    return this.repository.find({ where: { user_id } });
  }

  public createTask(body: CreateTaskDto): Promise<Task> {
    const task: Task = new Task();

    task.name = body.name;
    task.user_id = body.user_id;

    return this.repository.save(task);
  }

  public async updateTask(id: number, body: UpdateTaskDto): Promise<Task> {
    const task: Task = await this.repository.findOne({
      where: { task_id: id },
    });
    console.log(body);
    if (!!body.name) task.name = body.name;
    if (!!body.parent)
      task.parent = body.parent == 'noparent' ? null : body.parent;
    if (!!body.quota) task.quota = body.quota;
    if (!!body.quotaInterval) task.quotaInterval = body.quotaInterval;
    return this.repository.save(task);
  }

  public async deleteTask(id: number): Promise<Task> {
    return this.repository.remove(await this.getTask(id));
  }
}
