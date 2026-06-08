import { Test, TestingModule } from '@nestjs/testing';
import { TicketTypesController } from './ticket-types.controller';
import { TicketTypesService } from './ticket-types.service';

describe('TicketTypesController', () => {
  let controller: TicketTypesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TicketTypesController],
      providers: [TicketTypesService],
    }).compile();

    controller = module.get<TicketTypesController>(TicketTypesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
