import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateTicketDto } from './dto/create-ticket.dto';
import { UpdateTicketDto } from './dto/update-ticket.dto';

@Injectable()
export class TicketsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateTicketDto) {
    return this.prisma.tickets.create({
      data: dto,
    });
  }

  async findAll() {
    return this.prisma.tickets.findMany({
      include: {
        users: true,
      },
    });
  }

  async findOne(id: number) {
    const ticket = await this.prisma.tickets.findUnique({
      where: { id },
      include: {
        users: true,
      },
    });

    if (!ticket) {
      throw new NotFoundException(
        'Ticket not found',
      );
    }

    return ticket;
  }

  async update(
    id: number,
    dto: UpdateTicketDto,
  ) {
    return this.prisma.tickets.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.tickets.delete({
      where: { id },
    });
  }
}