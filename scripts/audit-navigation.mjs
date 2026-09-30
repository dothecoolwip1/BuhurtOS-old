import fs from 'node:fs';
import path from 'node:path';

const root=process.cwd();
const bad=[];
const forbidden=[
  {re:/href=["']#(?!https?:)/g,why:'Hash anchors break HashRouter navigation; use scrollIntoView.'},
  {re:/\/events\/(?:fall-open|winter-clash)\b/g,why:'Old demo event link.'},
  {re:/\/fighters\/bob\b/g,why:'Old demo fighter link.'},
  {re:/to=["']\/home["']/g,why:'Legacy prototype route; use /public.'},
  {re:/href=["']#\/teams\//g,why:'Raw hash deep link; use router Link or ?go=.'}
];

function walk(dir){
  for(const entry of fs.readdirSync(dir,{withFileTypes:true})){
    const full=path.join(dir,entry.name);
    if(entry.isDirectory())walk(full);
    else if(/\.(tsx|ts)$/.test(entry.name)){
      if(full.endsWith(path.join('pages','ShowcaseDashboard.tsx'))) continue;
      const text=fs.readFileSync(full,'utf8');
      for(const rule of forbidden){
        if(rule.re.test(text))bad.push(path.relative(root,full)+': '+rule.why);
        rule.re.lastIndex=0;
      }
      if(entry.name.endsWith('.tsx')){
        const buttonRe=/<button\b([^>]*)>/g;
        let m;
        while((m=buttonRe.exec(text))){
          const attrs=m[1];
          if(!/onClick=|type=["']submit["']|form=/.test(attrs) && !/disabled/.test(attrs)){
            bad.push(path.relative(root,full)+': button without an obvious action handler.');
          }
        }
      }
    }
  }
}

const appSource=fs.readFileSync(path.join(root,'src','App.tsx'),'utf8');
const mainSource=fs.readFileSync(path.join(root,'src','main.tsx'),'utf8');
const requiredRoutes=[
  'path="/"',
  'path="/public"',
  'path="/governance"',
  'path="/organizations/:organizationKey"',
  'path="/teams"',
  'path="/teams/:teamId"',
  'path="/fighters"',
  'path="/fighters/:fighterId"',
  'path="/events"',
  'path="/events/:eventId"',
  'path="/rankings"',
  'path="/rules"',
  'path="/ops/login"',
  'path="platform"',
  'path="codes"',
  'path="manage"',
  'path="signups"'
];
for(const route of requiredRoutes){
  if(!appSource.includes(route))bad.push('src/App.tsx: missing required Pack 1 route '+route+'.');
}
if(appSource.includes('ShowcaseDashboard'))bad.push('src/App.tsx: stale ShowcaseDashboard must remain quarantined from production routing.');
if(!mainSource.includes("params.get('go')")||!mainSource.includes("window.history.replaceState")){
  bad.push('src/main.tsx: public ?go= deep-link bridge is missing.');
}

walk(path.join(root,'src'));
if(bad.length){
  console.error('Navigation audit failed:\n'+[...new Set(bad)].map(x=>' - '+x).join('\n'));
  process.exit(1);
}
console.log('Navigation audit passed.');
