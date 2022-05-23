import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from './user.dto';
import { User } from './user.entity';

@Injectable()
export class UserService {
  @InjectRepository(User)
  private readonly repository: Repository<User>;

  public getUser(id: number): Promise<User> {
    return this.repository.findOne({ where: { user_id: id } });
  }

  public createUser(body: CreateUserDto): Promise<User> {
    const user: User = new User();

    user.username = body.username;
    user.email = body.email;
    user.hashed_password = hashPassword(body.hashed_password);

    return this.repository.save(user);
  }
}

function hashPassword(password: string): any {
  return 'lol';
}
