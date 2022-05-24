import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity()
export class Task {
  @PrimaryGeneratedColumn()
  public task_id!: number;

  @Column({ type: 'number' })
  public user_id: number;

  @Column({ type: 'number' })
  public parent: number;

  @Column({ type: 'varchar', length: 120 })
  public name: string;

  @Column({ type: 'boolean', default: false })
  public isDeleted: boolean;

  /*
   * Create and Update Date Columns
   */

  @CreateDateColumn({ type: 'timestamp' })
  public createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  public updatedAt!: Date;
}
