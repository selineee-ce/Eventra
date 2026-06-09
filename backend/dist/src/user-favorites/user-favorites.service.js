"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FavoritesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let FavoritesService = class FavoritesService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(dto) {
        return this.prisma.user_favorites.create({
            data: {
                user_id: 1,
                favorite_type: dto.favorite_type,
                item_id: dto.item_id,
            },
        });
    }
    async findAll(userId = 1) {
        const favorites = await this.prisma.user_favorites.findMany({
            where: { user_id: userId },
            orderBy: { created_at: 'desc' },
        });
        const eventIds = favorites
            .filter((favorite) => favorite.favorite_type === 'event')
            .map((favorite) => favorite.item_id);
        if (eventIds.length === 0) {
            return [];
        }
        const events = await this.prisma.events.findMany({
            where: { id: { in: eventIds } },
            orderBy: { sort_order: 'asc' },
        });
        return events.map((event) => ({
            id: event.id,
            title: event.title,
            subtitle: event.venue,
            price: event.price,
            image: event.image,
            date: event.date_label,
            place: event.venue,
            city: event.city,
            artist_name: event.lineup || event.title,
            type: 'event',
        }));
    }
    async findOne(id) {
        const favorite = await this.prisma.user_favorites.findUnique({
            where: { id },
        });
        if (!favorite) {
            throw new common_1.NotFoundException('Favorite not found');
        }
        return favorite;
    }
    async update(id, dto) {
        return this.prisma.user_favorites.update({
            where: { id },
            data: dto,
        });
    }
    async remove(id) {
        return this.prisma.user_favorites.delete({
            where: { id },
        });
    }
};
exports.FavoritesService = FavoritesService;
exports.FavoritesService = FavoritesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FavoritesService);
//# sourceMappingURL=user-favorites.service.js.map