import '@rainbow-me/rainbowkit/styles.css';
import type { Metadata } from 'next';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { ReactNode } from 'react';

import { createClient } from '@/clients/supabase.server';

import { RainbowkitProvider } from '@/components/rainbowkit.provider';
import { RefineProvider } from '@/components/refine.provider';
import { StyleProvider } from '@/components/style.provider';

import '@/utils/ensure-env';
import { Routes, Segments } from '@/utils/routes';
import { getSegment } from '@/utils/rsc';

export const metadata: Metadata = {
  title: 'Bangloan DeFI',
  description: 'Bangloan DeFI',
};

export default async function RootLayout(props: { children: ReactNode }) {
  const supabase = createClient(cookies());
  const { data: auth } = await supabase.auth.getUser();

  const segment = getSegment(props);
  if (auth.user && segment !== Segments.PROTECTED) redirect(Routes.DASHBOARD);

  return (
    <html lang="en">
      <body style={{ height: '100vh' }}>
        <StyleProvider>
          <RefineProvider>
            <RainbowkitProvider>{props.children}</RainbowkitProvider>
          </RefineProvider>
        </StyleProvider>
      </body>
    </html>
  );
}
