import CodeCallback from '@/components/auth/code-callback';

export default async function MagicLink({ searchParams }: { searchParams: { code?: string } }) {
  return <CodeCallback searchParams={searchParams} />;
}
