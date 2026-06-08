import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateFavoriteDto } from './dto/create-user-favorite.dto';
import { UpdateFavoriteDto } from './dto/update-user-favorite.dto';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateFavoriteDto) {
    return this.prisma.user_favorites.create({
      data: {
        user_id: 1,
        favorite_type: dto.favorite_type,
        item_id: dto.item_id,
      },
    });
  }

  async findAll() {
    return this.prisma.user_favorites.findMany({
      where: {
        user_id: 1,
      },
    });
  }

  async findOne(id: number) {
    const favorite =
      await this.prisma.user_favorites.findUnique({
        where: { id },
      });

    if (!favorite) {
      throw new NotFoundException(
        'Favorite not found',
      );
    }

    return favorite;
  }

  async update(
    id: number,
    dto: UpdateFavoriteDto,
  ) {
    return this.prisma.user_favorites.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.user_favorites.delete({
      where: { id },
    });
  }
}