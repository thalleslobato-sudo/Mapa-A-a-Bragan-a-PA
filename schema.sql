-- Mapa do Açaí — Bragança-PA
-- Estrutura do banco no Supabase.
-- Painel do Supabase → SQL Editor → New query → cole tudo abaixo → Run.
-- Rode isso UMA vez, logo depois de criar o projeto.

-- 1. Tabela única que guarda todos os dados da plataforma (pontos, config,
--    camadas de ruas/zona rural), cada registro identificado por um "path"
--    (ex.: "pontos/acai-do-mario", "config/geral", "camadas/ruas").
create table if not exists public.docs (
  path text primary key,
  data jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

-- 2. Segurança (Row Level Security): liga a proteção e define quem pode
--    ler, cadastrar, editar e apagar.
alter table public.docs enable row level security;

drop policy if exists "leitura_publica" on public.docs;
create policy "leitura_publica" on public.docs
  for select using (true);

-- Qualquer visitante (sem login) pode cadastrar e editar pontos de açaí.
drop policy if exists "cadastro_aberto_pontos" on public.docs;
create policy "cadastro_aberto_pontos" on public.docs
  for insert with check (path like 'pontos/%');

drop policy if exists "edicao_aberta_pontos" on public.docs;
create policy "edicao_aberta_pontos" on public.docs
  for update using (path like 'pontos/%') with check (path like 'pontos/%');

-- Só quem faz login (o responsável pelo mapa) pode cadastrar/editar QUALQUER
-- registro — inclusive título, categorias, etiquetas e camadas de rua —
-- e é o único que pode apagar pontos.
drop policy if exists "responsavel_insere_tudo" on public.docs;
create policy "responsavel_insere_tudo" on public.docs
  for insert with check (auth.role() = 'authenticated');

drop policy if exists "responsavel_atualiza_tudo" on public.docs;
create policy "responsavel_atualiza_tudo" on public.docs
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "responsavel_apaga" on public.docs;
create policy "responsavel_apaga" on public.docs
  for delete using (auth.role() = 'authenticated');

-- 3. Tempo real: faz as edições aparecerem na hora para todo mundo.
do $$
begin
  execute 'alter publication supabase_realtime add table public.docs';
exception when others then
  raise notice 'A tabela já fazia parte da publicação de tempo real (tudo certo).';
end $$;

-- 4. Dados iniciais: os 12 pontos já levantados e a configuração padrão
--    (título, as duas categorias e nenhuma etiqueta ainda).
insert into public.docs (path, data) values
  ('pontos/00749073z7z56hwa6g7i', '{"nome": "Açaí da Dulce", "categoria": "tradicional", "bairro": "Vila Sinhá", "zona": "urbana", "endereco": "Tv. Tiradentes, 104", "horario": "24h", "lat": -1.047248, "lng": -46.775064, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/0alcvv5ado37opl7h558', '{"nome": "Ponto do Açaí", "categoria": "tradicional", "bairro": "Alegre", "zona": "urbana", "endereco": "Tv. Dois, 6 - Alegre, Bragança - PA, 68600-000", "horario": "8h até 00h", "lat": -1.064571, "lng": -46.773981, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/0oekhuvtflv0e43daybq', '{"nome": "T.B Açaí", "categoria": "tradicional", "bairro": "Morro", "zona": "urbana", "endereco": "Av. Duque de Caxias", "horario": "", "lat": -1.066138, "lng": -46.768713, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/3eq034efi8sj1435o65t', '{"nome": "Açaí da Selma", "categoria": "tradicional", "bairro": "Centro", "zona": "urbana", "endereco": "R. Pinheiro Júnior, 60", "horario": "6h30 às 14h", "lat": -1.060657, "lng": -46.761519, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/6320t322cgq9xbiri5mn', '{"nome": "Louro do Açaí", "categoria": "tradicional", "bairro": "Morro", "zona": "urbana", "endereco": "Av. Duque de Caxias, 704", "horario": "9h às 22h", "lat": -1.065966, "lng": -46.767737, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/acai-do-geleia', '{"nome": "Açaí do Geleia", "categoria": "gourmet", "bairro": "Centro", "zona": "urbana", "endereco": "Rua Pinheiro Júnior", "horario": "Seg a Sáb, 06h às 14h; Dom, 08h às 01h", "lat": -1.0525, "lng": -46.7665, "licenca": "nao_verificado", "licencaNumero": "", "licencaValidade": "", "coordStatus": "aproximada", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/acai-do-mario', '{"nome": "Açaí do Mário", "categoria": "tradicional", "bairro": "Centro", "zona": "urbana", "endereco": "Av. Nazeazeno Ferreira, 600", "horario": "Seg a Sáb, 07h às 13h30; Dom, 08h às 12h", "lat": -1.056211, "lng": -46.766538, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/cxhzex86xt8ioew03ots', '{"nome": "Pérola Açaí", "categoria": "tradicional", "bairro": "Perpétuo Socorro", "zona": "urbana", "endereco": "R. César Pereira, 28", "horario": "8h às 18h", "lat": -1.043161, "lng": -46.775011, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/imyna4vl7ccon064h07x', '{"nome": "Açaí dos Primos", "categoria": "tradicional", "bairro": "Perpétuo Socorro", "zona": "urbana", "endereco": "R. Zacarias Corrêa", "horario": "", "lat": -1.043075, "lng": -46.771087, "licenca": "sem_licenca", "licencaNumero": "", "licencaValidade": "", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/nx0haqwx3gi2gcg0lgre', '{"nome": "Açaí Delícia", "categoria": "tradicional", "bairro": "Perpétuo Socorro", "zona": "urbana", "endereco": "Av. Santos Dumont, 1476", "horario": "", "lat": -1.045376, "lng": -46.772916, "licenca": "licenciado", "licencaNumero": "", "licencaValidade": "2026-12-31", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "destaque": "", "tags": []}'::jsonb),
  ('pontos/tonton-acaiteria', '{"nome": "Tonton Açaiteria", "categoria": "gourmet", "bairro": "Riozinho", "zona": "urbana", "endereco": "Av. Nazeazeno Ferreira, 455", "horario": "", "destaque": "Espaço moderno com proposta gourmet urbana.", "lat": -1.05839, "lng": -46.76594, "licenca": "nao_verificado", "licencaNumero": "", "licencaValidade": "", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "tags": []}'::jsonb),
  ('pontos/yasai-acaiteria', '{"nome": "Yasaí Açaiteria", "categoria": "gourmet", "bairro": "Perpétuo Socorro", "zona": "urbana", "endereco": "Av. Nazeazeno Ferreira, 2206 (em frente à Praça Perpétuo Socorro)", "horario": "Todos os dias, a partir das 16h", "destaque": "Delivery estruturado; boa localização na praça.", "lat": -1.063284, "lng": -46.764611, "licenca": "nao_verificado", "licencaNumero": "", "licencaValidade": "", "coordStatus": "conferida", "fonte": "Guia PDF", "nota": null, "tags": []}'::jsonb)
on conflict (path) do nothing;

insert into public.docs (path, data) values
  ('config/geral', '{"titulo": "Mapa do Açaí\nBragança-PA", "subtitulo": "", "categorias": [{"id": "tradicional", "nome": "Batedor tradicional", "cor": "#6A1F7C"}, {"id": "gourmet", "nome": "Açaiteria gourmet", "cor": "#D38A2B"}], "tags": []}'::jsonb)
on conflict (path) do nothing;
