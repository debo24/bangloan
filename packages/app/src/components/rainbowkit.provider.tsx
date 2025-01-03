'use client';

import { RainbowKitProvider, getDefaultWallets } from '@rainbow-me/rainbowkit';
import { ReactNode } from 'react';
import { WagmiConfig, configureChains, createConfig } from 'wagmi';
import { arbitrum, arbitrumSepolia, base, baseSepolia, foundry } from 'wagmi/chains';
import { publicProvider } from 'wagmi/providers/public';

const { chains, publicClient } = configureChains(
  [baseSepolia, foundry, arbitrumSepolia, arbitrum, base],
  [publicProvider()],
);

const { connectors } = getDefaultWallets({
  appName: 'Bangloan DeFI',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID,
  chains,
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
});

export function RainbowkitProvider({ children }: { children: ReactNode }) {
  return (
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider chains={chains}>{children}</RainbowKitProvider>
    </WagmiConfig>
  );
}
