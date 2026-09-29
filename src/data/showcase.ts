export type DemoTeam = {
  id: string;
  name: string;
  shortName: string;
  region: string;
  city: string;
  status: 'active' | 'forming';
  logoText: string;
  color: string;
  captain: string;
  members: number;
  founded: string;
  bio: string;
  socials?: Array<{ label: string; url: string }>;
  seasonResults?: Array<{ event: string; result: string }>;
};

export type DemoFighter = {
  id: string;
  name: string;
  fighterName: string;
  teamId: string;
  region: string;
  categories: string[];
  record: { wins: number; losses: number; draws: number };
  seasonRecord: { wins: number; losses: number; draws: number };
  podiums: number;
  events: number;
  rank: number;
  status: 'Active' | 'Medical hold' | 'Inactive';
  bio: string;
  achievements: string[];
  photoTone: string;
  weightClass?: string;
  experienceYears?: number;
  experienceLevel?: 'Rising' | 'Experienced' | 'Veteran' | 'Elite';
  socials?: Array<{ label: string; url: string }>;
  tournamentHistory?: Array<{ year: string; event: string; category: string; placement: string }>;
};

export type DemoEvent = {
  id: string;
  name: string;
  date: string;
  venue: string;
  city: string;
  status: 'Live' | 'Registration Open' | 'Draft' | 'Complete';
  sanctioning: string;
  host: string;
  ruleset: string;
  teams: number;
  fighters: number;
  fields: number;
  registrations: number;
};

export const demoTeams: DemoTeam[] = [
  {
    id: 'reavers',
    name: 'Red Deer Reavers',
    shortName: 'RDR',
    region: 'Central Alberta',
    city: 'Red Deer, AB',
    status: 'active',
    logoText: 'RR',
    color: '#8b5cf6',
    captain: 'Garrett Robson',
    members: 14,
    founded: '2024',
    bio: 'Central Alberta armored combat team competing across duel and melee formats.',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/reddeerreavers.demo' },
      { label: 'Facebook', url: 'https://facebook.com/reddeerreavers.demo' }
    ],
    seasonResults: [
      { event: 'HACSA Winter Melee', result: '1st — 5v5' },
      { event: 'Prairie Cup', result: '2nd — mixed' },
      { event: 'Alberta Invitational', result: '2nd — team duel' },
      { event: 'HACSA Spring Open', result: '3rd — 5v5' },
      { event: 'Northern Cup', result: '3rd — mixed' },
      { event: 'HACSA Summer Clash', result: '4th — 12v12' }
    ]
  },
  {
    id: 'iron-wolves',
    name: 'Iron Wolves',
    shortName: 'IW',
    region: 'Southern Alberta',
    city: 'Calgary, AB',
    status: 'active',
    logoText: 'IW',
    color: '#f59e0b',
    captain: 'Mason Clarke',
    members: 18,
    founded: '2019',
    bio: 'Demo team used in the BuhurtOS frontend prototype.',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/ironwolves.demo' },
      { label: 'YouTube', url: 'https://youtube.com/@ironwolves.demo' }
    ],
    seasonResults: [
      { event: 'HACSA Spring Open', result: '1st — 5v5' },
      { event: 'Prairie Cup', result: '2nd — mixed' },
      { event: 'HACSA Winter Melee', result: '3rd — 5v5' },
      { event: 'Alberta Invitational', result: '4th — team duel' }
    ]
  },
  {
    id: 'vanguard',
    name: 'Northern Vanguard',
    shortName: 'NV',
    region: 'Northern Alberta',
    city: 'Edmonton, AB',
    status: 'active',
    logoText: 'NV',
    color: '#38bdf8',
    captain: 'Alex Morgan',
    members: 11,
    founded: '2022',
    bio: 'Demo team used in the BuhurtOS frontend prototype.',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/northernvanguard.demo' },
      { label: 'Facebook', url: 'https://facebook.com/northernvanguard.demo' }
    ],
    seasonResults: [
      { event: 'Northern Cup', result: '1st — 5v5' },
      { event: 'HACSA Spring Open', result: '2nd — 5v5' },
      { event: 'Prairie Cup', result: '3rd — mixed' },
      { event: 'HACSA Summer Clash', result: '3rd — 12v12' }
    ]
  },
  {
    id: 'badlands',
    name: 'Badlands Forge',
    shortName: 'BF',
    region: 'Eastern Alberta',
    city: 'Drumheller, AB',
    status: 'forming',
    logoText: 'BF',
    color: '#fb7185',
    captain: 'Pending',
    members: 6,
    founded: '2026',
    bio: 'A forming demo team awaiting full organization approval.'
  }
];

export const demoFighters: DemoFighter[] = [
  {
    id: 'bob',
    name: 'Bob Mercer',
    fighterName: 'Bob “Bear” Mercer',
    teamId: 'reavers',
    region: 'Central Alberta',
    categories: ['Longsword', 'Sword & Buckler', '5v5'],
    record: { wins: 27, losses: 9, draws: 1 },
    seasonRecord: { wins: 8, losses: 2, draws: 0 },
    podiums: 6,
    events: 12,
    rank: 3,
    status: 'Active',
    bio: 'Heavy-hitting duel and melee fighter who prefers close pressure and long exchanges.',
    achievements: ['2026 Spring Open — Gold', '2026 Prairie Cup — Silver', '5v5 Team Captain Award'],
    photoTone: 'ember',
    weightClass: 'Up to 95 kg',
    experienceYears: 6,
    experienceLevel: 'Veteran',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/bobmercer.demo' },
      { label: 'YouTube', url: 'https://youtube.com/@bearmercer.demo' }
    ],
    tournamentHistory: [
      { year: '2026', event: 'HACSA Spring Open', category: 'Longsword', placement: 'Gold' },
      { year: '2026', event: 'Prairie Cup', category: 'Longsword', placement: 'Silver' },
      { year: '2025', event: 'HACSA Summer Clash', category: '5v5', placement: 'Semifinalist' },
      { year: '2025', event: 'Northern Cup', category: 'Longsword', placement: 'Quarterfinalist' }
    ]
  },
  {
    id: 'garrett',
    name: 'Garrett Robson',
    fighterName: 'Garrett Robson',
    teamId: 'reavers',
    region: 'Central Alberta',
    categories: ['Longsword', 'Polearm', '5v5'],
    record: { wins: 18, losses: 8, draws: 1 },
    seasonRecord: { wins: 5, losses: 2, draws: 0 },
    podiums: 3,
    events: 9,
    rank: 7,
    status: 'Active',
    bio: 'Reavers captain and multi-format competitor.',
    achievements: ['2026 Alberta Invitational — Bronze', 'Team Captain — Red Deer Reavers'],
    photoTone: 'violet',
    weightClass: 'Up to 80 kg',
    experienceYears: 4,
    experienceLevel: 'Experienced',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/garrettrobson.demo' }
    ],
    tournamentHistory: [
      { year: '2026', event: 'Alberta Invitational', category: 'Polearm', placement: 'Bronze' },
      { year: '2026', event: 'HACSA Winter Melee', category: '5v5', placement: 'Winner' },
      { year: '2025', event: 'Prairie Cup', category: 'Longsword', placement: 'Quarterfinalist' }
    ]
  },
  {
    id: 'kolby',
    name: 'Kolby H.',
    fighterName: 'Kolby H.',
    teamId: 'reavers',
    region: 'Central Alberta',
    categories: ['Longsword', 'Sword & Shield'],
    record: { wins: 31, losses: 11, draws: 0 },
    seasonRecord: { wins: 9, losses: 3, draws: 0 },
    podiums: 8,
    events: 15,
    rank: 2,
    status: 'Active',
    bio: 'Experienced duel competitor with strong tournament results.',
    achievements: ['Team Canada qualifier — Silver', 'Multiple regional podiums'],
    photoTone: 'steel',
    weightClass: 'Up to 95 kg',
    experienceYears: 8,
    experienceLevel: 'Elite',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/kolbyh.demo' },
      { label: 'X', url: 'https://x.com/kolbyh.demo' }
    ],
    tournamentHistory: [
      { year: '2026', event: 'Team Canada Qualifier', category: 'Longsword', placement: 'Silver' },
      { year: '2026', event: 'Prairie Cup', category: 'Longsword', placement: 'Gold' },
      { year: '2025', event: 'HACSA Winter Melee', category: 'Sword & Shield', placement: 'Winner' },
      { year: '2025', event: 'HACSA Summer Clash', category: 'Longsword', placement: 'Semifinalist' }
    ]
  },
  {
    id: 'alex',
    name: 'Alex Morgan',
    fighterName: 'Alex Morgan',
    teamId: 'vanguard',
    region: 'Northern Alberta',
    categories: ['Sword & Buckler', '5v5'],
    record: { wins: 22, losses: 13, draws: 2 },
    seasonRecord: { wins: 6, losses: 4, draws: 0 },
    podiums: 4,
    events: 13,
    rank: 6,
    status: 'Active',
    bio: 'Fast-paced fighter with a focus on Sword & Buckler.',
    achievements: ['2026 Northern Cup — Gold'],
    photoTone: 'blue',
    weightClass: 'Up to 85 kg',
    experienceYears: 3,
    experienceLevel: 'Rising',
    socials: [
      { label: 'Instagram', url: 'https://instagram.com/alexmorgan.demo' },
      { label: 'Facebook', url: 'https://facebook.com/alexmorgan.demo' }
    ],
    tournamentHistory: [
      { year: '2026', event: 'Northern Cup', category: 'Sword & Buckler', placement: 'Gold' },
      { year: '2025', event: 'HACSA Fall Open', category: 'Sword & Buckler', placement: 'Semifinalist' },
      { year: '2025', event: 'Alberta Invitational', category: 'Sword & Buckler', placement: 'Quarterfinalist' }
    ]
  }
];

export const demoEvents: DemoEvent[] = [
  {
    id: 'fall-open',
    name: 'HACSA Fall Open',
    date: 'Sep 26–27, 2026',
    venue: 'Springbrook Event Centre',
    city: 'Springbrook, AB',
    status: 'Live',
    sanctioning: 'HACSA',
    host: 'HACSA',
    ruleset: 'HACSA 2026.3 • BI based',
    teams: 8,
    fighters: 64,
    fields: 3,
    registrations: 71
  },
  {
    id: 'winter-clash',
    name: 'Winter Clash',
    date: 'Nov 14, 2026',
    venue: 'Calgary Combat Hall',
    city: 'Calgary, AB',
    status: 'Registration Open',
    sanctioning: 'HACSA',
    host: 'Iron Wolves',
    ruleset: 'HACSA 2026.3 • BI based',
    teams: 6,
    fighters: 39,
    fields: 2,
    registrations: 43
  },
  {
    id: 'championship',
    name: '2027 HACSA Championship',
    date: 'Mar 20–21, 2027',
    venue: 'TBD',
    city: 'Alberta',
    status: 'Draft',
    sanctioning: 'HACSA',
    host: 'HACSA',
    ruleset: 'HACSA 2027 Draft',
    teams: 0,
    fighters: 0,
    fields: 4,
    registrations: 0
  }
];

export const liveMatches = [
  { id:'m17', field:'Field 1', division:'5v5', round:'Pool A • Round 2', left:'Red Deer Reavers', right:'Northern Vanguard', leftScore:1, rightScore:0, state:'LIVE', clock:'00:42' },
  { id:'m31', field:'Field 2', division:'Longsword', round:'Quarterfinal', left:'Bob Mercer', right:'Alex Morgan', leftScore:7, rightScore:5, state:'LIVE', clock:'00:18' },
  { id:'m44', field:'Field 3', division:'Sword & Buckler', round:'Pool C', left:'Kolby H.', right:'Mason Clarke', leftScore:1, rightScore:1, state:'LIVE', clock:'R3' }
];

export const upcomingMatches = [
  { time:'2:35 PM', field:'Field 1', division:'5v5', left:'Iron Wolves', right:'Badlands Forge' },
  { time:'2:38 PM', field:'Field 2', division:'Longsword', left:'Garrett Robson', right:'Evan Cole' },
  { time:'2:41 PM', field:'Field 3', division:'Sword & Buckler', left:'Jamie R.', right:'Chris T.' },
  { time:'2:47 PM', field:'Field 1', division:'5v5', left:'Red Deer Reavers', right:'Iron Wolves' }
];

export const demoRulesets = [
  { id:'hacsa-2026-3', name:'HACSA Rules 2026.3', publisher:'HACSA', base:'BI rules with HACSA amendments', status:'Active', effective:'Aug 1, 2026', formats:12 },
  { id:'bi-2026', name:'BI International Rules 2026', publisher:'Buhurt International', base:'International', status:'Recognized', effective:'Jan 1, 2026', formats:14 },
  { id:'imcf-2025', name:'IMCF Rules 2025', publisher:'IMCF', base:'Historical', status:'Historical', effective:'Jan 1, 2025', formats:10 },
  { id:'hacsa-2027', name:'HACSA Rules 2027', publisher:'HACSA', base:'Draft next season', status:'Draft', effective:'Jan 1, 2027', formats:14 }
];

export const seasonRankings = [
  { rank:1, fighter:'Kolby H.', team:'Red Deer Reavers', category:'Longsword', points:860, change:'—' },
  { rank:2, fighter:'Mason Clarke', team:'Iron Wolves', category:'Longsword', points:815, change:'↑1' },
  { rank:3, fighter:'Bob Mercer', team:'Red Deer Reavers', category:'Longsword', points:790, change:'↓1' },
  { rank:4, fighter:'Alex Morgan', team:'Northern Vanguard', category:'Longsword', points:735, change:'↑2' },
  { rank:5, fighter:'Garrett Robson', team:'Red Deer Reavers', category:'Longsword', points:704, change:'—' }
];
