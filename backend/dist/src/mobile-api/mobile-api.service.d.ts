import { PrismaService } from '../prisma/prisma.service';
export declare class MobileApiService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    featuredEvents(userId?: number): Promise<{
        data: ({
            id: number;
            description: string | null;
            sort_order: number;
            title: string;
            venue: string;
            city: string;
            date_label: string;
            lineup: string | null;
            show_time: string | null;
            price: string | null;
            image: string | null;
            is_featured: boolean;
            remaining_seats: number;
            user_id: number | null;
            detail_image: string | null;
            venue_layout: string | null;
            source_url: string | null;
            tag1: string | null;
            tag2: string | null;
            button: string | null;
            is_limited: boolean;
            is_favorite: boolean;
        } & {
            image: string | null | undefined;
        })[];
    }>;
    nearbyEvents(userId?: number, location?: string): Promise<{
        data: {
            date: string;
            place: string;
            artist_name: string;
            id: number;
            description: string | null;
            sort_order: number;
            title: string;
            venue: string;
            city: string;
            date_label: string;
            lineup: string | null;
            show_time: string | null;
            price: string | null;
            image: string | null;
            is_featured: boolean;
            remaining_seats: number;
            user_id: number | null;
            detail_image: string | null;
            venue_layout: string | null;
            source_url: string | null;
            tag1: string | null;
            tag2: string | null;
            button: string | null;
            is_limited: boolean;
            is_favorite: boolean;
        }[];
    }>;
    exclusiveDrops(): Promise<{
        data: {
            id: number;
            title: string;
            badge: string;
            description: string;
            type: string;
            image: string | null;
            countdown_seconds: number;
            sort_order: number;
        }[];
    }>;
    ticketTypes(eventId: number): Promise<{
        data: {
            id: number;
            name: string;
            description: string | null;
            sort_order: number;
            price: number;
            event_id: number;
            badge: string | null;
            badge_color: string | null;
            bullet1: string | null;
            bullet2: string | null;
            bullet3: string | null;
            stock_remaining: number;
            max_per_order: number;
        }[];
    }>;
    eventDetail(eventId: number): Promise<{
        data: {
            place: string;
            artist_name: string;
            id: number;
            description: string | null;
            sort_order: number;
            title: string;
            venue: string;
            city: string;
            date_label: string;
            lineup: string | null;
            show_time: string | null;
            price: string | null;
            image: string | null;
            is_featured: boolean;
            remaining_seats: number;
            user_id: number | null;
            detail_image: string | null;
            venue_layout: string | null;
            source_url: string | null;
            tag1: string | null;
            tag2: string | null;
            button: string | null;
            is_limited: boolean;
            is_favorite: boolean;
        };
    }>;
    profile(userId?: number): Promise<{
        profile: {
            username: string;
            phone: string | null;
            email: string;
            location: string | null;
            id: number;
            name: string;
            bio: string | null;
            avatar_url: string | null;
            followers_count: number;
            events_count: number;
            upcoming_events_count: number;
            genre: string | null;
            description: string | null;
            role: string;
            is_verified: boolean;
            sort_order: number;
            created_at: Date;
        };
    }>;
    updateProfile(userId: number | undefined, body: Record<string, unknown>): Promise<{
        ok: boolean;
    }>;
    appConfig(): Promise<{
        config: Record<string, string>;
    }>;
    cities(): Promise<{
        data: string[];
    }>;
    artists(): Promise<{
        data: {
            id: number;
            name: string;
            username: string;
            avatar_url: string | null;
            imageUrl: string | null;
            genre: string | null;
            description: string | null;
            followers: number;
            followers_count: number;
            monthly_listeners: number;
            events_count: number;
            upcomingEvents: {
                event_id: number;
                place: string;
                artist_name: string;
                id: number;
                description: string | null;
                sort_order: number;
                title: string;
                venue: string;
                city: string;
                date_label: string;
                lineup: string | null;
                show_time: string | null;
                price: string | null;
                image: string | null;
                is_featured: boolean;
                remaining_seats: number;
                user_id: number | null;
                detail_image: string | null;
                venue_layout: string | null;
                source_url: string | null;
                tag1: string | null;
                tag2: string | null;
                button: string | null;
                is_limited: boolean;
                is_favorite: boolean;
            }[];
        }[];
    }>;
    setEventFavorite(userId: number | undefined, eventId: number, isFavorite: boolean): Promise<{
        ok: boolean;
    }>;
    setArtistFavorite(userId: number | undefined, artistId: number, isFavorite: boolean): Promise<{
        ok: boolean;
    }>;
    checkout(userId: number | undefined, body: Record<string, unknown>): Promise<{
        payment: {
            id: number;
            status: string;
            method: string;
            subtotal: number;
            serviceFee: number;
            total: number;
            qrisPayload: string | null;
        };
    }>;
    private withFavorite;
    private normalizeEvents;
    private normalizeEvent;
    private normalizeImage;
    private createDefaultTicketTypes;
    private ensureEvent;
    private ensureUser;
    private normalizeCity;
    private pickProfileFields;
    private parsePrice;
}
