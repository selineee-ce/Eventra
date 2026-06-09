import { MobileApiService } from './mobile-api.service';
export declare class MobileApiController {
    private readonly mobileApiService;
    constructor(mobileApiService: MobileApiService);
    health(): {
        ok: boolean;
    };
    featuredEvents(userId?: string): Promise<{
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
    nearbyEvents(userId?: string, location?: string): Promise<{
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
    passes(): {
        data: never[];
    };
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
    ticketTypes(id: string): Promise<{
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
    eventDetail(id: string): Promise<{
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
    profile(userId?: string): Promise<{
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
    updateProfile(userId: string | undefined, body: Record<string, unknown>): Promise<{
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
    setEventFavorite(userId: string | undefined, id: string, body: {
        isFavorite?: boolean;
    }): Promise<{
        ok: boolean;
    }>;
    setArtistFavorite(userId: string | undefined, id: string, body: {
        isFavorite?: boolean;
    }): Promise<{
        ok: boolean;
    }>;
    setPassFavorite(): {
        ok: boolean;
    };
    checkout(userId: string | undefined, body: Record<string, unknown>): Promise<{
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
    private parseUserId;
}
