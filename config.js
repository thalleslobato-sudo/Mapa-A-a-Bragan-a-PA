// Endereço e chave pública (anon) do seu projeto Supabase.
// Painel do Supabase → Project Settings → API → Project URL e "anon public" key.
//
// A chave "anon" é pública por natureza: ela fica visível para quem abrir o site.
// Quem protege os dados são as políticas (RLS) criadas pelo arquivo schema.sql.
// NUNCA coloque aqui a chave "service_role".
window.CONFIG_SUPABASE = {
  url: "COLE-AQUI-A-URL-DO-SEU-PROJETO",       // ex.: https://abcdefghijk.supabase.co
  anonKey: "COLE-AQUI-A-CHAVE-ANON-PUBLICA"
};
