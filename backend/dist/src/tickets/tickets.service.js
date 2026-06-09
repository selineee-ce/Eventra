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
exports.TicketsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let TicketsService = class TicketsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(dto) {
        return this.prisma.tickets.create({
            data: dto,
        });
    }
    async findAll(userId) {
        return this.prisma.tickets.findMany({
            where: userId ? { user_id: userId } : undefined,
            include: {
                users: true,
            },
            orderBy: {
                sort_order: 'asc',
            },
        });
    }
    async findOne(id) {
        const ticket = await this.prisma.tickets.findUnique({
            where: { id },
            include: {
                users: true,
            },
        });
        if (!ticket) {
            throw new common_1.NotFoundException('Ticket not found');
        }
        return ticket;
    }
    async update(id, dto) {
        return this.prisma.tickets.update({
            where: { id },
            data: dto,
        });
    }
    async remove(id) {
        return this.prisma.tickets.delete({
            where: { id },
        });
    }
};
exports.TicketsService = TicketsService;
exports.TicketsService = TicketsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], TicketsService);
//# sourceMappingURL=tickets.service.js.map