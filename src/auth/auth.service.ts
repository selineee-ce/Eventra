import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

import { JwtService } from '@nestjs/jwt';

import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existingUser = await this.prisma.users.findUnique({
      where: { email: dto.email },
    });

    if (existingUser) {
      throw new BadRequestException('Email already exists');
    }

    if (dto.password !== dto.confirmPassword) {
      throw new BadRequestException('Password and confirm password must match.');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const user = await this.prisma.users.create({
      data: {
        username: dto.username,
        name: dto.username,
        email: dto.email,
        phone: dto.phone,
        location: dto.location,
        password_hash: hashedPassword,
        role: this.getUserRole(dto.email, dto.username),
      },
    });

    const payload = { 
      sub: user.id, 
      email: user.email, 
      role: user.role, 
    };

    return {
      message: 'Register success',
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.users.findUnique({
      where: { email: dto.email },
    });
    if (!user) throw new UnauthorizedException('Email not registered');

    const isMatch = await bcrypt.compare(dto.password, user.password_hash);
    if (!isMatch) throw new UnauthorizedException('Invalid password');

    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    return {
      message: 'Login success',
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    };
  }

  private getUserRole(email: string, username: string): string {
    if (
      username.toLowerCase().includes('admin') ||
      email.toLowerCase().includes('admin')
    ) {
      return 'ADMIN';
    }

    return 'CUSTOMER';
  }
}