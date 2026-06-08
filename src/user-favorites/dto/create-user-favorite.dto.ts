import { IsEnum, IsNumber } from 'class-validator';
import { user_favorites_favorite_type } from '@prisma/client';

export class CreateFavoriteDto {
  @IsEnum(user_favorites_favorite_type)
    favorite_type!: user_favorites_favorite_type;

  @IsNumber()
    item_id!: number;
}