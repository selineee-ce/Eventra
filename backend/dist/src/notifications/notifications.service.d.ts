import { PrismaService } from '../prisma/prisma.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
export declare class NotificationsService {
    private prisma;
    constructor(prisma: PrismaService);
    create(dto: CreateNotificationDto): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
    findAll(): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }[]>;
    findOne(id: number): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
    remove(id: number): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
}
