import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateEventDto {
  @ApiProperty()
    @IsString()
    title!: string;

  @ApiProperty()
    @IsString()
    venue!: string;

  @ApiProperty()
    @IsString()
    city!: string;

  @ApiProperty()
    @IsString()
    date_label!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  lineup?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  show_time?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  price?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  image?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  is_featured?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  remaining_seats?: number;
}