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
walk(path.join(root,'src'));
if(bad.length){
  console.error('Navigation audit failed:\n'+[...new Set(bad)].map(x=>' - '+x).join('\n'));
  process.exit(1);
}
console.log('Navigation audit passed.');
