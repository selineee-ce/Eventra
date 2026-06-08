import { IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdateTicketTypeDto {
  @IsOptional()
  @IsNumber()
  event_id?: number;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  badge?: string;

  @IsOptional()
  @IsString()
  badge_color?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  bullet1?: string;

  @IsOptional()
  @IsString()
  bullet2?: string;

  @IsOptional()
  @IsString()
  bullet3?: string;

  @IsOptional()
  @IsNumber()
  price?: number;

  @IsOptional()
  @IsNumber()
  stock_remaining?: number;

  @IsOptional()
  @IsNumber()
  max_per_order?: number;

  @IsOptional()
  @IsNumber()
  sort_order?: number;
}