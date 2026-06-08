import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateTicketTypeDto {
  @IsNumber()
  @IsNotEmpty()
    event_id!: number;

  @IsString()
  @IsNotEmpty()
    name!: string;

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

  @IsNumber()
  @IsNotEmpty()
    price!: number;

  @IsNotEmpty()
  @IsNumber()
  stock_remaining?: number;

  @IsOptional()
  @IsNumber()
  max_per_order?: number;

  @IsNumber()
    sort_order!: number;
}