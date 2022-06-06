import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateQuotaDto } from './quota.dto';
import { Quota } from './quota.entity';

@Injectable()
export class QuotaService {
  @InjectRepository(Quota)
  private readonly repository: Repository<Quota>;

  public getQuota(id: number): Promise<Quota> {
    return this.repository.findOne({ where: { quota_id: id } });
  }

  public createQuota(body: CreateQuotaDto): Promise<Quota> {
    const quota: Quota = new Quota();

    quota.task_id = body.task_id;
    quota.duration = body.duration;

    return this.repository.save(quota);
  }

  public updateQuota(id: number, body: CreateQuotaDto): Promise<Quota> {
    const quota: Quota = new Quota();

    quota.quota_id = id;
    quota.task_id = body.task_id;
    quota.duration = body.duration;

    return this.repository.save(quota);
  }

  public async deleteQuota(id: number): Promise<Quota> {
    return this.repository.remove(await this.getQuota(id));
  }
}
