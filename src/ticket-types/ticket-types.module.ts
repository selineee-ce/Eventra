import { Module } from '@nestjs/common';
import { TicketTypesService } from './ticket-types.service';
import { TicketTypesController } from './ticket-types.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [TicketTypesController],
  providers: [TicketTypesService],
})
export class TicketTypesModule {}
