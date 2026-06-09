import { FavoritesService } from './user-favorites.service';
import { CreateFavoriteDto } from './dto/create-user-favorite.dto';
import { UpdateFavoriteDto } from './dto/update-user-favorite.dto';
export declare class FavoritesController {
    private readonly favoritesService;
    constructor(favoritesService: FavoritesService);
    create(dto: CreateFavoriteDto): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    findAll(userId?: string): Promise<{
        data: {
            id: number;
            title: string;
            subtitle: string;
            price: string | null;
            image: string | null;
            date: string;
            place: string;
            city: string;
            artist_name: string;
            type: string;
        }[];
    }>;
    findOne(id: string): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    update(id: string, dto: UpdateFavoriteDto): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    remove(id: string): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
}
