(function() {
  const defaultHours = localStorage.getItem('dotfiles:defaultHours') || '7.5';
  const $rows = document.querySelector('select[name^=TIME_TYPE] option[value="0"]')
    ?.closest('table')
    ?.querySelectorAll('tr');

  if (!$rows) return console.info('No time sheet rows found.');
  let lastTask = '';

  ROW:
  for (const $row of $rows) {
    const dayMatch = $row.textContent.match(/\d{4}-\d{2}-\d{2}\s+(\w+)/);
    if ($row.textContent.indexOf('Extra comment') !== -1) {
      $row.style.display = 'none';
      continue ROW;
    }
    if ($row.textContent.indexOf('Add more') !== -1) {
      $row.style.display = 'none';
      continue ROW;
    }
    if (($row.querySelector('b')?.textContent || '').indexOf('Hours') !== -1) {
      $row.style.display = 'none';
      continue ROW;
    }

    const $activity = $row.querySelector('input[name^=ACTIVITY_]');
    const $hours = $row.querySelector('input[name^=HOURS_]');
    if ($activity && $hours) {
      for (const $td of $row.querySelectorAll('td')) $td.style.paddingTop = '1rem';
      $activity.addEventListener('focus', () => {
        if ($activity.value === '') $activity.value = lastTask;
        if ($activity.value !== '' && $hours.value === '') $hours.value = defaultHours;
      });
      $activity.addEventListener('blur', () => {
        if ($activity.value === '') $hours.value = '';
        if ($activity.value !== '') lastTask = $activity.value;
        if ($activity.value !== '' && $hours.value === '') $hours.value = defaultHours;
      });
    }
  }
})();
