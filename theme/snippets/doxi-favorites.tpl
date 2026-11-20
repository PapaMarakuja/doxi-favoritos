{# Meus favoritos (doxi-my-favorites)
   - com fav_button: true -> botao coracao da pagina do produto (em snippets/product/product-form.tpl)
   - com fav_header: true -> icone com contador no header (em blocks/header-utilities.tpl, antes do carrinho)
   - sem parametro        -> modal + estilos + script (em layouts/layout.tpl, uma vez so)
   Favoritos ficam no navegador (localStorage). Link compartilhado: /?favoritos=ID,ID,... abre a modal com a lista. #}
{% set doxi_fav_api = 'https://doxi-my-favorites.vercel.app/api/products' %}
{% set doxi_fav_heart = '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>' %}

{% if fav_button %}
{% if product.id and not quickshop %}
<button type="button" class="js-doxi-fav-toggle doxi-fav-toggle" data-product-id="{{ product.id }}" aria-pressed="false">
	<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{{ doxi_fav_heart | raw }}</svg>
	<span class="js-doxi-fav-toggle-text">Favoritar</span>
</button>
{% endif %}

{% elseif fav_header %}
<span class="header-utility doxi-fav-header">
	<button type="button" class="js-doxi-fav-open js-modal-open-private header-icon" data-target="#doxi-fav-modal" data-modal-url="doxi-fav-modal" aria-label="Meus favoritos">
		<svg class="utility-icon icon-inline" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{{ doxi_fav_heart | raw }}</svg>
		<span class="js-doxi-fav-count badge badge-bottom" style="display: none;"></span>
	</button>
</span>

{% else %}

{% embed 'snippets/modals/modal.tpl' with {
	modal_id: 'doxi-fav-modal',
	position: { appear_from: 'bottom' },
	layout: { width_desktop: 'small' },
	title: 'Meus favoritos',
	modal_classes: { modal: 'h-auto', close_icon: 'icon-inline' }
} %}
	{% block modal_body %}
		<div class="js-doxi-fav doxi-fav" data-api="{{ doxi_fav_api }}">
			<p class="js-doxi-fav-status doxi-fav-status" role="status"></p>
			<ul class="js-doxi-fav-list doxi-fav-list"></ul>
			<div class="js-doxi-fav-share-box" style="display: none;">
				<button type="button" class="js-doxi-fav-share btn btn-primary btn-big btn-block">Compartilhar minha lista</button>
				<p class="js-doxi-fav-copied doxi-fav-copied" role="status"></p>
			</div>
		</div>
	{% endblock %}
{% endembed %}

<style>
	.doxi-fav-toggle {
		display: flex;
		width: 100%;
		align-items: center;
		justify-content: center;
		gap: 8px;
		min-height: 44px;
		margin-top: 10px;
		padding: 10px 16px;
		font-size: 14px;
		font-weight: 700;
		color: #e27d8d;
		background: #fff;
		border: 1px solid #e27d8d;
		border-radius: 30px;
		cursor: pointer;
		transition: transform 0.15s ease, background 0.15s ease;
	}
	.doxi-fav-toggle:active { transform: scale(0.97); }
	.doxi-fav-toggle.is-active { color: #fff; background: linear-gradient(135deg, #f5a3b0 0%, #e27d8d 100%); border-color: #e27d8d; }
	.doxi-fav-toggle.is-active svg, .doxi-fav-header.has-favs svg { fill: currentColor; }
	.doxi-fav-toggle.is-popping svg { animation: doxi-fav-pop 0.35s ease-out 1; }
	@keyframes doxi-fav-pop { 50% { transform: scale(1.35); } }

	.doxi-fav-status { margin: 0; font-size: 14px; line-height: 1.5; color: #555552; text-align: center; }
	.doxi-fav-status:empty { display: none; }
	.doxi-fav-list { list-style: none; margin: 0 0 16px; padding: 0; }
	.doxi-fav-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #e5e5e2; }
	.doxi-fav-item:last-child { border-bottom: 0; }
	.doxi-fav-link { display: flex; flex: 1; align-items: center; gap: 12px; min-width: 0; color: inherit; text-decoration: none; }
	.doxi-fav-img { width: 64px; height: 80px; flex: none; object-fit: cover; border-radius: 8px; background: #f8f8f7; }
	.doxi-fav-info { display: flex; flex-direction: column; gap: 2px; min-width: 0; font-size: 14px; }
	.doxi-fav-name { font-weight: 700; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
	.doxi-fav-compare { color: #999996; text-decoration: line-through; margin-right: 6px; }
	.doxi-fav-soldout { color: #c0392b; font-size: 12px; }
	.doxi-fav-remove { flex: none; width: 44px; height: 44px; border: 0; background: none; color: #999996; font-size: 22px; line-height: 1; cursor: pointer; }
	.doxi-fav-copied { margin: 8px 0 0; font-size: 13px; text-align: center; color: #555552; }
	.doxi-fav-copied:empty { display: none; }
</style>

<script>
(function() {
	if (window.DoxiFav) return;

	var KEY = 'doxi_favorites';
	var MAX = 40; // mesmo limite da API

	// "12,34,abc,12" -> [12, 34]
	function parseIds(str) {
		var out = [];
		String(str || '').split(',').forEach(function(s) {
			var n = Number(s);
			if (Number.isInteger(n) && n > 0 && out.indexOf(n) === -1) out.push(n);
		});
		return out.slice(0, MAX);
	}

	// Mais recente primeiro; passou do limite, o mais antigo sai
	function toggle(ids, id) {
		return ids.indexOf(id) === -1 ? [id].concat(ids).slice(0, MAX) : ids.filter(function(x) { return x !== id; });
	}

	function load() {
		try { return parseIds((JSON.parse(localStorage.getItem(KEY)) || []).join(',')); } catch (e) { return []; }
	}
	function save(ids) {
		try { localStorage.setItem(KEY, JSON.stringify(ids)); } catch (e) {} // aba anonima/bloqueado: vale so ate recarregar
		mem = ids;
	}
	var mem = null;
	function favs() { return mem || (mem = load()); }

	function refresh() {
		var ids = favs();
		document.querySelectorAll('.js-doxi-fav-toggle').forEach(function(btn) {
			var on = ids.indexOf(Number(btn.getAttribute('data-product-id'))) !== -1;
			btn.classList.toggle('is-active', on);
			btn.setAttribute('aria-pressed', String(on));
			btn.querySelector('.js-doxi-fav-toggle-text').textContent = on ? 'Favoritado' : 'Favoritar';
		});
		document.querySelectorAll('.js-doxi-fav-count').forEach(function(el) {
			el.textContent = ids.length;
			el.style.display = ids.length ? '' : 'none';
			el.closest('.doxi-fav-header').classList.toggle('has-favs', ids.length > 0);
		});
	}

	function money(n) {
		return Number(n).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
	}

	function el(tag, cls, text) {
		var e = document.createElement(tag);
		if (cls) e.className = cls;
		if (text != null) e.textContent = text;
		return e;
	}

	function item(p, shared) {
		var li = el('li', 'doxi-fav-item');
		var a = el('a', 'doxi-fav-link');
		a.href = p.url;
		if (p.image) {
			var img = el('img', 'doxi-fav-img');
			img.src = p.image;
			img.alt = '';
			img.loading = 'lazy';
			a.appendChild(img);
		}
		var info = el('span', 'doxi-fav-info');
		info.appendChild(el('span', 'doxi-fav-name', p.name));
		if (p.price != null) {
			var price = el('span');
			if (p.compare_at) price.appendChild(el('span', 'doxi-fav-compare', money(p.compare_at)));
			price.appendChild(document.createTextNode(money(p.price)));
			info.appendChild(price);
		}
		if (!p.available) info.appendChild(el('span', 'doxi-fav-soldout', 'Esgotado'));
		a.appendChild(info);
		li.appendChild(a);
		if (!shared) {
			var rm = el('button', 'js-doxi-fav-remove doxi-fav-remove', '×');
			rm.type = 'button';
			rm.setAttribute('data-product-id', p.id);
			rm.setAttribute('aria-label', 'Remover ' + p.name + ' dos favoritos');
			li.appendChild(rm);
		}
		return li;
	}

	var seq = 0;
	// shared = ids vindos do link compartilhado; sem ele mostra os favoritos deste navegador
	function show(shared) {
		var box = document.querySelector('.js-doxi-fav');
		var ids = shared || favs();
		var status = box.querySelector('.js-doxi-fav-status');
		var list = box.querySelector('.js-doxi-fav-list');
		var title = document.querySelector('#doxi-fav-modal .modal-title');
		if (title) title.textContent = shared ? 'Lista de favoritos' : 'Meus favoritos';
		box.querySelector('.js-doxi-fav-share-box').style.display = shared || !ids.length ? 'none' : '';
		box.querySelector('.js-doxi-fav-copied').textContent = '';
		list.innerHTML = '';
		if (!ids.length) { status.textContent = 'Você ainda não favoritou nada. Toque em "Favoritar" na página do produto 🐾'; return; }
		status.textContent = 'Carregando...';
		var my = ++seq;
		fetch(box.getAttribute('data-api') + '?ids=' + ids.join(','))
			.then(function(r) { return r.json().then(function(d) { if (!r.ok) throw new Error(d.error); return d.products; }); })
			.then(function(products) {
				if (my !== seq) return;
				status.textContent = products.length ? '' : 'Esses produtos não estão mais disponíveis.';
				products.forEach(function(p) { list.appendChild(item(p, !!shared)); });
			})
			.catch(function(e) {
				if (my === seq) status.textContent = e.message || 'Não foi possível carregar agora. Tente novamente.';
			});
	}

	function shareLink() {
		return location.origin + '/?favoritos=' + favs().join(',');
	}

	function share() {
		var url = shareLink();
		var copied = document.querySelector('.js-doxi-fav-copied');
		if (navigator.share) {
			navigator.share({ title: 'Meus favoritos da Doxi', url: url }).catch(function() {});
			return;
		}
		(navigator.clipboard ? navigator.clipboard.writeText(url) : Promise.reject())
			.then(function() { copied.textContent = 'Link copiado! É só colar onde quiser 💕'; })
			.catch(function() { copied.textContent = url; }); // sem clipboard: mostra o link pra copiar na mao
	}

	var pendingShared = null;

	// Link compartilhado: abre a modal assim que o tema (store.js, carregado depois) ligar os modais
	function openShared(ids) {
		var trigger = document.querySelector('.js-doxi-fav-open');
		var modal = document.querySelector('#doxi-fav-modal');
		if (!trigger || !modal) return;
		var tries = 0;
		(function attempt() {
			if (modal.classList.contains('modal-visible') || tries++ > 20) return;
			pendingShared = ids;
			trigger.click();
			setTimeout(attempt, 400);
		})();
	}

	function init() {
		document.addEventListener('click', function(e) {
			var t = e.target.closest('.js-doxi-fav-toggle');
			if (t) {
				save(toggle(favs(), Number(t.getAttribute('data-product-id'))));
				t.classList.remove('is-popping');
				void t.offsetWidth; // reflow: a animacao toca a cada clique
				t.classList.add('is-popping');
				return refresh();
			}
			if (e.target.closest('.js-doxi-fav-open')) { show(pendingShared); pendingShared = null; return; }
			var rm = e.target.closest('.js-doxi-fav-remove');
			if (rm) {
				save(toggle(favs(), Number(rm.getAttribute('data-product-id'))));
				refresh();
				rm.closest('.doxi-fav-item').remove();
				if (!favs().length) show(); // mostra o "lista vazia"
				return;
			}
			if (e.target.closest('.js-doxi-fav-share')) return share();
		});
		refresh();
		var shared = parseIds(new URLSearchParams(location.search).get('favoritos'));
		if (shared.length) openShared(shared);
	}

	window.DoxiFav = { parseIds: parseIds, toggle: toggle, shareLink: shareLink, refresh: refresh };
	if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
</script>
{% endif %}
