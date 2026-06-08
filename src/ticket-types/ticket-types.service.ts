import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateTicketTypeDto } from './dto/create-ticket-type.dto';
import { UpdateTicketTypeDto } from './dto/update-ticket-type.dto';

@Injectable()
export class TicketTypesService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateTicketTypeDto) {
    return this.prisma.event_ticket_types.create({
      data: dto,
    });
  }

  async findAll() {
    return this.prisma.event_ticket_types.findMany({
      include: {
        events: true,
      },
    });
  }

  async findOne(id: number) {
    const ticketType =
      await this.prisma.event_ticket_types.findUnique({
        where: { id },
        include: {
          events: true,
        },
      });

    if (!ticketType) {
      throw new NotFoundException(
        'Ticket type not found',
      );
    }

    return ticketType;
  }

  async update(
    id: number,
    dto: UpdateTicketTypeDto,
  ) {
    return this.prisma.event_ticket_types.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.event_ticket_types.delete({
      where: { id },
    });
  }
}