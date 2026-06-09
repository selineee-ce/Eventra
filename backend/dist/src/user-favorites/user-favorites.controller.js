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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FavoritesController = void 0;
const common_1 = require("@nestjs/common");
const user_favorites_service_1 = require("./user-favorites.service");
const create_user_favorite_dto_1 = require("./dto/create-user-favorite.dto");
const update_user_favorite_dto_1 = require("./dto/update-user-favorite.dto");
let FavoritesController = class FavoritesController {
    favoritesService;
    constructor(favoritesService) {
        this.favoritesService = favoritesService;
    }
    create(dto) {
        return this.favoritesService.create(dto);
    }
    async findAll(userId) {
        const data = await this.favoritesService.findAll(Number(userId) || undefined);
        return { data };
    }
    findOne(id) {
        return this.favoritesService.findOne(+id);
    }
    update(id, dto) {
        return this.favoritesService.update(+id, dto);
    }
    remove(id) {
        return this.favoritesService.remove(+id);
    }
};
exports.FavoritesController = FavoritesController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_user_favorite_dto_1.CreateFavoriteDto]),
    __metadata("design:returntype", void 0)
], FavoritesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], FavoritesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], FavoritesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_user_favorite_dto_1.UpdateFavoriteDto]),
    __metadata("design:returntype", void 0)
], FavoritesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], FavoritesController.prototype, "remove", null);
exports.FavoritesController = FavoritesController = __decorate([
    (0, common_1.Controller)('favorites'),
    __metadata("design:paramtypes", [user_favorites_service_1.FavoritesService])
], FavoritesController);
//# sourceMappingURL=user-favorites.controller.js.map