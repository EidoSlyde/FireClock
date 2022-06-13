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

  @Column({ type: 'int' })
  public user_id: number;

  @Column({ type: 'int', nullable: true })
  public parent?: number;

  @Column({ type: 'varchar', length: 120 })
  public name: string;

  @Column({ type: 'int', default: 0 })
  public quota: number = 0;

  @Column({ type: 'varchar', length: 5, default: 'day' })
  public quotaInterval = 'day';

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
