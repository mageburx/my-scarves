# My Scarves v2.1 — Cloud Sync

Esta versão mantém o IndexedDB local e acrescenta sincronização privada entre Windows e iPhone através do Supabase.

## 1. Criar o projeto Supabase

1. Vai a https://supabase.com e cria um projeto.
2. No projeto, abre **Storage** → **New bucket**.
3. Nome: `scarves`.
4. Mantém o bucket **Private**.
5. Abre **SQL Editor** e executa todo o conteúdo de `SETUP-SUPABASE.sql`.

## 2. Configurar o login

Em **Authentication → URL Configuration**:

- Site URL: `https://mageburx.github.io/my-scarves/`
- Adiciona também `https://mageburx.github.io/my-scarves/` aos Redirect URLs.

Podes manter a confirmação de email ativa. Nesse caso, ao criar a conta terás de abrir o email de confirmação antes do primeiro login.

## 3. Obter as credenciais públicas

No Supabase abre as definições/API do projeto e copia:

- Project URL
- Publishable key (ou legacy `anon` key)

Edita `config.js`:

```js
window.MYSCARVES_CONFIG = {
  supabaseUrl: 'https://TEU-PROJETO.supabase.co',
  supabaseKey: 'A_TUA_PUBLISHABLE_KEY'
};
```

**Nunca uses a `service_role` key no browser ou no GitHub.**

A publishable/anon key é uma chave de frontend. A proteção real dos teus dados é feita pelas políticas RLS incluídas neste projeto.

## 4. Publicar no GitHub

Substitui os ficheiros do repositório pelos desta pasta e faz commit para `main`.

Ficheiros novos importantes:

- `config.js`
- `SETUP-SUPABASE.sql` (não precisa de ser usado pela app; é apenas para configuração)
- `README-SUPABASE.md`

## 5. Primeira sincronização

1. No iPhone, abre My Scarves → **Definições**.
2. Cria uma conta ou inicia sessão.
3. Carrega em **Sincronizar agora**.
4. No Windows, abre o mesmo endereço e inicia sessão com a mesma conta.
5. A coleção é descarregada e fica disponível localmente no Windows.

Depois disso, alterações feitas num dispositivo são enviadas para a cloud e puxadas pelo outro dispositivo quando a app está online.

## Como funciona

- Local: IndexedDB `myscarves-v1`.
- Cloud: tabela `public.scarves` com RLS por `user_id`.
- Fotografias/emblemas: bucket privado `scarves`.
- Conflitos: ganha a alteração com `updatedAt` mais recente.
- Eliminações: são sincronizadas por tombstones para que um cachecol eliminado num dispositivo não reapareça noutro.

## Segurança

A app pública no GitHub não contém a tua coleção. Os dados cloud só podem ser lidos por uma sessão autenticada do mesmo utilizador, desde que as políticas RLS do SQL tenham sido aplicadas corretamente.
