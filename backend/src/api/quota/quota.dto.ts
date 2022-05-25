import { IsNotEmpty, IsString } from 'class-validator';

export class CreateQuotaDto {
  @IsString()
  @IsNotEmpty()
  public task_id: number;
  @IsString()
  @IsNotEmpty()
  public duration: string;
}
