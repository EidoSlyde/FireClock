import { IsNotEmpty, IsString } from 'class-validator';

export class CreateQuotaDto {
  @IsString()
  @IsNotEmpty()
  public name: string;
  public user_id: number;
  public parent: number;
}
