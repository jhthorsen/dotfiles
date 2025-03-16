window.addEventListener('load', async function() {
  try {
    const columns = ['ordered_at', 'id', 'cost', 'content', 'img_url', 'order_url', 'product_url'];
    const $form = document.querySelector('form[action*="/your-orders/orders"]');
    if (!$form) return console.log('Skip order parser safari/amazon.co.jp.js');

    let storageOrders = JSON.parse(localStorage.getItem('AmazonOrderHistory') || '[]');
    let found = 0;
    for (const $orderLink of document.querySelectorAll('a[href*="/order-details/"], a[href*="/order-summary"]')) {
      const $orderCard = $orderLink.closest('.js-order-card');
      const id = $orderCard.querySelector('.yohtmlc-order-id').textContent.replace(/.*#\s*/, '').trim(); // Remove "ORDER #"
      if ($orderCard.textContent.match(/Return complete/)) {
        storageOrders = storageOrders.filter(o => o.id !== id);
        continue;
      }

      for (const $product of $orderCard.querySelectorAll('.yohtmlc-item a')) {
        if ($product.href.indexOf('/product/') == -1) continue;

        // Add or update each product within an order
        const order = storageOrders.filter(o => o.id === id && o.product_url === $product.href)[0] || {};
        const $img = $product.closest('.a-fixed-left-grid').querySelector('img[src*="/images/"]');

        while ($img.src.indexOf("pixel") > 0) {
          if (!$img.parentNode) break;
          $img.scrollIntoView();
          console.log("Waiting for image to load", $img);
          await new Promise((resolve) => setTimeout(resolve, 200));
        }

        if (order.img_url && order.img_url !== $img.src) found++;

        order.content = $product.textContent.trim();
        order.cost = $orderCard.querySelector('.yohtmlc-order-total').textContent.trim().replace(/\D+/g, '');
        order.ordered_at = parseDate($orderCard.querySelector('.a-size-base .a-color-secondary').textContent.trim());
        order.ts = new Date(order.ordered_at).getTime();
        order.img_url = $img.src;
        order.order_url = $orderLink.href;
        order.product_url = $product.href;

        if (!order.id && storageOrders.filter(o => o.id === id).length > 0) order.cost = '';
        if (!order.id) found += storageOrders.push(order);
        order.id = id;
      }
    }

    const $pre = document.getElementById('AmazonOrderHistory') || document.createElement('pre');
    $form.parentNode.insertBefore($pre, $form);
    $pre.id = 'AmazonOrderHistory';
    $pre.style.maxWidth = '100%';
    $pre.style.maxHeight = '30vh';
    $pre.style.overflow = 'auto';
    $pre.textContent = `// total: ${storageOrders.length}\n`
      + columns.map(k => `"${k}"`).join(",") + '\n'
      + storageOrders.map(toRow).join('') + '\n';

    if (found > 0) {
      storageOrders.sort((a, b) => b.ts - a.ts);
      localStorage.setItem('AmazonOrderHistory', JSON.stringify(storageOrders));
      const $nextPage = document.querySelector('.a-pagination .a-last a');
      if ($nextPage) $nextPage.click();
    }
  }
  catch (err) {
    console.error('safari/amazon.co.jp.js', err);
  }

  function parseDate(raw) {
    if (raw.match(/^\d{4}-\d{2}-\d{2}$/)) return raw;
    const months = ['jan', 'feb', 'mar', 'apr', 'may', 'june', 'july', 'aug', 'sept', 'oct', 'nov', 'dec'];
    const monthRe = new RegExp(months.join('|'), 'i');
    const date = [];
    let parse = raw;
    parse = parse.replace(/\b(\d{1,2})\b/, (d) => date.push(d.padStart(2, '0')));
    parse = parse.replace(monthRe, (m) => date.push(String(months.findIndex(name => name === m.toLowerCase()) + 1).padStart(2, '0')));
    parse = parse.replace(/2\d\d\d/, (y) => date.push(y));
    return date.length === 3 ? `${date[2]}-${date[1]}-${date[0]}` : raw.replace(/[,.]/g, '');
  }

  function toRow(order) {
    return '"' + columns.map(k => String(order[k]).replace(/["']/g, '')).join('","') + '"\n';
  }
});
