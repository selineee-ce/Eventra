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
exports.MobileApiController = void 0;
const common_1 = require("@nestjs/common");
const mobile_api_service_1 = require("./mobile-api.service");
let MobileApiController = class MobileApiController {
    mobileApiService;
    constructor(mobileApiService) {
        this.mobileApiService = mobileApiService;
    }
    health() {
        return { ok: true };
    }
    featuredEvents(userId) {
        return this.mobileApiService.featuredEvents(this.parseUserId(userId));
    }
    nearbyEvents(userId, location) {
        return this.mobileApiService.nearbyEvents(this.parseUserId(userId), location);
    }
    passes() {
        return { data: [] };
    }
    exclusiveDrops() {
        return this.mobileApiService.exclusiveDrops();
    }
    ticketTypes(id) {
        return this.mobileApiService.ticketTypes(Number(id));
    }
    eventDetail(id) {
        return this.mobileApiService.eventDetail(Number(id));
    }
    profile(userId) {
        return this.mobileApiService.profile(this.parseUserId(userId));
    }
    updateProfile(userId, body) {
        return this.mobileApiService.updateProfile(this.parseUserId(userId), body);
    }
    appConfig() {
        return this.mobileApiService.appConfig();
    }
    cities() {
        return this.mobileApiService.cities();
    }
    artists() {
        return this.mobileApiService.artists();
    }
    setEventFavorite(userId, id, body) {
        return this.mobileApiService.setEventFavorite(this.parseUserId(userId), Number(id), Boolean(body?.isFavorite));
    }
    setArtistFavorite(userId, id, body) {
        return this.mobileApiService.setArtistFavorite(this.parseUserId(userId), Number(id), Boolean(body?.isFavorite));
    }
    setPassFavorite() {
        return { ok: true };
    }
    checkout(userId, body) {
        return this.mobileApiService.checkout(this.parseUserId(userId), body);
    }
    parseUserId(value) {
        const userId = Number(value);
        return Number.isInteger(userId) && userId > 0 ? userId : undefined;
    }
};
exports.MobileApiController = MobileApiController;
__decorate([
    (0, common_1.Get)('health'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "health", null);
__decorate([
    (0, common_1.Get)('home/featured-events'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "featuredEvents", null);
__decorate([
    (0, common_1.Get)('home/nearby-events'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __param(1, (0, common_1.Query)('location')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "nearbyEvents", null);
__decorate([
    (0, common_1.Get)('home/passes'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "passes", null);
__decorate([
    (0, common_1.Get)('home/exclusive-drops'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "exclusiveDrops", null);
__decorate([
    (0, common_1.Get)('nearby-events/:id/ticket-types'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "ticketTypes", null);
__decorate([
    (0, common_1.Get)('nearby-events/:id/detail'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "eventDetail", null);
__decorate([
    (0, common_1.Get)('profile'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "profile", null);
__decorate([
    (0, common_1.Post)('profile/update'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "updateProfile", null);
__decorate([
    (0, common_1.Get)('app-config'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "appConfig", null);
__decorate([
    (0, common_1.Get)('cities'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "cities", null);
__decorate([
    (0, common_1.Get)('artists'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "artists", null);
__decorate([
    (0, common_1.Post)('nearby-events/:id/favorite'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "setEventFavorite", null);
__decorate([
    (0, common_1.Post)('artists/:id/favorite'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "setArtistFavorite", null);
__decorate([
    (0, common_1.Post)('passes/:id/favorite'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "setPassFavorite", null);
__decorate([
    (0, common_1.Post)('payments/checkout'),
    __param(0, (0, common_1.Headers)('x-user-id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", void 0)
], MobileApiController.prototype, "checkout", null);
exports.MobileApiController = MobileApiController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [mobile_api_service_1.MobileApiService])
], MobileApiController);
//# sourceMappingURL=mobile-api.controller.js.map