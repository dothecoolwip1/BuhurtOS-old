import { describe, expect, test } from 'vitest';
import { buildTournamentPreview, seedTournamentEntries, validateTournamentPlan } from '../src/lib/tournamentGeneration';
import { computePoolQualificationState, generateRoundRobinPools } from '../src/lib/bracket';
import type { RosterEntry } from '../src/types';

const roster = (id:string,name:string,teamId?:string):RosterEntry => ({
  id,
  organizationId:'org',
  eventId:'event',
  teamId,
  entryType:'fighter',
  displayName:name,
  checkedIn:true,
  armorCleared:true,
  medicalCleared:true,
  waiverConfirmed:true,
  weighInCleared:true,
  competitionCleared:true,
  attendanceStatus:'approved'
});

const entries=[
  roster('00000000-0000-4000-8000-000000000001','Alpha','red'),
  roster('00000000-0000-4000-8000-000000000002','Bravo','red'),
  roster('00000000-0000-4000-8000-000000000003','Charlie','blue'),
  roster('00000000-0000-4000-8000-000000000004','Delta','green'),
  roster('00000000-0000-4000-8000-000000000005','Echo','yellow')
];

const base={
  organizationId:'10000000-0000-4000-8000-000000000001',
  seasonId:'10000000-0000-4000-8000-000000000002',
  eventId:'10000000-0000-4000-8000-000000000003',
  bracketId:'10000000-0000-4000-8000-000000000004',
  category:'Longsword',
  matchType:'longsword',
  scoringConfig:{kind:'duel' as const,roundsRequired:3,allowDrawRound:false},
  format:'single_elimination' as const,
  entries,
  antiFratricide:true
};

describe('Pack 7 tournament generation',()=>{
  test('replays the same recorded random draw with stable match IDs',()=>{
    const first=buildTournamentPreview({...base,seeding:{method:'random',randomSeed:'RED-DEER-2026'}});
    const second=buildTournamentPreview({...base,seeding:{method:'random',randomSeed:'RED-DEER-2026'}});
    expect(first.seededEntries.map(item=>item.entry.id)).toEqual(second.seededEntries.map(item=>item.entry.id));
    expect(first.plan.matches.map(match=>match.id)).toEqual(second.plan.matches.map(match=>match.id));
    expect(first.generationHash).toBe(second.generationHash);
  });

  test('changes the draw when the recorded random seed changes',()=>{
    const first=buildTournamentPreview({...base,seeding:{method:'random',randomSeed:'DRAW-A'}});
    const second=buildTournamentPreview({...base,seeding:{method:'random',randomSeed:'DRAW-B'}});
    expect(first.seededEntries.map(item=>item.entry.id)).not.toEqual(second.seededEntries.map(item=>item.entry.id));
  });

  test('rejects tournament fields smaller than two entrants',()=>{
    expect(()=>seedTournamentEntries([entries[0]],{method:'manual',values:{[entries[0].id]:1}})).toThrow(/at least two competitors/i);
  });

  test('rejects incomplete and ambiguous manual seeding',()=>{
    expect(()=>seedTournamentEntries(entries,{method:'manual',values:{}})).toThrow(/every selected competitor/i);
    const duplicate=Object.fromEntries(entries.map((entry,index)=>[entry.id,index<2?1:index+1]));
    expect(()=>seedTournamentEntries(entries,{method:'manual',values:duplicate})).toThrow(/must be unique/i);
  });

  test('records ranking ties but resolves them reproducibly',()=>{
    const values=Object.fromEntries(entries.map((entry,index)=>[entry.id,index<2?100:90-index]));
    const seeded=seedTournamentEntries(entries,{method:'ranking',values});
    expect(seeded.warnings.some(item=>item.includes('Tied ranking value 100'))).toBe(true);
    const tied=seeded.entries.filter(item=>values[item.entry.id]===100);
    expect(tied.map(item=>item.entry.id)).toEqual([...tied.map(item=>item.entry.id)].sort());
  });

  test('rejects invalid dependencies and duplicate competitors inside a match',()=>{
    const preview=buildTournamentPreview({...base,seeding:{method:'manual',values:Object.fromEntries(entries.map((entry,index)=>[entry.id,index+1]))}});
    const broken=structuredClone(preview.plan);
    broken.matches[0].winnerAdvancesToMatchId='99999999-9999-4999-8999-999999999999';
    broken.matches[0].participants=[
      {rosterEntryId:entries[0].id,sideIndex:1},
      {rosterEntryId:entries[0].id,sideIndex:2}
    ];
    const result=validateTournamentPlan(broken,entries.map(entry=>entry.id));
    expect(result.valid).toBe(false);
    expect(result.errors.some(item=>/missing match dependency/i.test(item))).toBe(true);
    expect(result.errors.some(item=>/same competitor/i.test(item))).toBe(true);
  });

  test('uses published seed as the final pool tiebreak and excludes withdrawn qualifiers',()=>{
    const poolEntries=entries.slice(0,4).map((entry,index)=>({entry,seed:index+1}));
    const pools=generateRoundRobinPools({
      organizationId:'org',
      seasonId:'season',
      eventId:'event',
      bracketId:'pool-bracket',
      category:'Longsword',
      matchType:'longsword',
      entries:poolEntries,
      scoringConfig:{kind:'duel',roundsRequired:1,allowDrawRound:true},
      targetPoolSize:4
    });
    const completed=pools.matches.map(match=>({
      ...match,
      status:'finalized' as const,
      resultSummary:{
        winnerSide:null,
        side1Total:1,
        side2Total:1,
        roundsWonSide1:0,
        roundsWonSide2:0,
        resultType:'draw' as const
      }
    }));
    const ranked=computePoolQualificationState(completed,entries,'pool-bracket',2);
    expect(ranked.ready).toBe(true);
    expect(ranked.pools[0].standings.map(row=>row.seed)).toEqual([1,2,3,4]);
    const withdrawn=entries.map(entry=>entry.id===ranked.qualifiers[0].entry.id?{...entry,attendanceStatus:'withdrawn' as const}:entry);
    const reranked=computePoolQualificationState(completed,withdrawn,'pool-bracket',2);
    expect(reranked.qualifiers.map(item=>item.entry.attendanceStatus)).not.toContain('withdrawn');
  });
});
