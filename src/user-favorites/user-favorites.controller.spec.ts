import { Test, TestingModule } from '@nestjs/testing';
import { UserFavoritesController } from './user-favorites.controller';
import { UserFavoritesService } from './user-favorites.service';

describe('UserFavoritesController', () => {
  let controller: UserFavoritesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserFavoritesController],
      providers: [UserFavoritesService],
    }).compile();

    controller = module.get<UserFavoritesController>(UserFavoritesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
