import { IsNotEmpty, IsString } from 'class-validator';

export class CreateActivityDto {
  @IsString()
  @IsNotEmpty()
  public task_id: number;
  public start_date: Date;
  public duration: string;
}
