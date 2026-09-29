import puppeteer from 'puppeteer-core';
import { writeFile } from 'node:fs/promises';

const browser=await puppeteer.launch({executablePath:process.env.CHROME_PATH||'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--disable-dev-shm-usage']});
const page=await browser.newPage();
await page.setViewport({width:1440,height:1000});
await page.setUserAgent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/140 Safari/537.36');

await page.goto('https://www.buhurtinternational.com/teams',{waitUntil:'networkidle2',timeout:90000});
await new Promise(r=>setTimeout(r,2500));

const result=await page.evaluate(async()=>{
  const encode=obj=>btoa(unescape(encodeURIComponent(JSON.stringify(obj)))).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
  const all=[]; let offset=0; const limit=100;
  while(true){
    const request={
      dataCollectionId:'TeamRegistrationcustom',
      query:{filter:{},sort:[{fieldName:'5Vs5AveragePoints',order:'DESC'}],paging:{offset,limit},fields:[]},
      referencedItemOptions:[],returnTotalCount:true,environment:'LIVE',appId:'f4c9f61b-b20d-46ac-b453-3134ea78db25'
    };
    const url='/_api/cloud-data/v2/items/query?.r='+encode(request);
    const res=await fetch(url,{credentials:'include'});
    if(!res.ok)throw new Error('BI cloud-data '+res.status+' at offset '+offset);
    const json=await res.json();
    const items=json.dataItems||[];
    all.push(...items);
    const total=json.pagingMetadata?.count??json.totalCount??json.pagingMetadata?.total??null;
    if(items.length<limit || (total!=null && all.length>=total)) return {items:all,total,rawMeta:json.pagingMetadata||null};
    offset+=items.length;
    if(offset>5000)throw new Error('Safety stop: too many BI team records');
  }
});

await writeFile('src/data/biTeamCollection.json',JSON.stringify({
 source:'https://www.buhurtinternational.com/_api/cloud-data/v2/items/query',
 collection:'TeamRegistrationcustom',
 generatedAt:new Date().toISOString(),
 count:result.items.length,
 total:result.total,
 pagingMetadata:result.rawMeta,
 items:result.items
},null,2)+'\n','utf8');
console.log('Saved BI TeamRegistrationcustom records:',result.items.length,'reported total:',result.total);
await browser.close();
