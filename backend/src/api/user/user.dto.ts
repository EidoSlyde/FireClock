import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  public username: string;
  public hashed_password: string;

  @IsEmail()
  public email: string;
}
