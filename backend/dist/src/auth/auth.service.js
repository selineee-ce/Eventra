"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcrypt"));
let AuthService = class AuthService {
    prisma;
    jwtService;
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
    }
    async register(dto) {
        const existingUser = await this.prisma.users.findUnique({
            where: { email: dto.email },
        });
        if (existingUser) {
            throw new common_1.BadRequestException('Email already exists');
        }
        if (dto.confirmPassword && dto.password !== dto.confirmPassword) {
            throw new common_1.BadRequestException('Password and confirm password must match.');
        }
        const hashedPassword = await bcrypt.hash(dto.password, 10);
        const user = await this.prisma.users.create({
            data: {
                username: dto.username,
                name: dto.username,
                email: dto.email,
                phone: dto.phone || null,
                location: dto.location || 'Set your location',
                password_hash: hashedPassword,
                role: this.getUserRole(dto.email, dto.username),
            },
        });
        const payload = {
            sub: user.id,
            email: user.email,
            role: user.role,
        };
        return {
            message: 'Register success',
            access_token: this.jwtService.sign(payload),
            user: {
                id: user.id,
                username: user.username,
                name: user.name,
                email: user.email,
                phone: user.phone,
                location: user.location,
                avatar_url: user.avatar_url,
                followers_count: user.followers_count,
                upcoming_events_count: user.upcoming_events_count,
                description: user.description,
                role: user.role,
                is_verified: user.is_verified,
            },
        };
    }
    async login(dto) {
        const identifier = dto.identifier || dto.email;
        if (!identifier) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const user = await this.prisma.users.findFirst({
            where: {
                OR: [
                    { email: identifier },
                    { username: identifier },
                    { phone: identifier },
                ],
            },
        });
        if (!user)
            throw new common_1.UnauthorizedException('Invalid credentials');
        const isMatch = await bcrypt.compare(dto.password, user.password_hash);
        if (!isMatch)
            throw new common_1.UnauthorizedException('Invalid credentials');
        const payload = {
            sub: user.id,
            email: user.email,
            role: user.role,
        };
        return {
            message: 'Login success',
            access_token: this.jwtService.sign(payload),
            user: {
                id: user.id,
                username: user.username,
                name: user.name,
                email: user.email,
                phone: user.phone,
                location: user.location,
                avatar_url: user.avatar_url,
                followers_count: user.followers_count,
                upcoming_events_count: user.upcoming_events_count,
                description: user.description,
                role: user.role,
                is_verified: user.is_verified,
            },
        };
    }
    getUserRole(email, username) {
        if (username.toLowerCase().includes('admin') ||
            email.toLowerCase().includes('admin')) {
            return 'ADMIN';
        }
        return 'CUSTOMER';
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map