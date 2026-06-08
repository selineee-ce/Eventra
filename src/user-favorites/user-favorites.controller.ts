import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { FavoritesService } from './user-favorites.service';
import { CreateFavoriteDto } from './dto/create-user-favorite.dto';
import { UpdateFavoriteDto } from './dto/update-user-favorite.dto';

@Controller('favorites')
export class FavoritesController {
  constructor(
    private readonly favoritesService: FavoritesService,
  ) {}

  @Post()
  create(@Body() dto: CreateFavoriteDto) {
    return this.favoritesService.create(dto);
  }

  @Get()
  findAll() {
    return this.favoritesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.favoritesService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateFavoriteDto,
  ) {
    return this.favoritesService.update(
      +id,
      dto,
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.favoritesService.remove(+id);
  }
}
