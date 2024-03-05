(function() {
  const primaryTask = localStorage.getItem('primaryTask');
  const $rows = document.querySelector('select[name^=TIME_TYPE] option[value="0"]')
    ?.closest('table')
    ?.querySelectorAll('tr');

  if (!$rows) return console.info('No time sheet rows found.');
  let currentDay = '';

  ROW:
  for (const $row of $rows) {
    const dayMatch = $row.textContent.match(/\d{4}-\d{2}-\d{2}\s+(\w+)/);
    if (dayMatch) {
      for (const $td of $row.querySelectorAll('td')) $td.style.paddingTop = '1rem';
      currentDay = dayMatch[1];
    }

    const $activity = $row.querySelector('input[name^=ACTIVITY_]');
    const $hours = $row.querySelector('input[name^=HOURS_]');
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

    const weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    if (weekDays.some(wd => currentDay === wd)) {
      if ($hours && $hours.value.length === 0) $hours.value = '7.5';
      if ($activity && $activity.value.length === 0) $activity.value = primaryTask || '';
      currentDay = ''; // Make sure we don't fill "Add hours"
    }
  }
})();
