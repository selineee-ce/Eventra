import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(dto: RegisterDto): Promise<{
        message: string;
        access_token: string;
        user: {
            id: number;
            username: string;
            name: string;
            email: string;
            phone: string | null;
            location: string | null;
            avatar_url: string | null;
            followers_count: number;
            upcoming_events_count: number;
            description: string | null;
            role: string;
            is_verified: boolean;
        };
    }>;
    login(dto: LoginDto): Promise<{
        message: string;
        access_token: string;
        user: {
            id: number;
            username: string;
            name: string;
            email: string;
            phone: string | null;
            location: string | null;
            avatar_url: string | null;
            followers_count: number;
            upcoming_events_count: number;
            description: string | null;
            role: string;
            is_verified: boolean;
        };
    }>;
}
