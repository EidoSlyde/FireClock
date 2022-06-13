import {
  IsDate,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateActivityDto {
  @IsNotEmpty()
  public task_id: number;
  @IsNotEmpty()
  public start_date: Date;
  @IsNotEmpty()
  public end_date: Date;
}

export class UpdateActivityDto {
  @IsOptional()
  public task_id?: number;
  @IsOptional()
  public start_date?: Date;
  @IsOptional()
  public end_date?: Date;
}
