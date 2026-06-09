"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserFavoritesModule = void 0;
const common_1 = require("@nestjs/common");
const user_favorites_service_1 = require("./user-favorites.service");
const user_favorites_controller_1 = require("./user-favorites.controller");
const prisma_module_1 = require("../prisma/prisma.module");
let UserFavoritesModule = class UserFavoritesModule {
};
exports.UserFavoritesModule = UserFavoritesModule;
exports.UserFavoritesModule = UserFavoritesModule = __decorate([
    (0, common_1.Module)({
        imports: [prisma_module_1.PrismaModule],
        controllers: [user_favorites_controller_1.FavoritesController],
        providers: [user_favorites_service_1.FavoritesService],
    })
], UserFavoritesModule);
//# sourceMappingURL=user-favorites.module.js.map