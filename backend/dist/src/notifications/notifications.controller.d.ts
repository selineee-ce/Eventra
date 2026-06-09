import { NotificationsService } from './notifications.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    create(dto: CreateNotificationDto): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
    findAll(): Promise<{
        data: {
            id: number;
            sort_order: number;
            title: string;
            subtitle: string;
        }[];
    }>;
    findOne(id: string): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
    remove(id: string): Promise<{
        id: number;
        sort_order: number;
        title: string;
        subtitle: string;
    }>;
}
