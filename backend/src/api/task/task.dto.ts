import {
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateTaskDto {
  @IsString()
  @IsNotEmpty()
  public name: string;
  @IsNotEmpty()
  public user_id: number;
}

export class UpdateTaskDto {
  @IsString()
  @IsOptional()
  name?: string;
  @IsOptional()
  quota?: number;
  @IsString()
  @IsOptional()
  quotaInterval?: string;
  @IsOptional()
  parent?: number | 'noparent';
}
