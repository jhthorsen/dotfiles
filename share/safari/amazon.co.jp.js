(function() {
  const columns = ['date', 'id', 'total', 'order', 'img', 'url', 'desc'];
  const months = ['jan', 'feb', 'mar', 'apr', 'may', 'june', 'july', 'aug', 'sept', 'oct', 'nov', 'dec'];

  const $orders = document.querySelectorAll('.js-order-card');
  const orders = JSON.parse(localStorage.getItem('AmazonOrderHistory') || '[]');
  const monthRe = new RegExp(months.join('|'), 'i');
  const rowSeen = new Set();
  const before = orders.length;

  for (const $order of $orders) {
    const $total = $order.querySelector('.yohtmlc-order-total');
    if (!$total) continue;

    const $orderPlaced = $order.querySelector('.a-size-base .a-color-secondary');
    const $orderId = $order.querySelector('.yohtmlc-order-id');
    const $itemLinks = $order.querySelectorAll('.yohtmlc-item a');
    const $orderLink = $order.querySelector('a[href*="/order-details/"]')
                    || $order.querySelector('a[href*="/order-summary"]')

    const id = $orderId.textContent.replace(/.*#\s*/, '').trim(); // Remove "ORDER #"
    const total = $total.textContent.trim().replace(/\s*\w+\s+/, '').replace(/[,.]/g, ''); // Remove "TOTAL"

    if (!$orderLink) throw 'Could not find $orderLink for ' + id;

    for (const $itemLink of $itemLinks) {
      if ($itemLink.href.indexOf('/product/') == -1) continue;

      const url = $itemLink.href;
      const row = orders.filter(o => o.id === id && o.url === url)[0] || {};
      const $img = $itemLink.closest('.a-fixed-left-grid').querySelector('img[src*="/images/"]');

      if (!row.id) orders.push(row);
      row.date = $orderPlaced.textContent.trim();
      row.desc = $itemLink.textContent.trim();
      row.id = id;
      row.img = $img.src;
      row.total = total.replace(/\D/g, '');
      row.order = $orderLink.href;
      row.url = url;
    }
  }

  if ($orders.length) {
    localStorage.setItem('AmazonOrderHistory', JSON.stringify(orders));

    const $pre = document.getElementById('AmazonOrderHistory') || document.createElement('pre');
    $orders[0].parentNode.insertBefore($pre, $orders[0]);

    $pre.id = 'AmazonOrderHistory';
    $pre.style.maxWidth = '100%';
    $pre.style.maxHeight = '30vh';
    $pre.style.overflow = 'auto';
    $pre.textContent = `// total: ${orders.length}\n` + toRow(columns) + orders.map(orderToRow).join('') + '\n';
  }

  if (before < orders.length) {
    const $nextPage = document.querySelector('.a-pagination .a-last a');
    if ($nextPage) $nextPage.click();
  }

  function orderToRow(order) {
    if (rowSeen.has(order.id)) order.total = '0';
    rowSeen.add(order.id);
    order.date = parseDate(order.date);
    return toRow(columns.map(k => order[k]));
  }

  function parseDate(raw) {
    if (raw.match(/^\d{4}-\d{2}-\d{2}$/)) return raw;
    const date = [];
    let parse = raw;
    parse = parse.replace(/2\d\d\d/, (y) => date.push(y));
    parse = parse.replace(monthRe, (m) => date.push(String(months.findIndex(name => name === m.toLowerCase()) + 1).padStart(2, '0')));
    parse = parse.replace(/\b(\d{1,2})\b/, (d) => date.push(d.padStart(2, '0')));
    return date.length === 3 ? date.join('-') : raw.replace(/[,.]/g, '');
  }

  function toRow(columns) {
    return '"' + columns.map(c => String(c).replace(/["']/g, '')).join('","') + '"\n';
  }
})();
