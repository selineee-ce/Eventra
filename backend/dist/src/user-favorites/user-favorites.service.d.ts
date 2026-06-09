import { PrismaService } from '../prisma/prisma.service';
import { CreateFavoriteDto } from './dto/create-user-favorite.dto';
import { UpdateFavoriteDto } from './dto/update-user-favorite.dto';
export declare class FavoritesService {
    private prisma;
    constructor(prisma: PrismaService);
    create(dto: CreateFavoriteDto): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    findAll(userId?: number): Promise<{
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
    }[]>;
    findOne(id: number): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    update(id: number, dto: UpdateFavoriteDto): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
    remove(id: number): Promise<{
        id: number;
        created_at: Date;
        user_id: number;
        favorite_type: import("@prisma/client").$Enums.user_favorites_favorite_type;
        item_id: number;
    }>;
}
