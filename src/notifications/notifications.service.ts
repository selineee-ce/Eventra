import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateNotificationDto } from './dto/create-notification.dto';
@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateNotificationDto) {
    return this.prisma.notifications.create({
      data: dto,
    });
  }

  async findAll() {
    return this.prisma.notifications.findMany({
      orderBy: {
        sort_order: 'asc',
      },
    });
  }

  async findOne(id: number) {
    const notification =
      await this.prisma.notifications.findUnique({
        where: { id },
      });

    if (!notification) {
      throw new NotFoundException(
        'Notification not found',
      );
    }

    return notification;
  }

  async remove(id: number) {
    return this.prisma.notifications.delete({
      where: { id },
    });
  }
}