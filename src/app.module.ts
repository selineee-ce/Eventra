import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { EventsModule } from './events/events.module';
import { TicketsModule } from './tickets/tickets.module';
import { NotificationsModule } from './notifications/notifications.module';
import { UserFavoritesModule } from './user-favorites/user-favorites.module';
import { TicketTypesModule } from './ticket-types/ticket-types.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    EventsModule,
    TicketsModule,
    NotificationsModule,
    UserFavoritesModule,
    TicketTypesModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
