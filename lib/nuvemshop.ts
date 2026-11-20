type I18n = Record<string, string>;

export type NsVariant = {
  id: number;
  price: string | null;
  promotional_price: string | null;
  stock: number | null; // null = estoque infinito
  stock_management: boolean;
};

export type NsProduct = {
  id: number;
  name: I18n;
  canonical_url: string;
  published: boolean;
  variants: NsVariant[];
  images: { src: string }[];
};

const t = (v: I18n | undefined) => (v ? v.pt ?? Object.values(v)[0] ?? "" : "");

export async function getProduct(productId: number): Promise<NsProduct | null> {
  const base = process.env.NUVEMSHOP_API_URL ?? "https://api.nuvemshop.com.br/v1";
  const fields = "id,name,canonical_url,published,variants,images";
  const res = await fetch(`${base}/${process.env.NUVEMSHOP_USER_ID}/products/${productId}?fields=${fields}`, {
    headers: {
      Authentication: `bearer ${process.env.NUVEMSHOP_ACCESS_TOKEN}`,
      "User-Agent": "doxi-my-favorites (hello@doxiwear.com)",
    },
    next: { revalidate: 300 }, // cache por produto: protege o rate limit da API (balde de 40 req)
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`Nuvemshop API ${res.status} ${res.statusText}`);
  return (await res.json()) as NsProduct;
}

const inStock = (v: NsVariant) => !v.stock_management || v.stock === null || v.stock > 0;
const num = (s: string | null) => (s && Number(s) > 0 ? Number(s) : null);
const finalPrice = (v: NsVariant) => num(v.promotional_price) ?? num(v.price);

// Card público do produto: menor preço entre as variantes (com o "de" quando está em promoção)
export function toCard(p: NsProduct) {
  const priced = p.variants.filter((v) => finalPrice(v) !== null);
  const v = priced.sort((a, b) => finalPrice(a)! - finalPrice(b)!)[0];
  return {
    id: p.id,
    name: t(p.name),
    url: p.canonical_url,
    image: p.images[0]?.src ?? null,
    price: v ? finalPrice(v) : null,
    compare_at: v && num(v.promotional_price) ? num(v.price) : null,
    available: p.variants.some(inStock),
  };
}
