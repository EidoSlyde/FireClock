import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Activity {
  @PrimaryGeneratedColumn()
  public activity_id!: number;

  @Column({ type: 'int' })
  public task_id: number;

  @Column({ type: 'timestamp' })
  public start_date: Date;

  @Column({ type: 'timestamp' })
  public end_date: Date;

  @Column({ type: 'boolean', default: false })
  public isDeleted: boolean;
}
