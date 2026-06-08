import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { TicketTypesService } from './ticket-types.service';
import { CreateTicketTypeDto } from './dto/create-ticket-type.dto';
import { UpdateTicketTypeDto } from './dto/update-ticket-type.dto';

@Controller('ticket-types')
export class TicketTypesController {
  constructor(
    private readonly ticketTypesService: TicketTypesService,
  ) {}

  @Post()
  create(@Body() dto: CreateTicketTypeDto) {
    return this.ticketTypesService.create(dto);
  }

  @Get()
  findAll() {
    return this.ticketTypesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ticketTypesService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateTicketTypeDto,
  ) {
    return this.ticketTypesService.update(
      +id,
      dto,
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ticketTypesService.remove(+id);
  }
}