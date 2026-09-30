import type { MatchRecord, RosterEntry } from '../types';
import type { StandingRow, TeamStandingRow } from './standings';

function csvCell(value: unknown): string {
  const text = String(value ?? '');
  return /[",\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

function csv(headers: string[], rows: Array<Array<unknown>>): string {
  return [headers, ...rows].map(row => row.map(csvCell).join(',')).join('\n');
}

export function standingsCsv(rows: StandingRow[]): string {
  const header = ['Rank', 'Competitor', 'Matches', 'Wins', 'Losses', 'Draws', 'Points For', 'Points Against', 'Differential', 'Standing Points'];
  const lines = rows.map((r, index) => [index + 1, r.name, r.matches, r.wins, r.losses, r.draws, r.pointsFor, r.pointsAgainst, r.differential, r.standingPoints]);
  return csv(header, lines);
}

export function teamStandingsCsv(rows: TeamStandingRow[]): string {
  const header = ['Rank', 'Team', 'Fighters', 'Matches', 'Wins', 'Losses', 'Draws', 'Points For', 'Points Against', 'Differential', 'Standing Points'];
  const lines = rows.map((r, index) => [index + 1, r.name, r.fighters, r.matches, r.wins, r.losses, r.draws, r.pointsFor, r.pointsAgainst, r.differential, r.standingPoints]);
  return csv(header, lines);
}

export interface FightCardExportView {
  name: string;
  status: string;
}

export function fightCardCsv(card: FightCardExportView, matches: MatchRecord[]): string {
  const meta = csv(['Field', 'Value'], [
    ['Fight Card', card.name],
    ['Status', card.status],
    ['Matches', String(matches.length)]
  ]);
  return `${meta}\n\n${matchesCsv(matches)}`;
}

export function matchesCsv(matches: MatchRecord[]): string {
  const header = ['Order', 'Label', 'Category', 'Stage', 'Status', 'Winner Side', 'Side 1 Total', 'Side 2 Total'];
  const lines = matches.map(m => [m.scheduledOrder, m.label, m.category, m.stage, m.status, m.resultSummary?.winnerSide ?? '', m.resultSummary?.side1Total ?? '', m.resultSummary?.side2Total ?? '']);
  return csv(header, lines);
}

export interface DisciplineRow {
  name: string;
  color: string;
  reason: string;
  notes?: string;
  issuedAt: string;
}

export function disciplineCsv(cards: DisciplineRow[]): string {
  return csv(
    ['Competitor', 'Color', 'Reason', 'Notes', 'Issued At'],
    cards.map(c => [c.name, c.color, c.reason, c.notes ?? '', new Date(c.issuedAt).toLocaleString()])
  );
}

export interface SuspensionRow {
  name: string;
  reason: string;
  startsAt: string;
  endsAt: string;
  status: string;
  revokedAt?: string | null;
}

export function suspensionsCsv(suspensions: SuspensionRow[]): string {
  return csv(
    ['Competitor', 'Reason', 'Starts', 'Ends', 'Status', 'Revoked At'],
    suspensions.map(s => [
      s.name,
      s.reason,
      new Date(s.startsAt).toLocaleString(),
      new Date(s.endsAt).toLocaleString(),
      s.status,
      s.revokedAt ? new Date(s.revokedAt).toLocaleString() : ''
    ])
  );
}

export function rosterCsv(roster: RosterEntry[]): string {
  return csv(
    ['Competitor', 'Entry Type', 'Attendance', 'Checked In', 'Armor', 'Medical', 'Waiver', 'Weigh In', 'Competition Cleared'],
    roster.map(r => [
      r.displayName,
      r.entryType.replaceAll('_', ' '),
      r.attendanceStatus.replaceAll('_', ' '),
      r.checkedIn ? 'yes' : 'no',
      r.armorCleared ? 'yes' : 'no',
      r.medicalCleared ? 'yes' : 'no',
      r.waiverConfirmed ? 'yes' : 'no',
      r.weighInCleared ? 'yes' : 'no',
      r.competitionCleared ? 'yes' : 'no'
    ])
  );
}

const escapeHtml = (value: unknown) => String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export function htmlTable(headers: Array<string | number>, rows: Array<Array<string | number | boolean>>): string {
  const head = `<thead><tr>${headers.map(h => `<th>${escapeHtml(h)}</th>`).join('')}</tr></thead>`;
  const body = rows.map(row => `<tr>${row.map(cell => `<td>${cell === true ? 'yes' : cell === false ? 'no' : escapeHtml(cell)}</td>`).join('')}</tr>`).join('');
  return `<table>${head}<tbody>${body}</tbody></table>`;
}

export function downloadText(filename: string, content: string, mime = 'text/csv;charset=utf-8'): void {
  const blob = new Blob([content], { type: mime });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export function openPrintableReport(title: string, bodyHtml: string): void {
  const win = window.open('', '_blank', 'noopener,noreferrer');
  if (!win) throw new Error('Pop-up blocked. Allow pop-ups to create the printable report.');
  win.document.write(`<!doctype html><html><head><meta charset="utf-8"><title>${escapeHtml(title)}</title><style>body{font-family:system-ui;padding:32px;color:#111}table{border-collapse:collapse;width:100%}th,td{padding:8px;border-bottom:1px solid #ddd;text-align:left}h1{margin-top:0}@media print{button{display:none}}</style></head><body><button onclick="window.print()">Print / Save PDF</button><h1>${escapeHtml(title)}</h1>${bodyHtml}</body></html>`);
  win.document.close();
}
