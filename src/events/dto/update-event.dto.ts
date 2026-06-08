import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdateEventDto {
  @IsOptional()
  @IsNumber()
  user_id?: number;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  lineup?: string;

  @IsOptional()
  @IsString()
  venue?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  date_label?: string;

  @IsOptional()
  @IsString()
  show_time?: string;

  @IsOptional()
  @IsString()
  price?: string;

  @IsOptional()
  @IsString()
  image?: string;

  @IsOptional()
  @IsString()
  detail_image?: string;

  @IsOptional()
  @IsString()
  venue_layout?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  source_url?: string;

  @IsOptional()
  @IsString()
  tag1?: string;

  @IsOptional()
  @IsString()
  tag2?: string;

  @IsOptional()
  @IsString()
  button?: string;

  @IsOptional()
  @IsBoolean()
  is_featured?: boolean;

  @IsOptional()
  @IsBoolean()
  is_limited?: boolean;

  @IsOptional()
  @IsNumber()
  remaining_seats?: number;

  @IsOptional()
  @IsNumber()
  sort_order?: number;

  @IsOptional()
  @IsBoolean()
  is_favorite?: boolean;
}