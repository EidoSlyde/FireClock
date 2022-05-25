import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  public username: string;
  @IsEmail()
  public email: string;
  @IsString()
  @IsNotEmpty()
  public password: string;
}
