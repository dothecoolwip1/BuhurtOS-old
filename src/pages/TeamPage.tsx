import { Link, useParams } from 'react-router-dom';
import { getHacsaTeam } from '../data/hacsaTeams';
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
  const team=getHacsaTeam(teamId);

  if(!team){
    return <div className="state-card">
      <h2>Team not found</h2>
      <p>This team is not in the current HACSA source snapshot.</p>
      <Link className="show-btn secondary" to="/teams">Back to HACSA teams</Link>
    </div>;
  }

  return <>
    <div className="show-profile-hero team official-team-hero">
      <div className="show-team-logo-xl">{initials(team.name)}</div>
      <div className="grow">
        <span className="eyebrow">HACSA OFFICIAL DIRECTORY</span>
        <h1>{team.name}</h1>
        <p>{team.location}</p>
        <div className="show-inline-pills"><Pill tone="green">Source-backed</Pill><Pill>Verified {team.verifiedAt}</Pill></div>
      </div>
      <a className="show-btn secondary" href={team.sourceUrl} target="_blank" rel="noopener noreferrer">View source ↗</a>
    </div>

    <div className="show-two-col wide-left">
      <div className="show-stack">
        <Panel title="Official HACSA information" subtitle="Only fields published by HACSA are shown as source facts.">
          <div className="show-detail-rows">
            <div><span>Team</span><b>{team.name}</b></div>
            <div><span>Location</span><b>{team.location}</b></div>
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
          {team.contactUrl?<a className="show-btn secondary full" href={team.contactUrl} target="_blank" rel="noopener noreferrer">Team contact ↗</a>:null}
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
