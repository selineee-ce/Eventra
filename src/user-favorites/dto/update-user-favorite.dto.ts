import { IsEnum, IsNumber, IsOptional } from 'class-validator';
import { user_favorites_favorite_type } from '@prisma/client';

export class UpdateFavoriteDto {
  @IsOptional()
  @IsEnum(user_favorites_favorite_type)
  favorite_type?: user_favorites_favorite_type;

  @IsOptional()
  @IsNumber()
  item_id?: number;
}