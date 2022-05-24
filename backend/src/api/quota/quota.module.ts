import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuotaController } from './quota.controller';
import { Quota } from './quota.entity';
import { QuotaService } from './quota.service';

@Module({
  imports: [TypeOrmModule.forFeature([Quota])],
  controllers: [QuotaController],
  providers: [QuotaService],
})
export class QuotaModule {}
