import puppeteer from 'puppeteer-core';

const browser=await puppeteer.launch({executablePath:process.env.CHROME_PATH||'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--disable-dev-shm-usage']});
const page=await browser.newPage();
await page.setViewport({width:1440,height:1200});
await page.setUserAgent('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/140 Safari/537.36');
const seen=[];
page.on('response',async r=>{
  try{
    const u=r.url(),h=r.headers(),ct=(h['content-type']||'').toLowerCase();
    if(/json|graphql|wix|data|query|collection|dataset/i.test(u+' '+ct)){
      let body='';
      if(ct.includes('json')||ct.includes('text')){ try{body=(await r.text()).slice(0,200000);}catch{} }
      seen.push({url:u,status:r.status(),contentType:ct,body});
    }
  }catch{}
});
await page.goto('https://www.buhurtinternational.com/teams',{waitUntil:'networkidle2',timeout:90000});
await new Promise(r=>setTimeout(r,4000));
for(let i=0;i<3;i++){
  await page.evaluate(()=>{
    const c=[...document.querySelectorAll('button,[role="button"],a')].find(el=>/^load more$/i.test((el.textContent||'').trim())&&el.getBoundingClientRect().height>0);
    if(c)c.click();
  });
  await new Promise(r=>setTimeout(r,2500));
}
console.log('NETWORK_CAPTURE_START');
for(const x of seen)console.log(JSON.stringify(x));
console.log('NETWORK_CAPTURE_END');
await browser.close();
