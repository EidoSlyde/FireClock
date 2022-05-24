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

    quota.name = body.name;
    quota.user_id = body.user_id;
    quota.parent = body.parent;

    return this.repository.save(quota);
  }
}
