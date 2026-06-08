import { IsNumber, IsString } from 'class-validator';

export class CreateNotificationDto {
  @IsString()
    title!: string;

  @IsString()
    subtitle!: string;

  @IsNumber()
    sort_order!: number;
}