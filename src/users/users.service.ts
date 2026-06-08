import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.users.findMany({
      select: {
        id: true,
        username: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        is_verified: true,
      },
    });
  }

  async findOne(id: number) {
    const user = await this.prisma.users.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async update(id: number, dto: UpdateUserDto) {
    return this.prisma.users.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: number) {
    return this.prisma.users.delete({
      where: { id },
    });
  }
}