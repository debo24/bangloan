import { BangloanWhiteListProvider } from '@bangloan/contracts';
import { Test, TestingModule } from '@nestjs/testing';
import { SupabaseClient } from '@supabase/supabase-js';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { DeepMockProxy, mockDeep } from 'vitest-mock-extended';

import { EthersService } from '../../clients/ethers/ethers.service';
import { SupabaseAdminService } from '../../clients/supabase/supabase-admin.service';
import { SupabaseService } from '../../clients/supabase/supabase.service';
import { ConfigurationModule } from '../../utils/module';

import { AccountsController } from './accounts.controller';
import { AccountsModule } from './accounts.module';
import { WhiteListStatus } from './whiteList.dto';
import { WhiteListService } from './whiteList.service';

describe('AccountsController', () => {
  let controller: AccountsController;
  let client: DeepMockProxy<SupabaseClient>;
  let admin: DeepMockProxy<SupabaseClient>;
  let whiteList: DeepMockProxy<BangloanWhiteListProvider>;
  let ethers: DeepMockProxy<EthersService>;
  beforeEach(async () => {
    client = mockDeep<SupabaseClient>();
    admin = mockDeep<SupabaseClient>();
    whiteList = mockDeep<BangloanWhiteListProvider>();
    ethers = mockDeep<EthersService>();

    (WhiteListService.prototype as any).getOnChainProvider = vi.fn().mockReturnValue(whiteList);

    const service = { client: () => client, admin: () => admin };

    const module: TestingModule = await Test.createTestingModule({
      imports: [ConfigurationModule, AccountsModule],
    })
      .overrideProvider(SupabaseAdminService)
      .useValue(service)
      .overrideProvider(SupabaseService)
      .useValue(service)
      .overrideProvider(EthersService)
      .useValue(ethers)
      .compile();

    controller = await module.resolve<AccountsController>(AccountsController);
  });

  it('should return pending status if there is no white list event', async () => {
    const select = vi.fn();
    const eq = vi.fn();
    const single = vi.fn();
    const builder = { select, eq, single };
    select.mockReturnValueOnce(builder as any);
    eq.mockReturnValueOnce(builder as any);
    single.mockResolvedValueOnce({ data: null } as any);

    client.from.mockReturnValue(builder as any);

    const { status } = await controller.status();

    expect(status).toBe(WhiteListStatus.PENDING);
  });

  it('should whitelist an existing account', async () => {
    const user_id = '1';
    const address = '0x0000000000';

    const insert = vi.fn();
    const select = vi.fn();
    const eq = vi.fn();
    const is = vi.fn();
    const single = vi.fn();
    const maybeSingle = vi.fn();
    const neq = vi.fn();
    const lt = vi.fn();
    const builder = { insert, select, eq, single, neq, lt, maybeSingle, is };
    select
      .mockReturnValueOnce(builder as any)
      .mockReturnValueOnce(builder as any)
      .mockReturnValueOnce(builder as any);
    is.mockReturnValue(builder as any);
    eq.mockReturnValue(builder as any);
    single.mockResolvedValueOnce({ data: { user_id } } as any);
    maybeSingle.mockResolvedValueOnce({} as any);

    neq.mockReturnValueOnce({ lt } as any);
    lt.mockResolvedValueOnce({ data: [{ address: '0xvault0xaddress' }] } as any);

    insert.mockReturnValueOnce(builder as any);
    select.mockResolvedValueOnce({ data: [] } as any);

    admin.from.mockReturnValue({ select, insert } as any);
    ethers.operator.mockResolvedValue({} as any);

    whiteList.status.mockResolvedValueOnce(false);
    whiteList.updateStatus.mockResolvedValueOnce({} as any);

    const { status } = await controller.whitelist({ user_id, address });

    expect(insert.mock.calls[0][0]).toStrictEqual({ address, user_id, event_name: 'accepted' });
    expect(status).toBe(WhiteListStatus.ACTIVE);
  });

  it('should verify the signature and link the wallet', async () => {
    const app_metadata = {};
    const user_id = '1';
    const dto = {
      message:
        'localhost:3000 wants you to sign in with your Ethereum account:\n0xA57FCEE8db30A62b1FE8Fab0431Ac2d2A6aBbAfB\n\nBy connecting your wallet, you agree to the Terms of Service and Privacy Policy.\n\nURI: http://localhost:3000\nVersion: 1\nChain ID: 10\nNonce: zIok3D7zIKBu3VAnl\nIssued At: 2024-01-10T09:22:45.985Z',
      signature:
        '0x9bc8fd1dd2c25bead1582e3ecd4a949ee6093ef47d3d1bcd82c5cf08e71f7fc33979d365cddcb3c1172b4e72fab0775b53ab60af990b23f0fa0bdc8cca03059c1b',
    };

    const select = vi.fn();
    const eq = vi.fn();
    const insert = vi.fn();
    const maybeSingle = vi.fn();
    const builder = { select, eq, insert, maybeSingle };
    insert.mockReturnValueOnce(builder as any);
    eq.mockReturnValueOnce(builder as any);
    maybeSingle.mockResolvedValueOnce({} as any);
    select.mockReturnValueOnce(builder as any).mockResolvedValueOnce({ data: [{ user_id }] } as any);

    client.auth.getUser.mockResolvedValueOnce({ data: { user: { id: user_id, app_metadata } } } as any);
    client.from.mockReturnValue(builder as any);

    const data = await controller.linkWallet(dto);

    expect(data.user_id).toBe(user_id);
  });

  it('should not verify the signature and throw an error', async () => {
    const app_metadata = {};
    const user_id = '1';
    const dto = {
      message:
        'localhost:3000 wants you to sign in with your Ethereum account:\n0xA57FCEE8db30A62b1FE8Fab0431Ac2d2A6aBbAfB\n\nBy connecting your wallet, you agree to the Terms of Service and Privacy Policy.\n\nURI: http://localhost:3000\nVersion: 1\nChain ID: 10\nNonce: zIok3D7zIKBu3VAnl\nIssued At: 2024-01-10T09:22:45.985Z',
      signature:
        '0xd4a949ee6093ef47d3d1bcd82c5cf08e71f7fc33979d365cddcb3c1172b4e72fab0775b53ab60af990b23f0fa0bdc8cca03059c1b',
    };

    client.auth.getUser.mockResolvedValueOnce({ data: { user: { id: user_id, app_metadata } } } as any);

    try {
      await controller.linkWallet(dto);
    } catch (e) {
      expect(e.error.type).toBe('Signature does not match address of the message.');
    }
  });

  it('should require discriminator if entity type is partner', async () => {
    const app_metadata = { partner_type: 'channel' };
    const user_id = '1';
    const dto = { message: '', signature: '' };

    client.auth.getUser.mockResolvedValueOnce({ data: { user: { id: user_id, app_metadata } } } as any);

    try {
      await controller.linkWallet(dto);
    } catch (e) {
      expect(e.message).toBe('No discriminator provided');
    }
  });
});
