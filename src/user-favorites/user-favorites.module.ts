import { Module } from '@nestjs/common';
import { FavoritesService } from './user-favorites.service';
import { FavoritesController } from './user-favorites.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [FavoritesController],
  providers: [FavoritesService],
})
export class UserFavoritesModule {}
