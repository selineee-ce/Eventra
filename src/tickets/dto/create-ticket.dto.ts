import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateTicketDto {
  @IsOptional()
  @IsNumber()
  user_id?: number;

  @IsString()
    title!: string;

  @IsString()
    image!: string;

  @IsString()
    date_label!: string;

  @IsString()
    time_label!: string;

  @IsString()
    venue!: string;

  @IsString()
    section!: string;

  @IsString()
    row_label!: string;

  @IsString()
    seat_label!: string;

  @IsString()
    qr_data!: string;

  @IsString()
    ticket_type!: string;

  @IsOptional()
  @IsString()
  ticket_status?: string;

  @IsNumber()
    sort_order!: number;
}