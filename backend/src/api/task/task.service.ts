import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { CreateTaskDto, UpdateTaskDto } from './task.dto';
import { Task } from './task.entity';

@Injectable()
export class TaskService {
  @InjectRepository(Task)
  private readonly repository: Repository<Task>;

  public async getTask(id: number): Promise<Task> {
    const children = await this.repository.find({ where: { parent: id } });
    const t = await this.repository.findOne({ where: { task_id: id } });
    t.children = await Promise.all(
      children.map((c) => this.getTask(c.task_id)),
    );
    return t;
  }

  public async getTasksOfUser(user_id: number): Promise<Task[]> {
    const ts = await this.repository.find({
      where: { user_id, parent: IsNull() },
    });
    return Promise.all(ts.map((t) => this.getTask(t.task_id)));
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
