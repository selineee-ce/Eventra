import {
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class UpdateTicketDto {
  @IsOptional()
  @IsNumber()
  user_id?: number;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  image?: string;

  @IsOptional()
  @IsString()
  date_label?: string;

  @IsOptional()
  @IsString()
  time_label?: string;

  @IsOptional()
  @IsString()
  venue?: string;

  @IsOptional()
  @IsString()
  section?: string;

  @IsOptional()
  @IsString()
  row_label?: string;

  @IsOptional()
  @IsString()
  seat_label?: string;

  @IsOptional()
  @IsString()
  qr_data?: string;

  @IsOptional()
  @IsString()
  ticket_type?: string;

  @IsOptional()
  @IsString()
  ticket_status?: string;

  @IsOptional()
  @IsNumber()
  sort_order?: number;
}