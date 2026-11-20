# doxi-my-favorites

"Meus favoritos" da Doxi na Nuvemshop.

**Fluxo:** botão "Favoritar" na página do produto → o ID fica salvo no navegador (`localStorage`, até 40 produtos) → ícone de coração no header (com contador) abre uma modal com a lista → `GET /api/products?ids=...` busca nome, foto, preço e estoque atuais na API da Nuvemshop → cada item leva ao produto e tem um × para remover.

**Compartilhar:** o botão "Compartilhar minha lista" gera `https://doxiwear.com/?favoritos=ID,ID,...` (no celular abre o compartilhar nativo; no desktop copia o link). Quem abre o link vê a modal "Lista de favoritos" com aqueles produtos, só para ver (não mexe nos favoritos da pessoa).

Sem banco e sem dados pessoais: a API só devolve dados públicos dos produtos, então é aberta (CORS `*`) e cacheada na CDN da Vercel por 5 min.

## Setup

1. **Env:** copie `.env.example` para `.env.local` (e configure na Vercel). Mesmo token da Nuvemshop do doxi-affiliates/doxi-notifyme.
2. **Deploy** na Vercel.
3. **Tema:** copie `theme/snippets/doxi-favorites.tpl` para `snippets/doxi-favorites.tpl` do tema e inclua em três lugares:

`layouts/layout.tpl`, dentro do `{% if template != 'password' %}` (perto do `cart-modal.tpl`):

```twig
{% include 'snippets/doxi-favorites.tpl' %}
```

`blocks/header-utilities.tpl`, logo antes do `{# Cart #}`:

```twig
{% include 'snippets/doxi-favorites.tpl' with { fav_header: true } %}
```

`snippets/product/product-form.tpl`, dentro de `.buy-button-container`, depois do notify-me:

```twig
{% include 'snippets/doxi-favorites.tpl' with { fav_button: true } %}
```

Ajuste `doxi_fav_api` no topo do snippet se o domínio do deploy for outro.

## Dev

```powershell
npm run dev
```

```powershell
npm test
```

`npm test` testa a lógica do snippet (limpeza dos IDs, adicionar/remover, link compartilhado).
