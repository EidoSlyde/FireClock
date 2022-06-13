import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from './user.dto';
import { User } from './user.entity';
import * as bcrypt from 'bcrypt';

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
    user.hashed_password = hashPassword(body.password);

    return this.repository.save(user);
  }

  public async deleteUser(id: number): Promise<User> {
    return this.repository.remove(await this.getUser(id));
  }

  public async login(username: string, password: string): Promise<User> {
    const user: User = await this.repository.findOne({ where: { username } });

    if (!user) throw new HttpException('User not found', 400);
    if (!(await bcrypt.compare(password, user.hashed_password)))
      throw new HttpException('Invalid password', 400);

    return user;
  }
}

function hashPassword(password: string): any {
  return bcrypt.hashSync(password, bcrypt.genSaltSync(8));
}
