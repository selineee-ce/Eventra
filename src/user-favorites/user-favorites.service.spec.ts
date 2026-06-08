import { Test, TestingModule } from '@nestjs/testing';
import { UserFavoritesService } from './user-favorites.service';

describe('UserFavoritesService', () => {
  let service: UserFavoritesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserFavoritesService],
    }).compile();

    service = module.get<UserFavoritesService>(UserFavoritesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
