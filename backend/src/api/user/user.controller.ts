import {
  Body,
  Controller,
  Delete,
  Get,
  Inject,
  Param,
  ParseIntPipe,
  Post,
} from '@nestjs/common';
import { CreateUserDto } from './user.dto';
import { User } from './user.entity';
import { UserService } from './user.service';

@Controller('user')
export class UserController {
  @Inject(UserService)
  private readonly service: UserService;

  @Get(':id')
  public getUser(@Param('id', ParseIntPipe) id: number): Promise<User> {
    return this.service.getUser(id);
  }

  @Post()
  public createUser(@Body() body: CreateUserDto): Promise<User> {
    return this.service.createUser(body);
  }

  @Delete(':id')
  public deleteUser(@Param('id', ParseIntPipe) id: number): Promise<User> {
    return this.service.deleteUser(id);
  }

  @Post('login')
  public login(@Body() body: any): Promise<User> {
    return this.service.login(body.username, body.password);
  }
}
