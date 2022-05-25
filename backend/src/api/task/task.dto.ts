import { IsNotEmpty, IsString } from 'class-validator';

export class CreateTaskDto {
  @IsString()
  @IsNotEmpty()
  public name: string;
  @IsString()
  @IsNotEmpty()
  public user_id: number;
  @IsString()
  @IsNotEmpty()
  public parent: number;
}
