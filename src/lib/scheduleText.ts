export interface ScheduleRow {
  time: string;
  area: string;
  label: string;
  side1: string;
  side2: string;
  status?: string;
}

/** Groups rows by area in first-seen order, keeping each area's own order. */
export function groupRowsByArea(rows: ScheduleRow[]): Array<{ area: string; rows: ScheduleRow[] }> {
  const groups = new Map<string, ScheduleRow[]>();
  for (const row of rows) {
    const key = row.area || 'Unassigned';
    groups.set(key, [...(groups.get(key) ?? []), row]);
  }
  return [...groups.entries()].map(([area, list]) => ({ area, rows: list }));
}

/** Plain text that pastes cleanly into a group chat or a social post. */
export function scheduleAsText(title: string, rows: ScheduleRow[]): string {
  const lines = [title, ''];
  for (const group of groupRowsByArea(rows)) {
    lines.push(group.area);
    for (const row of group.rows) {
      lines.push(`${row.time ? row.time + '  ' : ''}${row.label}: ${row.side1} vs ${row.side2}`);
    }
    lines.push('');
  }
  return lines.join('\n').trimEnd() + '\n';
}
