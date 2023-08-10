'use server';

import { cookies } from 'next/headers';

import { createClient as createBangloan } from '@/clients/bangloan-api.client';
import { createClient as createSupabase } from '@/clients/supabase.server';

export const accountStatus = async () => {
  const supabase = createSupabase(cookies());
  const bangloanApi = createBangloan(supabase);

  return bangloanApi.accountStatus();
};

export const linkWallet = async (message: string, signature: string, discriminator?: string) => {
  const supabase = createSupabase(cookies());
  const bangloanApi = createBangloan(supabase);

  await bangloanApi.linkWallet(message, signature, discriminator);
};

export const mockTokenAddress = async (): Promise<string | undefined> => {
  const admin = createSupabase(cookies(), { admin: true });
  const { data } = await admin.from('contracts_addresses').select().eq('contract_name', 'SimpleToken').single();

  return data?.address;
};
