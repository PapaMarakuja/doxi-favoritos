// Testa a lógica do snippet (roda o <script> do .tpl num window falso)
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const tpl = readFileSync(new URL("./snippets/doxi-favorites.tpl", import.meta.url), "utf8");
const js = tpl.match(/<script>([\s\S]*?)<\/script>/)[1];
const store = { doxi_favorites: JSON.stringify([5, 7]) };
const window = {};
const document = { readyState: "complete", addEventListener() {}, querySelector: () => null, querySelectorAll: () => [] };
const localStorage = { getItem: (k) => store[k] ?? null, setItem: (k, v) => (store[k] = v) };
const location = { origin: "https://doxiwear.com", search: "?favoritos=3,1" };
new Function("window", "document", "localStorage", "location", js)(window, document, localStorage, location);
const { parseIds, toggle, shareLink } = window.DoxiFav;

test("parseIds ignora lixo e repetidos", () => {
  assert.deepEqual(parseIds("12, 34,abc,12,-1,0,1.5,"), [12, 34]);
  assert.deepEqual(parseIds(null), []);
});

test("toggle adiciona no topo, remove, e respeita o limite de 40", () => {
  assert.deepEqual(toggle([1, 2], 3), [3, 1, 2]);
  assert.deepEqual(toggle([1, 2, 3], 2), [1, 3]);
  const full = Array.from({ length: 40 }, (_, i) => i + 1);
  const next = toggle(full, 99);
  assert.equal(next.length, 40);
  assert.equal(next[0], 99);
  assert.equal(next.includes(40), false); // o mais antigo saiu
});

test("link compartilhado usa os favoritos salvos", () => {
  assert.equal(shareLink(), "https://doxiwear.com/?favoritos=5,7");
});
