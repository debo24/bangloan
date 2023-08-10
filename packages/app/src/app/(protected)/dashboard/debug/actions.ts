'use server';

import { cookies } from 'next/headers';

import { createClient as createBangloan } from '@/clients/bangloan-api.client';
import { createClient as createSupabase } from '@/clients/supabase.server';

export const whitelistAddress = async (address: string) => {
  const supabase = createSupabase(cookies());
  const bangloanApi = createBangloan(supabase);

  const auth = await supabase.auth.getSession();
  const user_id = auth.data.session!.user.id;

  return bangloanApi.whitelistAddress({ address, user_id });
};
