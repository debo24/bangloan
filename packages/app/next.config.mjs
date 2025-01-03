/**
 * @type {import("next").NextConfig}
 */
const nextConfig = {
  transpilePackages: ['@bangloan/sdk'],
  webpack: (config) => {
    config.externals.push({
      'utf-8-validate': 'commonjs utf-8-validate',
      bufferutil: 'commonjs bufferutil',
      'pino-pretty': 'commonjs pino-pretty',
    });
    return config;
  },
};

export default nextConfig;
