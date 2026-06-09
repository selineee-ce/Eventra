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
exports.MobileApiService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let MobileApiService = class MobileApiService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async featuredEvents(userId) {
        const events = await this.prisma.events.findMany({
            where: { is_featured: true },
            orderBy: { sort_order: 'asc' },
        });
        return { data: this.normalizeEvents(await this.withFavorite(events, userId)) };
    }
    async nearbyEvents(userId, location) {
        const city = this.normalizeCity(location);
        const events = await this.prisma.events.findMany({
            where: city ? { city: { equals: city } } : undefined,
            orderBy: { sort_order: 'asc' },
        });
        const data = this.normalizeEvents(await this.withFavorite(events, userId)).map((event) => ({
            ...event,
            date: event.date_label,
            place: event.venue,
            artist_name: event.lineup || event.title,
        }));
        return { data };
    }
    async exclusiveDrops() {
        const events = await this.prisma.events.findMany({
            where: { is_limited: true },
            orderBy: { sort_order: 'asc' },
            take: 3,
        });
        return {
            data: this.normalizeEvents(events).map((event, index) => ({
                id: event.id,
                title: event.title,
                badge: event.tag1 || 'EVENT',
                description: event.description || `Live at ${event.venue}, ${event.city}`,
                type: 'ticket',
                image: event.image,
                countdown_seconds: [9912, 45000, 75000][index] || 75000,
                sort_order: event.sort_order,
            })),
        };
    }
    async ticketTypes(eventId) {
        await this.ensureEvent(eventId);
        let tickets = await this.prisma.event_ticket_types.findMany({
            where: { event_id: eventId },
            orderBy: { sort_order: 'asc' },
        });
        if (tickets.length === 0) {
            await this.createDefaultTicketTypes(eventId);
            tickets = await this.prisma.event_ticket_types.findMany({
                where: { event_id: eventId },
                orderBy: { sort_order: 'asc' },
            });
        }
        return { data: tickets };
    }
    async eventDetail(eventId) {
        const event = await this.ensureEvent(eventId);
        return {
            data: {
                ...this.normalizeEvent(event),
                place: event.venue,
                artist_name: event.lineup || event.title,
            },
        };
    }
    async profile(userId) {
        const user = await this.ensureUser(userId);
        const { password_hash: _passwordHash, ...profile } = user;
        return { profile };
    }
    async updateProfile(userId, body) {
        const user = await this.ensureUser(userId);
        const data = this.pickProfileFields(body);
        if (Object.keys(data).length === 0) {
            throw new common_1.BadRequestException('No fields to update');
        }
        await this.prisma.users.update({
            where: { id: user.id },
            data,
        });
        return { ok: true };
    }
    async appConfig() {
        const rows = await this.prisma.app_config.findMany();
        const config = rows.reduce((result, row) => {
            result[row.config_key] = row.config_value;
            return result;
        }, {});
        return { config };
    }
    async cities() {
        const rows = await this.prisma.events.findMany({
            distinct: ['city'],
            select: { city: true },
            orderBy: { city: 'asc' },
        });
        return { data: rows.map((row) => row.city) };
    }
    async artists() {
        const artists = await this.prisma.users.findMany({
            where: { role: { in: ['PROMOTER', 'promoter', 'ADMIN', 'ARTIST', 'artist'] } },
            orderBy: { followers_count: 'desc' },
            take: 15,
        });
        const events = await this.prisma.events.findMany({ orderBy: { sort_order: 'asc' } });
        return {
            data: artists.map((artist) => ({
                id: artist.id,
                name: artist.name,
                username: artist.username,
                avatar_url: artist.avatar_url,
                imageUrl: artist.avatar_url,
                genre: artist.genre,
                description: artist.description,
                followers: artist.followers_count,
                followers_count: artist.followers_count,
                monthly_listeners: 0,
                events_count: artist.events_count,
                upcomingEvents: events
                    .filter((event) => event.user_id === artist.id || (event.lineup || '').toLowerCase().includes(artist.name.toLowerCase()))
                    .map((event) => ({
                    ...event,
                    event_id: event.id,
                    place: event.venue,
                    artist_name: event.lineup || event.title,
                })),
            })),
        };
    }
    async setEventFavorite(userId, eventId, isFavorite) {
        const user = await this.ensureUser(userId);
        await this.ensureEvent(eventId);
        if (isFavorite) {
            await this.prisma.user_favorites.upsert({
                where: {
                    user_id_favorite_type_item_id: {
                        user_id: user.id,
                        favorite_type: 'event',
                        item_id: eventId,
                    },
                },
                update: { created_at: new Date() },
                create: { user_id: user.id, favorite_type: 'event', item_id: eventId },
            });
        }
        else {
            await this.prisma.user_favorites.deleteMany({
                where: { user_id: user.id, favorite_type: 'event', item_id: eventId },
            });
        }
        return { ok: true };
    }
    async setArtistFavorite(userId, artistId, isFavorite) {
        const user = await this.ensureUser(userId);
        if (isFavorite) {
            await this.prisma.user_favorites.upsert({
                where: {
                    user_id_favorite_type_item_id: {
                        user_id: user.id,
                        favorite_type: 'artist',
                        item_id: artistId,
                    },
                },
                update: { created_at: new Date() },
                create: { user_id: user.id, favorite_type: 'artist', item_id: artistId },
            });
        }
        else {
            await this.prisma.user_favorites.deleteMany({
                where: { user_id: user.id, favorite_type: 'artist', item_id: artistId },
            });
        }
        return { ok: true };
    }
    async checkout(userId, body) {
        const user = await this.ensureUser(userId);
        const eventId = Number(body.eventId);
        const method = String(body.paymentMethod || '').toLowerCase();
        const items = Array.isArray(body.items) ? body.items : [];
        if (!eventId || !method || items.length === 0) {
            throw new common_1.BadRequestException('Event, payment method, and ticket items are required');
        }
        await this.ticketTypes(eventId);
        const event = await this.ensureEvent(eventId);
        const ticketIds = items.map((item) => Number(item.ticketTypeId)).filter(Boolean);
        const ticketTypes = await this.prisma.event_ticket_types.findMany({
            where: { event_id: eventId, id: { in: ticketIds } },
        });
        const ticketMap = new Map(ticketTypes.map((ticket) => [ticket.id, ticket]));
        let subtotal = 0;
        const normalizedItems = items.map((item) => {
            const ticketTypeId = Number(item.ticketTypeId);
            const quantity = Number(item.quantity);
            const ticket = ticketMap.get(ticketTypeId);
            if (!ticket || !Number.isInteger(quantity) || quantity < 1) {
                throw new common_1.BadRequestException('Invalid ticket selection');
            }
            if (quantity > ticket.stock_remaining) {
                throw new common_1.BadRequestException(`${ticket.name} only has ${ticket.stock_remaining} tickets left`);
            }
            if (ticket.max_per_order > 0 && quantity > ticket.max_per_order) {
                throw new common_1.BadRequestException(`${ticket.name} has a maximum purchase of ${ticket.max_per_order} tickets per order`);
            }
            subtotal += ticket.price * quantity;
            return { ticket, quantity };
        });
        const serviceFee = Math.round(subtotal * 0.035);
        const total = subtotal + serviceFee;
        const createdTickets = await this.prisma.$transaction(async (tx) => {
            const result = [];
            const lastTicket = await tx.tickets.findFirst({ orderBy: { id: 'desc' } });
            let nextSort = (lastTicket?.id || 0) + 1;
            for (const item of normalizedItems) {
                await tx.event_ticket_types.update({
                    where: { id: item.ticket.id },
                    data: { stock_remaining: { decrement: item.quantity } },
                });
                for (let index = 0; index < item.quantity; index += 1) {
                    const seatNumber = ((nextSort - 1) % 30) + 1;
                    const created = await tx.tickets.create({
                        data: {
                            user_id: user.id,
                            title: event.title,
                            image: this.normalizeImage(event.image) || '',
                            date_label: event.date_label,
                            time_label: event.show_time || '19:00 WIB',
                            venue: event.venue,
                            section: item.ticket.name,
                            row_label: `Row ${String.fromCharCode(65 + ((nextSort - 1) % 6))}`,
                            seat_label: `Seat ${seatNumber}`,
                            qr_data: `EVENTRA-${eventId}-${Date.now()}-${nextSort}`,
                            ticket_type: item.ticket.name,
                            ticket_status: 'ACTIVE',
                            sort_order: nextSort,
                        },
                    });
                    result.push(created);
                    nextSort += 1;
                }
            }
            return result;
        });
        return {
            payment: {
                id: createdTickets[0]?.id || Date.now(),
                status: 'SUCCESS',
                method,
                subtotal,
                serviceFee,
                total,
                qrisPayload: method === 'qris' ? `EVENTRA-QRIS-${Date.now()}` : null,
            },
        };
    }
    async withFavorite(events, userId) {
        if (!userId || events.length === 0) {
            return events;
        }
        const favorites = await this.prisma.user_favorites.findMany({
            where: {
                user_id: userId,
                favorite_type: 'event',
                item_id: { in: events.map((event) => event.id) },
            },
        });
        const favoriteIds = new Set(favorites.map((favorite) => favorite.item_id));
        return events.map((event) => ({
            ...event,
            is_favorite: favoriteIds.has(event.id),
        }));
    }
    normalizeEvents(events) {
        return events.map((event) => this.normalizeEvent(event));
    }
    normalizeEvent(event) {
        return {
            ...event,
            image: this.normalizeImage(event.image),
        };
    }
    normalizeImage(image) {
        if (!image) {
            return image;
        }
        const value = image.trim();
        if (!value) {
            return value;
        }
        const legacyAliases = {
            'assets/hindia.jpg': 'assets/events/hindia_tennis_indoor.jpeg',
        };
        if (legacyAliases[value]) {
            return legacyAliases[value];
        }
        if (value.startsWith('http://') ||
            value.startsWith('https://') ||
            value.startsWith('assets/events/') ||
            value.startsWith('assets/artists/') ||
            value.startsWith('assets/images/') ||
            value.startsWith('assets/icons/') ||
            value.startsWith('assets/stadiums/')) {
            return value;
        }
        if (value.startsWith('assets/')) {
            return `assets/events/${value.substring('assets/'.length)}`;
        }
        return value;
    }
    async createDefaultTicketTypes(eventId) {
        const event = await this.ensureEvent(eventId);
        const basePrice = this.parsePrice(event.price);
        const rows = [
            { name: 'Regular', badge: 'STANDARD', badge_color: '#8B5CF6', price: basePrice, stock_remaining: 120, max_per_order: 6, sort_order: 1 },
            { name: 'VIP', badge: 'VIP', badge_color: '#F59E0B', price: Math.round(basePrice * 1.8), stock_remaining: 40, max_per_order: 4, sort_order: 2 },
        ];
        await this.prisma.event_ticket_types.createMany({
            data: rows.map((row) => ({
                ...row,
                event_id: eventId,
                description: `${row.name} ticket for ${event.title}`,
                bullet1: `Access to ${event.venue}`,
                bullet2: 'Digital QR ticket',
                bullet3: 'Official Eventra verification',
            })),
            skipDuplicates: true,
        });
    }
    async ensureEvent(eventId) {
        if (!Number.isInteger(eventId) || eventId <= 0) {
            throw new common_1.BadRequestException('Invalid event id');
        }
        const event = await this.prisma.events.findUnique({ where: { id: eventId } });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
        }
        return event;
    }
    async ensureUser(userId) {
        if (!userId) {
            throw new common_1.UnauthorizedException('Missing user session');
        }
        const user = await this.prisma.users.findUnique({ where: { id: userId } });
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid user session');
        }
        return user;
    }
    normalizeCity(location) {
        const value = String(location || '').trim();
        if (!value || ['set your location', 'unknown', '-'].includes(value.toLowerCase())) {
            return '';
        }
        return value.includes(',') ? value.split(',')[0].trim() : value;
    }
    pickProfileFields(body) {
        const data = {};
        for (const field of ['name', 'bio', 'location', 'avatar_url']) {
            if (typeof body[field] === 'string') {
                data[field] = body[field];
            }
        }
        return data;
    }
    parsePrice(value) {
        const digits = String(value || '').replace(/[^0-9]/g, '');
        const amount = Number(digits);
        return Number.isFinite(amount) && amount > 0 ? amount : 350000;
    }
};
exports.MobileApiService = MobileApiService;
exports.MobileApiService = MobileApiService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MobileApiService);
//# sourceMappingURL=mobile-api.service.js.map