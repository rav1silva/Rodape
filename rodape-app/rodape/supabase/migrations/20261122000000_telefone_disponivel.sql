-- Verificação de telefone antes do cadastro.
--
-- O app chama esta função ANTES do auth.signUp, quando ainda não há sessão
-- (role anon). Ela roda como SECURITY DEFINER para enxergar a tabela
-- profiles apesar do RLS, mas devolve só um booleano: nenhum dado de
-- perfil sai daqui.
--
-- A comparação é feita só pelos dígitos, para que "+55 11 91234-5678" e
-- "+5511912345678" sejam tratados como o mesmo número.

create or replace function public.telefone_disponivel(p_telefone text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select not exists (
    select 1
    from public.profiles
    where regexp_replace(telefone, '\D', '', 'g')
        = regexp_replace(coalesce(p_telefone, ''), '\D', '', 'g')
  );
$$;

revoke all on function public.telefone_disponivel(text) from public;
grant execute on function public.telefone_disponivel(text) to anon, authenticated;

-- Garantia final no banco: cobre dois cadastros simultâneos com o mesmo
-- número (os dois passariam na checagem acima ao mesmo tempo).
--
-- ATENÇÃO: se já existirem telefones repetidos, este índice falha. Para
-- encontrá-los antes:
--
--   select regexp_replace(telefone, '\D', '', 'g') as digitos, count(*)
--   from public.profiles
--   group by 1
--   having count(*) > 1;
create unique index if not exists profiles_telefone_digitos_key
  on public.profiles (regexp_replace(telefone, '\D', '', 'g'));
