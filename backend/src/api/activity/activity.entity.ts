import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Activity {
  @PrimaryGeneratedColumn()
  public activity_id!: number;

  @Column({ type: 'uuid' })
  public task_id: number;

  @Column({ type: 'timestamp' })
  public start_date: Date;

  @Column({ type: 'varchar', length: 120 })
  public duration: string;

  @Column({ type: 'boolean', default: false })
  public isDeleted: boolean;
}
