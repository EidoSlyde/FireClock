import {
  Body,
  Controller,
  Get,
  Inject,
  Param,
  ParseIntPipe,
  Post,
} from '@nestjs/common';
import { CreateQuotaDto } from './quota.dto';
import { Quota } from './quota.entity';
import { QuotaService } from './quota.service';

@Controller('quota')
export class QuotaController {
  @Inject(QuotaService)
  private readonly service: QuotaService;

  @Get(':id')
  public getQuota(@Param('id', ParseIntPipe) id: number): Promise<Quota> {
    return this.service.getQuota(id);
  }

  @Post()
  public createQuota(@Body() body: CreateQuotaDto): Promise<Quota> {
    return this.service.createQuota(body);
  }
}
