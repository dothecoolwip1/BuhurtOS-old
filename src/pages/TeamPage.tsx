import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { hacsaFallbackDirectory, loadPublicTeamDirectory, type PublicDirectoryTeam } from '../lib/teamDirectory';
import { Panel, Pill } from '../components/ShowcaseUI';

function initials(name: string) {
  return name
    .replace(/^The\s+/i, '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 3)
    .map(part => part[0]?.toUpperCase())
    .join('');
}

export function TeamPage(){
  const {teamId='reavers'}=useParams();
  const [team,setTeam]=useState<PublicDirectoryTeam|undefined>(()=>hacsaFallbackDirectory().find(item=>item.slug===teamId));

  useEffect(()=>{
    let active=true;
    loadPublicTeamDirectory({ organizationShortName:'HACSA', teamSlug:teamId })
      .then(rows=>{if(active&&rows[0])setTeam(rows[0]);})
      .catch(()=>{});
    return ()=>{active=false;};
  },[teamId]);

  if(!team){
    return <div className="state-card">
      <h2>Team not found</h2>
      <p>This team is not in the current HACSA source directory.</p>
      <Link className="show-btn secondary" to="/teams">Back to HACSA teams</Link>
    </div>;
  }

  return <>
    <div className="show-profile-hero team official-team-hero">
      <div className="show-team-logo-xl">{initials(team.name)}</div>
      <div className="grow">
        <span className="eyebrow">HACSA OFFICIAL DIRECTORY</span>
        <h1>{team.name}</h1>
        <p>{team.location} · {team.adminAreaName}, {team.countryName}</p>
        <div className="show-inline-pills"><Pill tone="green">Source-backed</Pill><Pill>Verified {team.verifiedAt}</Pill></div>
      </div>
      <a className="show-btn secondary" href={team.sourceUrl} target="_blank" rel="noopener noreferrer">View source ↗</a>
    </div>

    <div className="directory-hierarchy compact" aria-label="Team geography">
      <strong>{team.organizationShortName}</strong><span>›</span><b>{team.continentName}</b><span>›</span><b>{team.countryName}</b><span>›</span><b>{team.adminAreaName}</b>
    </div>

    <div className="show-two-col wide-left">
      <div className="show-stack">
        <Panel title="Official HACSA information" subtitle="Only fields published by HACSA are shown as source facts. Province/country hierarchy is normalized for directory browsing.">
          <div className="show-detail-rows">
            <div><span>Team</span><b>{team.name}</b></div>
            <div><span>Published location</span><b>{team.location}</b></div>
            <div><span>Province</span><b>{team.adminAreaName}</b></div>
            <div><span>Country</span><b>{team.countryName}</b></div>
            <div><span>Continent</span><b>{team.continentName}</b></div>
            <div><span>Public email</span><a href={`mailto:${team.email}`}>{team.email}</a></div>
            <div><span>Source checked</span><b>{team.verifiedAt}</b></div>
          </div>
        </Panel>

        <Panel title="BuhurtOS team record">
          <div className="source-empty-state">
            <strong>No invented roster or statistics</strong>
            <p>HACSA's public team directory does not publish a roster, member count, founding year or competition record for this listing. BuhurtOS will attach those fields only when they come from an approved source or from the team itself.</p>
          </div>
        </Panel>
      </div>

      <div className="show-stack">
        <Panel title="Contact">
          <a className="show-btn primary full" href={`mailto:${team.email}`}>Email team</a>
          {team.websiteUrl?<a className="show-btn secondary full" href={team.websiteUrl} target="_blank" rel="noopener noreferrer">Team website ↗</a>:null}
          {team.contactUrl?<a className="show-btn secondary full" href={team.contactUrl} target="_blank" rel="noopener noreferrer">HACSA contact link ↗</a>:null}
        </Panel>
        <Panel title="Source priority">
          <div className="source-priority-list">
            <div className="active"><span>1</span><div><b>HACSA Teams</b><small>Current primary source</small></div></div>
            <div><span>2</span><div><b>BI Teams</b><small>Next integration</small></div></div>
            <div><span>3</span><div><b>BI Official Ranking</b><small>Ranking and competition enrichment</small></div></div>
          </div>
        </Panel>
      </div>
    </div>
  </>;
}
