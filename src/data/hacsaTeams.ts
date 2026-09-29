export type TeamSourceStatus = 'current' | 'next';

export type ExternalTeamSource = {
  id: 'hacsa' | 'bi-teams' | 'bi-ranking';
  label: string;
  url: string;
  status: TeamSourceStatus;
  priority: number;
};

export type HacsaTeam = {
  id: string;
  name: string;
  location: string;
  email: string;
  websiteUrl?: string;
  contactUrl?: string;
  continentCode: 'NA';
  continentName: 'North America';
  countryCode: 'CA';
  countryName: 'Canada';
  adminAreaCode: 'AB' | 'BC' | 'MB' | 'SK';
  adminAreaName: 'Alberta' | 'British Columbia' | 'Manitoba' | 'Saskatchewan';
  sourceId: 'hacsa';
  sourceUrl: string;
  verifiedAt: string;
};

export const externalTeamSources: ExternalTeamSource[] = [
  {
    id: 'hacsa',
    label: 'HACSA Teams',
    url: 'https://www.hacsacanada.com/teams',
    status: 'current',
    priority: 1
  },
  {
    id: 'bi-teams',
    label: 'Buhurt International Teams',
    url: 'https://www.buhurtinternational.com/teams',
    status: 'current',
    priority: 2
  },
  {
    id: 'bi-ranking',
    label: 'Buhurt International Official Ranking',
    url: 'https://www.buhurtinternational.com/ranking',
    status: 'next',
    priority: 3
  }
];

const HACSA_SOURCE = 'https://www.hacsacanada.com/teams';
const VERIFIED_AT = '2026-09-29';

export const hacsaTeams: HacsaTeam[] = [
  {
    id: 'silver-gryphons',
    name: 'The Company of the Silver Gryphons',
    location: 'Calgary (North)',
    email: 'SilverGryphons@hacsacanada.com',
    contactUrl: 'https://www.facebook.com/mike.diaz.779',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'horde',
    name: 'Horde',
    location: 'Drayton Valley',
    email: 'brozell.br@gmail.com',
    contactUrl: 'https://m.me/.billy.rozell',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'crimson-blades',
    name: 'The Crimson Blades',
    location: 'West Edmonton',
    email: 'info@hacsacanada.com',
    contactUrl: 'https://m.me/.george.soika',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'black-spears',
    name: 'The Company of the Black Spears',
    location: 'Lethbridge',
    email: 'lethbridgeblackspears@gmail.com',
    contactUrl: 'https://m.me/.brian.boisson.9',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'mace-company-manitoba',
    name: 'Mace Company Manitoba',
    location: 'Winnipeg',
    email: 'macecompanymanitoba@gmail.com',
    websiteUrl: 'https://macecompany.ca',
    contactUrl: 'https://www.facebook.com/profile.php?id=61586808193807',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'MB',
    adminAreaName: 'Manitoba',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'reavers',
    name: 'Reavers',
    location: 'Red Deer',
    email: 'kedrixx.streit@gmail.com',
    contactUrl: 'https://www.facebook.com/profile.php?id=100081119922743&mibextid=ZbWKwL',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'oath-bearers',
    name: 'The Oath Bearers',
    location: 'Regina',
    email: 'Duster18@hotmail.com',
    contactUrl: 'https://m.me/.patrick.c.depaulo',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'SK',
    adminAreaName: 'Saskatchewan',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'vanguard',
    name: 'Vanguard',
    location: 'Vancouver',
    email: 'vancityvanguard@gmail.com',
    contactUrl: 'https://m.me/.josh.caldwellmaki',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'BC',
    adminAreaName: 'British Columbia',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'strathcona-warhorse',
    name: 'Strathcona Warhorse',
    location: 'East Edmonton',
    email: 'strathconawarhorse@gmail.com',
    contactUrl: 'https://www.facebook.com/profile.php?id=100009466462258&mibextid=ZbWKwL',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  },
  {
    id: 'arverni-legion',
    name: 'Arverni Legion',
    location: 'Alberta Foothills',
    email: 'Arverni_legion@outlook.com',
    contactUrl: 'https://m.me/.rneilson31',
    continentCode: 'NA',
    continentName: 'North America',
    countryCode: 'CA',
    countryName: 'Canada',
    adminAreaCode: 'AB',
    adminAreaName: 'Alberta',
    sourceId: 'hacsa',
    sourceUrl: HACSA_SOURCE,
    verifiedAt: VERIFIED_AT
  }
];

export function getHacsaTeam(teamId: string) {
  return hacsaTeams.find(team => team.id === teamId);
}
