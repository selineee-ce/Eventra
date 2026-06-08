import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateEventDto) {
    return this.prisma.events.create({
      data: dto,
    });
  }

  async findAll() {
    return this.prisma.events.findMany({
      include: {
        event_ticket_types: true,
      },
    });
  }

  async findOne(id: number) {
    const event = await this.prisma.events.findUnique({
      where: { id },
      include: {
        event_ticket_types: true,
      },
    });

    if (!event) {
      throw new NotFoundException('Event not found');
    }

    return event;
  }

  async update(id: number, dto: UpdateEventDto) {
    return this.prisma.events.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.events.delete({
      where: { id },
    });
  }
}