import { mkdir, writeFile } from 'node:fs/promises';

const ORIGIN = 'https://www.buhurtinternational.com';
const URL_OUTPUT = new URL('../src/data/biTeamUrls.json', import.meta.url);
const RAW_OUTPUT = new URL('../src/data/biTeamsRaw.json', import.meta.url);
const PROFILE_OUTPUT = new URL('../src/data/biTeamProfilesRaw.json', import.meta.url);

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

function decodeXml(value) {
  return value.replace(/^<!\[CDATA\[/, '').replace(/\]\]>$/, '')
    .replaceAll('&amp;', '&').replaceAll('&quot;', '"').replaceAll('&apos;', "'")
    .replaceAll('&lt;', '<').replaceAll('&gt;', '>').trim();
}
function locs(xml) { return [...xml.matchAll(/<loc>\s*([\s\S]*?)\s*<\/loc>/gi)].map(m => decodeXml(m[1])); }
async function fetchText(url) {
  const response = await fetch(url, { redirect:'follow', headers:{'user-agent':'BuhurtOS/1.0 (+https://dothecoolwip1.github.io/BuhurtOS/)'} });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`);
  return response.text();
}
function slugFromUrl(url){ try{return decodeURIComponent(new URL(url).pathname.replace(/^\/team\//,''));}catch{return url;} }
function cleanLines(text){ return text.split('\n').map(v=>v.replace(/\s+/g,' ').trim()).filter(Boolean); }
function valueBefore(lines,label){
  const i=lines.findIndex(v=>v.toLowerCase()===label.toLowerCase());
  return i>0?lines[i-1]:null;
}
function numberOrNull(v){ if(v==null||!String(v).trim()||String(v).trim()==='​')return null; const n=Number(String(v).replace(',','.')); return Number.isFinite(n)?n:null; }
function parseDirectoryCard(record){
  const lines=cleanLines(record.text);
  const name=lines[0]||slugFromUrl(record.url);
  return {
    url:record.url, slug:slugFromUrl(record.url), name,
    rank5v5:numberOrNull(valueBefore(lines,'Rank 5vs5')),
    averagePoints5v5:numberOrNull(valueBefore(lines,'Average points 5vs5')),
    totalPoints5v5:numberOrNull(valueBefore(lines,'Total points 5vs5')),
    rank12v12:numberOrNull(valueBefore(lines,'Rank 12vs12')),
    averagePoints12v12:numberOrNull(valueBefore(lines,'Average points 12vs12')),
    totalPoints12v12:numberOrNull(valueBefore(lines,'Total points 12vs12')),
    captain:valueBefore(lines,'Captain'),
    conference:valueBefore(lines,'Conference'),
    country:valueBefore(lines,'country'),
    city:valueBefore(lines,'City'),
    rawText:record.text
  };
}
async function discoverTeamUrls() {
  const queue=[`${ORIGIN}/sitemap.xml`], seen=new Set(), sitemaps=[], teams=new Set();
  while(queue.length){
    const current=queue.shift(); if(!current||seen.has(current))continue;
    if(seen.size>=100)throw new Error('Sitemap traversal exceeded safety limit.');
    seen.add(current); const xml=await fetchText(current); sitemaps.push(current);
    for(const rawLoc of locs(xml)){
      let url; try{url=new URL(rawLoc);}catch{continue;} if(url.origin!==ORIGIN)continue;
      if(/^\/team\//i.test(url.pathname)){url.hash='';url.search='';teams.add(url.toString());}
      else if(/sitemap/i.test(url.pathname)&&!seen.has(url.toString()))queue.push(url.toString());
    }
  }
  return {sitemaps,teamUrls:[...teams].sort((a,b)=>a.localeCompare(b))};
}
async function launchBrowser(){
  const {default:puppeteer}=await import('puppeteer-core');
  return puppeteer.launch({executablePath:process.env.CHROME_PATH||process.env.CHROME_BIN||'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--disable-dev-shm-usage','--disable-gpu']});
}
async function preparePage(browser){
  const page=await browser.newPage(); await page.setViewport({width:1440,height:1200});
  await page.setUserAgent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/140 Safari/537.36');
  await page.setRequestInterception(true);
  page.on('request',req=>{ if(['media','font'].includes(req.resourceType()))req.abort(); else req.continue(); });
  return page;
}
async function renderDirectory(browser){
  const page=await preparePage(browser);
  try{
    await page.goto(`${ORIGIN}/teams`,{waitUntil:'domcontentloaded',timeout:90000});
    await page.waitForFunction(()=>document.querySelectorAll('a[href*="/team/"]').length>0,{timeout:90000});
    let stagnant=0;
    for(let attempt=0;attempt<160;attempt++){
      const before=await page.evaluate(()=>new Set([...document.querySelectorAll('a[href*="/team/"]')].map(a=>a.href)).size);
      const clicked=await page.evaluate(()=>{
        const controls=[...document.querySelectorAll('button,[role="button"],a')];
        const c=controls.find(el=>/^load more$/i.test((el.textContent||'').trim())&&el.getBoundingClientRect().height>0);
        if(!c)return false;c.scrollIntoView({block:'center'});c.click();return true;
      });
      if(!clicked)break; await sleep(900);
      const after=await page.evaluate(()=>new Set([...document.querySelectorAll('a[href*="/team/"]')].map(a=>a.href)).size);
      console.log(`BI load-more ${attempt+1}: ${before} -> ${after}`);
      stagnant=after>before?0:stagnant+1; if(stagnant>=4)break;
    }
    const rendered=await page.evaluate(()=>{
      const best=new Map();
      for(const anchor of document.querySelectorAll('a[href*="/team/"]')){
        const href=anchor.href;if(!href||!new URL(href).pathname.startsWith('/team/'))continue;
        let node=anchor,text=(anchor.textContent||'').trim();
        for(let depth=0;depth<12&&node.parentElement;depth++){
          node=node.parentElement; const candidate=(node.innerText||'').replace(/\n{3,}/g,'\n\n').trim();
          if(!candidate||candidate.length>6500)continue;
          if(/Conference/i.test(candidate)&&/Country/i.test(candidate)&&/Captain/i.test(candidate)){text=candidate;break;}
          if(candidate.length>text.length)text=candidate;
        }
        const normalized=href.split('#')[0].split('?')[0], existing=best.get(normalized);
        if(!existing||text.length>existing.text.length)best.set(normalized,{url:normalized,text});
      }
      return [...best.values()].sort((a,b)=>a.url.localeCompare(b.url));
    });
    return rendered.map(parseDirectoryCard);
  }finally{await page.close();}
}
async function scrapeProfile(browser,url,index,total){
  const page=await preparePage(browser);
  try{
    await page.goto(url,{waitUntil:'domcontentloaded',timeout:60000});
    await sleep(1200);
    const data=await page.evaluate(()=>{
      const root=document.querySelector('main')||document.body;
      const text=(root?.innerText||'').replace(/\n{3,}/g,'\n\n').trim();
      const images=[...document.images].map(img=>({src:img.currentSrc||img.src||'',alt:(img.alt||'').trim(),width:img.naturalWidth||img.width||0,height:img.naturalHeight||img.height||0}))
        .filter(x=>x.src&&/^https?:/i.test(x.src));
      const links=[...document.querySelectorAll('a[href]')].map(a=>({href:a.href,text:(a.textContent||'').replace(/\s+/g,' ').trim()}))
        .filter(x=>x.href&&/^https?:/i.test(x.href));
      const title=document.querySelector('h1')?.textContent?.trim()||document.title||'';
      return {title,text,images,links};
    });
    const nameGuess=data.title.replace(/\s*\|.*$/,'').trim();
    const logoCandidates=data.images.filter(i=>i.width>=80&&i.height>=80&&!/logo.*buhurt|buhurt.*logo/i.test(i.alt))
      .sort((a,b)=>{
        const an=(a.alt||'').toLowerCase().includes(nameGuess.toLowerCase())?1000:0;
        const bn=(b.alt||'').toLowerCase().includes(nameGuess.toLowerCase())?1000:0;
        return (bn+b.width*b.height)-(an+a.width*a.height);
      }).slice(0,8);
    console.log(`profile ${index+1}/${total}: ${url}`);
    return {url,slug:slugFromUrl(url),ok:true,title:data.title,text:data.text,logoCandidates,links:data.links.slice(0,120)};
  }catch(error){
    console.warn(`profile failed: ${url}: ${error.message}`);
    return {url,slug:slugFromUrl(url),ok:false,error:String(error.message||error),title:'',text:'',logoCandidates:[],links:[]};
  }finally{await page.close();}
}
async function scrapeProfiles(browser,urls,concurrency=5){
  const results=new Array(urls.length); let cursor=0;
  async function worker(){
    while(true){const i=cursor++; if(i>=urls.length)return; results[i]=await scrapeProfile(browser,urls[i],i,urls.length);}
  }
  await Promise.all(Array.from({length:concurrency},()=>worker()));
  return results;
}

const {sitemaps,teamUrls}=await discoverTeamUrls();
if(!teamUrls.length)throw new Error('No BI team profile URLs found.');
const generatedAt=new Date().toISOString(); await mkdir(new URL('../src/data/',import.meta.url),{recursive:true});
await writeFile(URL_OUTPUT,JSON.stringify({source:`${ORIGIN}/teams`,sourceHost:'www.buhurtinternational.com',generatedAt,discovery:'BI sitemap team profile URLs',count:teamUrls.length,sitemaps,teamUrls},null,2)+'\n','utf8');

const browser=await launchBrowser();
try{
  const directory=await renderDirectory(browser);
  if(directory.length<100)throw new Error(`Rendered BI directory returned only ${directory.length} team links.`);
  await writeFile(RAW_OUTPUT,JSON.stringify({source:`${ORIGIN}/teams`,generatedAt,sitemapCount:teamUrls.length,renderedCount:directory.length,teams:directory},null,2)+'\n','utf8');
  const profiles=await scrapeProfiles(browser,teamUrls,Number(process.env.BI_PROFILE_CONCURRENCY||5));
  await writeFile(PROFILE_OUTPUT,JSON.stringify({source:`${ORIGIN}/teams`,generatedAt,count:profiles.length,successful:profiles.filter(x=>x.ok).length,failed:profiles.filter(x=>!x.ok).length,profiles},null,2)+'\n','utf8');
  console.log(`BI snapshot complete: ${directory.length} directory records, ${profiles.filter(x=>x.ok).length}/${profiles.length} profiles.`);
}finally{await browser.close();}
