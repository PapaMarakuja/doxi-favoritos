import { getProduct, toCard } from "@/lib/nuvemshop";

const MAX = 40; // mesmo limite do snippet

// Só dados públicos (nome, foto, preço, link): pode ser chamado de qualquer origem e cacheado na CDN
const cors = { "Access-Control-Allow-Origin": "*" };

export async function GET(req: Request) {
  const raw = new URL(req.url).searchParams.get("ids") ?? "";
  const ids = [...new Set(raw.split(",").map(Number))].filter((id) => Number.isInteger(id) && id > 0);
  if (!ids.length || ids.length > MAX) return Response.json({ error: "Lista inválida" }, { status: 400, headers: cors });

  try {
    const products = await Promise.all(ids.map(getProduct));
    // Produto apagado (404) ou despublicado some da lista, sem erro
    const cards = products.filter((p) => p?.published).map((p) => toCard(p!));
    return Response.json(
      { products: cards },
      { headers: { ...cors, "Cache-Control": "public, s-maxage=300, stale-while-revalidate=3600" } }
    );
  } catch (e) {
    console.error("products failed", ids, e);
    return Response.json({ error: "Não foi possível carregar agora. Tente novamente." }, { status: 502, headers: cors });
  }
}
