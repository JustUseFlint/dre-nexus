/* DRE Nexus web replica: core, router, Drug Hub, Matrix, Case Law, Settings */
const $=(s,r=document)=>r.querySelector(s), $$=(s,r=document)=>[...r.querySelectorAll(s)];
const esc=s=>String(s??'').replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const getP=(o,p)=>p.split('.').reduce((a,k)=>a==null?undefined:a[k],o);
const setP=(o,p,v)=>{const ks=p.split('.');let a=o;ks.slice(0,-1).forEach(k=>{if(typeof a[k]!=='object'||a[k]===null)a[k]={};a=a[k]});a[ks[ks.length-1]]=v;};
const uid=()=>Date.now().toString(36)+Math.random().toString(36).slice(2,7);
const fmtT=t=>t?new Date(t).toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}):'';
const fmtDT=t=>t?new Date(t).toLocaleString([], {month:'short',day:'numeric',hour:'2-digit',minute:'2-digit'}):'';
const catOf=id=>DN.CATS_ALL.find(c=>c.id===id)||DN.CATS_ALL[7];
const S_={get:(k,d)=>{try{const v=localStorage.getItem('dn.'+k);return v==null?d:JSON.parse(v)}catch(e){return d}},set:(k,v)=>localStorage.setItem('dn.'+k,JSON.stringify(v))};
const ST={role:S_.get('role','DRE'),theme:S_.get('theme','dark'),lang:S_.get('lang','en'),pass:S_.get('pass',null),rt:S_.get('rt',false),hc:S_.get('hc',false),officer:S_.get('officer',{name:'',badge:'',agency:'',dre:''})};
const saveST=()=>Object.entries(ST).forEach(([k,v])=>S_.set(k,v));
/* IndexedDB case store */
const DB={db:null,open(){return new Promise((res,rej)=>{const r=indexedDB.open('dre-nexus',1);r.onupgradeneeded=()=>r.result.createObjectStore('cases',{keyPath:'id'});r.onsuccess=()=>{DB.db=r.result;res()};r.onerror=()=>rej(r.error)})},
 all(){return new Promise(res=>{const q=DB.db.transaction('cases').objectStore('cases').getAll();q.onsuccess=()=>res(q.result||[])})},
 put(c){return new Promise(res=>{const t=DB.db.transaction('cases','readwrite');t.objectStore('cases').put(JSON.parse(JSON.stringify(c)));t.oncomplete=res})},
 del(id){return new Promise(res=>{const t=DB.db.transaction('cases','readwrite');t.objectStore('cases').delete(id);t.oncomplete=res})}};
let CASES=[], CUR=null, saveTimer=null;
function saveCur(){ if(!CUR) return; CUR.updated=Date.now(); clearTimeout(saveTimer); saveTimer=setTimeout(()=>DB.put(CUR),250); }
function toast(msg,ic='check'){let t=$('#toast');t.innerHTML=A.i[ic].replace('<svg','<svg width="18" height="18"')+esc(msg);t.classList.add('on');clearTimeout(t._h);t._h=setTimeout(()=>t.classList.remove('on'),2200);}
function haptic(){ if(navigator.vibrate) try{navigator.vibrate(8)}catch(e){} }
/* Sheets */
function openSheet(title,html,onOpen){const bg=$('#sheet-bg'),sh=$('#sheet');sh.innerHTML=`<div class="grab"></div><div class="sh-head"><h3>${esc(title)}</h3><button class="cbtn glass" data-act="closeSheet" aria-label="Close">${A.i.x}</button></div><div class="sh-body mat">${html}</div>`;bg.hidden=false;sh.hidden=false;requestAnimationFrame(()=>{bg.classList.add('on');sh.classList.add('on')});onOpen&&onOpen(sh);}
function closeSheet(){const bg=$('#sheet-bg'),sh=$('#sheet');bg.classList.remove('on');sh.classList.remove('on');setTimeout(()=>{bg.hidden=true;sh.hidden=true;sh.innerHTML=''},450);}
/* Speech */
function speak(key){const t=DN.INSTR[key];if(!t||!('speechSynthesis' in window)){toast('Audio not supported here','x');return}speechSynthesis.cancel();const u=new SpeechSynthesisUtterance(t[ST.lang]);u.lang=ST.lang==='es'?'es-US':'en-US';u.rate=.95;speechSynthesis.speak(u);toast(ST.lang==='es'?'Reproduciendo instrucciones':'Playing instructions','speak');}
function dictate(path,btn){const R=window.SpeechRecognition||window.webkitSpeechRecognition;if(!R){toast('Voice dictation not supported in this browser','x');return}const r=new R();r.lang=ST.lang==='es'?'es-US':'en-US';r.interimResults=false;btn.classList.add('on');r.onresult=e=>{const txt=[...e.results].map(x=>x[0].transcript).join(' ');const prev=getP(CUR,path)||'';setP(CUR,path,(prev?prev+' ':'')+txt);saveCur();const ta=$(`[data-b="${path}"]`);if(ta)ta.value=getP(CUR,path);};r.onend=()=>btn.classList.remove('on');r.onerror=()=>{btn.classList.remove('on');toast('Dictation stopped','x')};r.start();}
/* Matrix evaluation */
function classify(ind){return ind;}
function evaluate(ind){
 const keys=Object.keys(ind).filter(k=>ind[k]);
 const res=DN.CATS.map(c=>{const m=DN.MATRIX[c.id];let s=0,detail={};keys.forEach(k=>{const e=m[k];if(!e)return;if(e.v.includes(ind[k])){s+=1;detail[k]='hit'}else if(e.alt&&e.alt.includes(ind[k])){s+=.6;detail[k]='alt'}else detail[k]='miss'});return {cat:c,score:keys.length?s/keys.length:0,detail,n:keys.length}}).sort((a,b)=>b.score-a.score);
 const subs=DN.SUBSTANCES.filter(s=>s.cat!=='NONE').map(s=>{const r=res.find(x=>x.cat.id===s.cat);let sc=r.score,why=[];Object.entries(s.flags).forEach(([k,txt])=>{const want=k==='bp'?(/UP/.test(txt)?'up':'down'):({pupil:'dilated',pulse:'up',rtl:'slow'})[k];if(ind[k]&&ind[k]===want){sc+=.08;why.push(txt)}else if(ind[k]&&k==='bp'&&ind[k]!==want){sc-=.05}});return {s,score:Math.min(1,sc),why}}).sort((a,b)=>b.score-a.score);
 return {cats:res,subs,n:keys.length};
}
function matrixTable(detailsByCat){
 const cats=DN.CATS;const top=detailsByCat&&detailsByCat[0]?detailsByCat[0].cat.id:null;
 return `<div class="hscroll"><table class="matrix"><thead><tr><th></th>${cats.map(c=>`<th class="${top===c.id&&detailsByCat[0].n?'top':''}"><div style="display:flex;flex-direction:column;align-items:center;gap:4px">${A.cat(c.id,26)}<span>${c.short}</span></div></th>`).join('')}</tr></thead><tbody>${DN.MATRIX_ROWS.map(r=>`<tr><td>${r.label}</td>${cats.map(c=>{const d=detailsByCat?(detailsByCat.find(x=>x.cat.id===c.id)||{}).detail||{}:{};return `<td class="${d[r.k]||''}">${DN.MATRIX[c.id][r.k].t}</td>`}).join('')}</tr>`).join('')}</tbody></table></div>`;
}
function footnotes(){return `<div class="dim" style="margin-top:10px">${Object.entries(DN.FOOTNOTES).map(([k,v])=>`<div style="margin:3px 0"><b>${k==='*'?'*':'('+k+')'}</b> ${esc(v)}</div>`).join('')}</div>`;}
function resultsHTML(ev,limitSubs=8){
 if(!ev.n) return `<div class="empty">${A.i.matrix.replace('<svg','<svg width="40" height="40"')}<p>Enter observations to rank categories.</p></div>`;
 return `<div class="mat">${ev.cats.map((r,i)=>`<div class="row" style="margin:10px 0">${A.cat(r.cat.id,34)}<div style="flex:1"><div class="row between"><b style="font-size:15px">${r.cat.name}</b><span class="dim" style="font-variant-numeric:tabular-nums">${Math.round(r.score*100)}%</span></div><div class="bar" style="margin-top:6px"><i style="width:${r.score*100}%;background:${r.cat.color}"></i></div></div></div>`).join('')}
 <h3 style="margin-top:18px">Most consistent substances</h3><div class="card pad0 list">${ev.subs.slice(0,limitSubs).map(x=>`<a href="#/drug/${x.s.id}">${A.cat(x.s.cat,30)}<div style="flex:1;min-width:0"><b>${esc(x.s.name)}</b><div class="dim">${catOf(x.s.cat).short}${x.why.length?' \u00b7 '+esc(x.why.join('; ')):''}</div></div><span class="dim">${Math.round(x.score*100)}%</span></a>`).join('')}</div>
 <p class="dim">Polydrug use can mask or exaggerate indicators (e.g., a stimulant with a narcotic analgesic). Rankings support, and never replace, the evaluator\u2019s trained opinion based on the totality of the 12-step evaluation.</p></div>`;
}
/* Router */
const ROUTES=[];const route=(re,fn)=>ROUTES.push([re,fn]);
let NAV={title:'',back:null,right:''};
function render(){
 const h=location.hash.slice(1)||'/';
 let out=null;for(const [re,fn] of ROUTES){const m=h.match(re);if(m){NAV={title:'',back:null,right:''};out=fn(...m.slice(1));break}}
 if(out==null){location.hash='#/';return}
 const v=$('#view');v.className='view';void v.offsetWidth;v.innerHTML=out;
 $('#tb-title').textContent=NAV.title;$('#tb-back').style.visibility=NAV.back?'visible':'hidden';$('#tb-back').dataset.href=NAV.back||'';$('#tb-right').innerHTML=NAV.right||'';
 const tab=h.split('/')[1]||'';const map={'':'home',hub:'hub',drug:'hub',match:'hub',law:'law',cases:'cases',case:'cases',matrix:'matrix',settings:'settings'};
 setTab(map[tab]||'home');
 $('#fab').hidden=!(h.startsWith('/case/')&&CUR);
 $('#tabbar').style.display=/\/dre\/\d+|\/sfst\/\w+/.test(h)?'none':'';
 window.scrollTo(0,0);document.body.classList.remove('scrolled','min');
 AFTER.forEach(f=>f());AFTER.length=0;refreshLive();
}
const AFTER=[];
function setTab(k){$$('#tabbar a').forEach(a=>a.classList.toggle('on',a.dataset.tab===k));const on=$('#tabbar a.on'),p=$('#tabbar .pill');if(on&&p){p.style.left=on.offsetLeft+'px';p.style.width=on.offsetWidth+'px';p.style.opacity=1}else if(p)p.style.opacity=0;}
/* Live regions */
const LIVE={};function refreshLive(){$$('[data-live]').forEach(el=>{const [n,arg]=el.dataset.live.split('|');if(LIVE[n]){const h=LIVE[n](arg);if(el.innerHTML!==h)el.innerHTML=h}})}
/* Form helpers bound to CUR */
const F={
 text:(p,l,ph='',type='text')=>`<div class="field"><label>${l}</label><input class="input" type="${type}" data-b="${p}" value="${esc(getP(CUR,p)??'')}" placeholder="${esc(ph)}"${type==='number'?' inputmode="decimal" step="any"':''}></div>`,
 num:(p,l,ph='')=>F.text(p,l,ph,'number'),
 date:(p,l)=>F.text(p,l,'','date'),
 time:(p,l)=>`<div class="field"><label>${l}</label><div class="row"><input class="input" type="time" data-b="${p}" value="${esc(getP(CUR,p)??'')}"><button class="btn sm" data-act="now" data-p="${p}">Now</button></div></div>`,
 sel:(p,l,opts)=>`<div class="field"><label>${l}</label><select class="input" data-b="${p}"><option value="">Select\u2026</option>${opts.map(o=>`<option ${getP(CUR,p)===o?'selected':''}>${esc(o)}</option>`).join('')}</select></div>`,
 area:(p,l,ph='')=>`<div class="field"><label class="row between"><span>${l}</span><button class="chip" style="margin:0;min-height:34px" data-act="dict" data-p="${p}" aria-label="Dictate">${A.i.mic.replace('<svg','<svg width="16" height="16"')}Dictate</button></label><textarea class="input" data-b="${p}" placeholder="${esc(ph)}">${esc(getP(CUR,p)??'')}</textarea></div>`,
 seg:(p,l,opts,bad=true)=>`<div class="field">${l?`<label>${l}</label>`:''}<div class="seg ${bad?'bad':''}" data-seg="${p}">${opts.map(o=>{const [v,t]=Array.isArray(o)?o:[o.toLowerCase(),o];return `<button data-v="${v}" class="${getP(CUR,p)===v?'on':''}">${t}</button>`}).join('')}</div></div>`,
 tog:(p,l,sub='',ok=false)=>`<div class="toggle ${getP(CUR,p)?'on':''} ${ok?'okc':''}" data-tog="${p}" role="switch" aria-checked="${!!getP(CUR,p)}"><div><div style="font-weight:550">${l}</div>${sub?`<div class="dim">${sub}</div>`:''}</div><div class="sw"></div></div>`,
 chips:(p,opts,bad=false)=>`<div>${opts.map(o=>`<span class="chip ${bad?'bad':''} ${(getP(CUR,p)||[]).includes(o)?'on':''}" data-arr="${p}" data-v="${esc(o)}">${esc(o)}</span>`).join('')}</div>`,
 counter:(p,l)=>`<div class="row between" style="padding:8px 0"><span style="font-weight:550">${l}</span><div class="counter"><button class="cbtn glassbtn btn" style="min-height:44px;padding:0" data-inc="${p}" data-d="-1">${A.i.minus}</button><span class="n" style="font-size:28px;min-width:36px" data-show="${p}">${getP(CUR,p)||0}</span><button class="cbtn glassbtn btn" style="min-height:44px;padding:0" data-inc="${p}" data-d="1">${A.i.plus}</button></div></div>`
};
function timerHTML(p,target,label='Timer'){return `<div class="card" style="text-align:center"><div class="eyebrow">${label}${target?` \u00b7 target ${target}s`:''}</div><div class="timer" data-timer="${p}" data-target="${target||''}">0.0</div><div class="row" style="justify-content:center;gap:8px;margin-top:8px"><button class="btn pri sm" data-act="tStart" data-p="${p}">${A.i.play.replace('<svg','<svg width="16" height="16"')}Start</button><button class="btn sm" data-act="tStop" data-p="${p}">${A.i.pause.replace('<svg','<svg width="16" height="16"')}Stop</button><button class="btn sm" data-act="tReset" data-p="${p}">${A.i.reset.replace('<svg','<svg width="16" height="16"')}</button></div></div>`;}
function tVal(p){const t=getP(CUR,p)||{};return (t.acc||0)+(t.start?Date.now()-t.start:0);}
setInterval(()=>{$$('[data-timer]').forEach(el=>{if(!CUR)return;const ms=tVal(el.dataset.timer);const s=ms/1000;el.textContent=s>=60?`${Math.floor(s/60)}:${String(Math.floor(s%60)).padStart(2,'0')}`:s.toFixed(1);const tg=+el.dataset.target;el.style.color=tg&&s>=tg?'var(--ok)':''})},100);
/* Actions */
const ACT={
 closeSheet, now(el){const d=new Date();const v=`${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`;setP(CUR,el.dataset.p,v);saveCur();const i=$(`[data-b="${el.dataset.p}"]`);if(i)i.value=v;refreshLive();},
 dict(el){dictate(el.dataset.p,el)}, speak(el){speak(el.dataset.k)},
 tStart(el){const t=getP(CUR,el.dataset.p)||{acc:0};if(!t.start){t.start=Date.now();if(!t.began)t.began=Date.now();}setP(CUR,el.dataset.p,t);saveCur();haptic()},
 tStop(el){const t=getP(CUR,el.dataset.p)||{acc:0};if(t.start){t.acc=(t.acc||0)+Date.now()-t.start;t.start=null}setP(CUR,el.dataset.p,t);saveCur();haptic();refreshLive()},
 tReset(el){setP(CUR,el.dataset.p,{acc:0,start:null});saveCur();refreshLive()},
 lang(el){ST.lang=el.dataset.v;saveST();$$('[data-act=lang]').forEach(b=>b.classList.toggle('on',b.dataset.v===ST.lang))},
 openMatrix(){openMatrixSheet()},
};
function openMatrixSheet(){const ind=CUR?caseIndicators(CUR):{};const ev=evaluate(ind);openSheet('Live Matrix',`<p class="dim" style="margin-top:0">Updates from the indicators entered in this case. Green: consistent. Amber: consistent via a Matrix footnote.</p><div class="card">${matrixTable(ev.n?ev.cats:null)}${footnotes()}</div>${resultsHTML(ev,6)}`);}
document.addEventListener('click',e=>{
 const t=e.target.closest('[data-act],[data-tog],[data-seg] button,[data-arr],[data-inc],[data-href]');if(!t)return;
 if(t.dataset.href){location.hash=t.dataset.href;return}
 if(t.dataset.act){e.preventDefault();ACT[t.dataset.act]&&ACT[t.dataset.act](t,e);return}
 if(!CUR&&!t.closest('#match-form'))return;
 const tgt=t.closest('#match-form')?MATCH:CUR;
 if(t.dataset.tog){const p=t.dataset.tog;const v=!getP(tgt,p);setP(tgt,p,v);t.classList.toggle('on',v);t.setAttribute('aria-checked',v);haptic();}
 else if(t.parentElement.dataset.seg){const p=t.parentElement.dataset.seg;const v=getP(tgt,p)===t.dataset.v?'':t.dataset.v;setP(tgt,p,v);$$('button',t.parentElement).forEach(b=>b.classList.toggle('on',b.dataset.v===v));haptic();}
 else if(t.dataset.arr){const p=t.dataset.arr;let a=getP(tgt,p)||[];a=a.includes(t.dataset.v)?a.filter(x=>x!==t.dataset.v):a.concat(t.dataset.v);setP(tgt,p,a);t.classList.toggle('on');haptic();}
 else if(t.dataset.inc){const p=t.dataset.inc;const v=Math.max(0,(getP(tgt,p)||0)+(+t.dataset.d));setP(tgt,p,v);$$(`[data-show="${p}"]`).forEach(s=>{s.textContent=v;s.classList.remove('pop');void s.offsetWidth;s.classList.add('pop')});haptic();}
 if(tgt===CUR)saveCur();refreshLive();
});
document.addEventListener('input',e=>{const t=e.target;if(!t.dataset.b)return;const tgt=t.closest('#match-form')?MATCH:CUR;if(!tgt)return;let v=t.value;if(t.type==='number')v=v===''?'':parseFloat(v);setP(tgt,t.dataset.b,v);if(tgt===CUR)saveCur();refreshLive();});
/* Scroll effects: edge, tab bar minimize, parallax */
let lastY=0;window.addEventListener('scroll',()=>{const y=scrollY;document.body.classList.toggle('scrolled',y>24);if(y>lastY+6&&y>120)document.body.classList.add('min');else if(y<lastY-6)document.body.classList.remove('min');lastY=y;$$('.parallax').forEach(p=>p.style.transform=`translate3d(0,${y*.25}px,0) rotate(${y*.02}deg)`);},{passive:true});
/* ===== Home ===== */
route(/^\/$/,()=>{NAV.title='DRE Nexus';
 const open=CASES.filter(c=>c.status!=='closed').length;const hr=new Date().getHours();const g=hr<12?'Good morning':hr<18?'Good afternoon':'Good evening';
 const recent=[...CASES].sort((a,b)=>b.updated-a.updated).slice(0,3);
 return `<div class="hero mat"><div class="art parallax">${A.heroArt()}</div><div class="eyebrow">${ST.role==='DRE'?'Drug Recognition Expert':'Patrol Officer'}</div><h1 class="big" style="max-width:240px">${g}${ST.officer.name?', '+esc(ST.officer.name.split(' ')[0]):''}</h1><p class="sub" style="max-width:220px">${open} open case${open===1?'':'s'} \u00b7 ${DN.SUBSTANCES.length} substances \u00b7 ${DN.CASES.length} cases in law library</p><button class="btn pri" data-act="newCase">${A.i.plus.replace('<svg','<svg width="20" height="20"')}New investigation</button></div>
 <div class="grid2 grid-wide mat" style="animation-delay:.05s">
  <a class="tile" href="#/match">${A.cat('HAL')}<b>Match tool</b><small>Observed signs \u2192 likely categories</small></a>
  <a class="tile" href="#/matrix">${A.cat('DA')}<b>DRE Matrix</b><small>Full symptomatology with footnotes</small></a>
  <a class="tile" href="#/hub">${A.cat('NA')}<b>Drug hub</b><small>${DN.SUBSTANCES.length} substances, 7 categories</small></a>
  <a class="tile" href="#/law">${A.cat('CAN')}<b>Case law</b><small>Impairment & possession</small></a>
 </div>
 <h2>Recent cases</h2>${recent.length?`<div class="card pad0 list mat">${recent.map(caseRow).join('')}</div>`:`<div class="card empty">No cases yet.</div>`}
 <h2>Categories</h2><div class="hscroll" style="display:flex;gap:10px;padding-bottom:6px">${DN.CATS.map(c=>`<a class="tile" style="min-width:150px" href="#/hub?cat=${c.id}">${A.cat(c.id)}<b>${c.short}</b><small>${DN.SUBSTANCES.filter(s=>s.cat===c.id).length} substances</small></a>`).join('')}</div>`;
});
/* ===== Drug hub ===== */
let HUBQ='',HUBCAT='',HUBTYPE='';
route(/^\/hub(?:\?cat=(\w+))?$/,(cat)=>{NAV.title='Drug Hub';if(cat)HUBCAT=cat;
 AFTER.push(()=>{const i=$('#hubq');i.value=HUBQ;i.addEventListener('input',()=>{HUBQ=i.value;$('#hublist').innerHTML=hubList()});});
 return `<h1 class="big">Drug Hub</h1><p class="sub">Prescription, OTC, illicit and inhalants, mapped to the 7 DRE categories.</p>
 <div class="search glass">${A.i.search.replace('<svg','<svg width="20" height="20"')}<input id="hubq" placeholder="Name, street name, schedule\u2026" autocomplete="off" aria-label="Search substances"></div>
 <div class="hscroll" style="white-space:nowrap;margin-bottom:6px">${[['','All'],...DN.CATS_ALL.map(c=>[c.id,c.short])].map(([v,t])=>`<span class="chip ${HUBCAT===v?'on':''}" data-act="hubCat" data-v="${v}">${v?`<i class="catdot" style="background:${catOf(v).color}"></i>`:''}${t}</span>`).join('')}</div>
 <div class="seg" style="margin-bottom:14px">${['','Prescription','OTC','Illicit','Inhalant'].map(v=>`<button data-act="hubType" data-v="${v}" class="${HUBTYPE===v?'on':''}">${v||'All types'}</button>`).join('')}</div>
 <div id="hublist">${hubList()}</div>`;});
ACT.hubCat=el=>{HUBCAT=el.dataset.v;$$('[data-act=hubCat]').forEach(c=>c.classList.toggle('on',c===el));$('#hublist').innerHTML=hubList()};
ACT.hubType=el=>{HUBTYPE=el.dataset.v;$$('[data-act=hubType]').forEach(c=>c.classList.toggle('on',c===el));$('#hublist').innerHTML=hubList()};
function hubList(){const q=HUBQ.toLowerCase().trim();const l=DN.SUBSTANCES.filter(s=>(!HUBCAT||s.cat===HUBCAT)&&(!HUBTYPE||s.type===HUBTYPE)&&(!q||[s.name,s.official,s.sched,...s.street].join(' ').toLowerCase().includes(q)));
 if(!l.length)return `<div class="card empty">No matches for \u201c${esc(HUBQ)}\u201d.</div>`;
 return `<div class="card pad0 list mat">${l.map(s=>`<a href="#/drug/${s.id}">${A.cat(s.cat,40)}<div style="flex:1;min-width:0"><b>${esc(s.name)}</b><div class="dim" style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${esc(s.street.slice(0,3).join(', '))}</div></div><span class="tag">${esc(s.sched.split(' (')[0].replace('Schedule','Sch.'))}</span><span class="chev">${A.i.chev.replace('<svg','<svg width="16" height="16"')}</span></a>`).join('')}</div><p class="dim">${l.length} of ${DN.SUBSTANCES.length} substances</p>`;}
function trendChart(s,mode){const d=DN.trend(s)[mode];const W=320,H=140,p=22;const xs=i=>p+i*(W-2*p)/(d.length-1),ys=v=>H-p-(v/100)*(H-2*p);const pts=d.map((v,i)=>`${xs(i)},${ys(v)}`).join(' ');const c=catOf(s.cat).color;
 return `<svg viewBox="0 0 ${W} ${H}" class="svgbox"><defs><linearGradient id="tg" x1="0" x2="0" y1="0" y2="1"><stop offset="0" stop-color="${c}" stop-opacity=".35"/><stop offset="1" stop-color="${c}" stop-opacity="0"/></linearGradient></defs>${[0,50,100].map(v=>`<path d="M${p} ${ys(v)}H${W-p}" stroke="currentColor" stroke-opacity=".08"/>`).join('')}<polygon points="${xs(0)},${H-p} ${pts} ${xs(d.length-1)},${H-p}" fill="url(#tg)"/><polyline points="${pts}" fill="none" stroke="${c}" stroke-width="2.5" stroke-linejoin="round"/>${d.map((v,i)=>`<circle cx="${xs(i)}" cy="${ys(v)}" r="3" fill="${c}"/>`).join('')}${DN.YEARS.map((y,i)=>i%2===0?`<text x="${xs(i)}" y="${H-4}" font-size="9" text-anchor="middle" fill="currentColor" opacity=".5">${y}</text>`:'').join('')}</svg>`;}
let TRMODE='seizures';
ACT.trend=el=>{TRMODE=el.dataset.v;$$('[data-act=trend]').forEach(b=>b.classList.toggle('on',b===el));$('#trend').innerHTML=trendChart(DN.SUBSTANCES.find(s=>s.id===el.dataset.s),TRMODE)};
route(/^\/drug\/([\w-]+)$/,(id)=>{const s=DN.SUBSTANCES.find(x=>x.id===id);if(!s)return null;const c=catOf(s.cat);NAV.title=s.name;NAV.back='/hub';
 const m=DN.MATRIX[s.cat];const law=DN.CASES.filter(k=>(s.type==='Illicit'||s.cat==='CAN')?true:k.t==='Impairment').slice(0,4);
 const abuse=[1,2,3,4,5].map(i=>`<i style="display:inline-block;width:22px;height:8px;border-radius:4px;margin-right:3px;background:${i<=s.abuse?c.color:'var(--line2)'}"></i>`).join('');
 return `<div class="hero mat" style="background:radial-gradient(120% 100% at 100% 0%,${c.color}40 0%,transparent 55%),var(--card)"><div class="row">${A.cat(s.cat,56)}<div><div class="eyebrow" style="color:${c.color}">${c.name}</div><h1 class="big" style="margin:2px 0">${esc(s.name)}</h1></div></div><p class="muted" style="margin:10px 0 12px">${esc(s.official)}</p><div>${s.street.map(x=>`<span class="tag">${esc(x)}</span>`).join('')}</div></div>
 <div class="grid2 mat"><div class="card"><div class="eyebrow">DEA schedule</div><div style="font-weight:650;margin-top:4px">${esc(s.sched)}</div></div><div class="card"><div class="eyebrow">Rx status</div><div style="font-weight:650;margin-top:4px">${esc(s.rx)}</div></div></div>
 <div class="card mat"><dl class="kv"><dt>Medical use</dt><dd>${esc(s.use)}</dd><dt>Typical dosage</dt><dd>${esc(s.dose)}</dd><dt>Onset</dt><dd>${esc(s.onset)}</dd><dt>Duration</dt><dd>${esc(s.duration)}</dd><dt>Routes</dt><dd>${esc(s.routes)}</dd><dt>Abuse potential</dt><dd>${abuse}</dd><dt>Street price</dt><dd>${esc(s.price)}</dd></dl></div>
 ${s.cat!=='NONE'?`<h2>Impairment indicators vs Matrix</h2><div class="card pad0 mat"><div class="hscroll"><table class="matrix"><thead><tr><th>Indicator</th><th>${esc(c.short)} Matrix</th><th>${esc(s.name)} notes</th></tr></thead><tbody>${DN.MATRIX_ROWS.map(r=>`<tr><td>${r.label}</td><td>${m[r.k].t}</td><td class="${s.flags[r.k]?'alt':''}" style="text-align:left">${esc(s.flags[r.k]||'As Matrix')}</td></tr>`).join('')}</tbody></table></div></div>
 <div class="card mat"><h3>General indicators</h3><div>${DN.GENERAL[s.cat].map(g=>`<span class="tag">${esc(g)}</span>`).join('')}</div><h3 style="margin-top:12px">Overdose signs</h3><p class="muted" style="margin:0">${esc(DN.OD[s.cat])}</p></div>`:`<div class="card mat"><p class="muted" style="margin:0">Not a DRE drug category at normal doses. Included for reference and to rule out.</p></div>`}
 <h2>Reference visuals</h2><div class="grid2 mat">${A.ref(s)}</div><p class="dim">Custom illustrations of typical forms and paraphernalia; not photographs of evidence.</p>
 <h2>History</h2><div class="card mat"><p style="margin:0">${esc(s.history)}</p></div>
 <h2>Trends</h2><div class="card mat"><div class="seg" style="margin-bottom:10px"><button class="on" data-act="trend" data-v="seizures" data-s="${s.id}">Seizures / lab reports</button><button data-act="trend" data-v="arrests" data-s="${s.id}">Arrests</button></div><div id="trend">${trendChart(s,'seizures')}</div><p class="dim">${esc(DN.TRENDS_NOTE)}</p></div>
 <h2>Related case law</h2><div class="card pad0 list mat">${law.map(k=>`<a href="#/law?q=${encodeURIComponent(k.n)}">${A.i.law.replace('<svg','<svg width="22" height="22"')}<div style="flex:1"><b>${esc(k.n)}</b><div class="dim">${esc(k.c)}</div></div><span class="chev">${A.i.chev.replace('<svg','<svg width="16" height="16"')}</span></a>`).join('')}</div>`;});
/* ===== Match tool ===== */
let MATCH={};
const MATCH_FIELDS=[['hgn','HGN',[['present','Present'],['none','None']]],['vgn','Vertical nystagmus',[['present','Present'],['none','None']]],['loc','Lack of convergence',[['present','Present'],['none','None']]],['pupil','Pupil size',[['constricted','Constricted'],['normal','Normal'],['dilated','Dilated']]],['rtl','Reaction to light',[['normal','Normal'],['slow','Slow'],['none','Little / none']]],['pulse','Pulse',[['down','Down'],['normal','Normal'],['up','Up']]],['bp','Blood pressure',[['down','Down'],['normal','Normal'],['up','Up']]],['temp','Temperature',[['down','Down'],['normal','Normal'],['up','Up']]],['tone','Muscle tone',[['flaccid','Flaccid'],['normal','Normal'],['rigid','Rigid']]]];
LIVE.match=()=>resultsHTML(evaluate(MATCH));
ACT.matchReset=()=>{MATCH={};render()};
route(/^\/match$/,()=>{NAV.title='Match Tool';NAV.back='/';NAV.right=`<button class="cbtn glass" data-act="matchReset" aria-label="Reset">${A.i.reset}</button>`;
 return `<h1 class="big">Match tool</h1><p class="sub">Enter what you observed. Categories are ranked against the DRE Matrix, honoring its footnotes and exceptions.</p>
 <div class="card mat" id="match-form">${MATCH_FIELDS.map(([k,l,o])=>`<div class="field"><label>${l}</label><div class="seg" data-seg="${k}">${o.map(([v,t])=>`<button data-v="${v}" class="${MATCH[k]===v?'on':''}">${t}</button>`).join('')}</div></div>`).join('')}</div>
 <h2>Ranking</h2><div data-live="match"></div>`;});
/* ===== Matrix ===== */
route(/^\/matrix$/,()=>{NAV.title='DRE Matrix';
 return `<h1 class="big">DRE Matrix</h1><p class="sub">Drug Symptomatology Matrix (IACP / NHTSA DEC Program).</p><div class="card mat">${matrixTable(null)}${footnotes()}</div>
 ${DN.CATS.map(c=>`<div class="card mat"><div class="row">${A.cat(c.id,44)}<div><h3 style="margin:0">${c.name}</h3><div class="dim">${esc(DN.ADMIN[c.id])}</div></div></div><p class="muted">${esc(c.desc)}</p><dl class="kv"><dt>Duration</dt><dd>${esc(DN.ONSET[c.id])}</dd><dt>Overdose</dt><dd>${esc(DN.OD[c.id])}</dd></dl><div style="margin-top:10px">${DN.GENERAL[c.id].map(g=>`<span class="tag">${esc(g)}</span>`).join('')}</div></div>`).join('')}`;});
/* ===== Case law ===== */
let LAWT='';
route(/^\/law(?:\?q=(.*))?$/,(q)=>{NAV.title='Case Law';const q0=q?decodeURIComponent(q):'';
 AFTER.push(()=>{const i=$('#lawq');i.value=q0;const up=()=>$('#lawlist').innerHTML=lawList(i.value);i.addEventListener('input',up);up();});
 const tags=[...new Set(DN.CASES.flatMap(c=>c.tags))].sort();
 return `<h1 class="big">Case law</h1><p class="sub">Verified decisions on impairment and possession enforcement. Summaries are for training; confirm current law in your jurisdiction.</p>
 <div class="search glass">${A.i.search.replace('<svg','<svg width="20" height="20"')}<input id="lawq" placeholder="Case, citation, issue\u2026" aria-label="Search case law"></div>
 <div class="seg" style="margin-bottom:10px">${['','Impairment','Possession'].map(v=>`<button data-act="lawT" data-v="${v}" class="${LAWT===v?'on':''}">${v||'All'}</button>`).join('')}</div>
 <div class="hscroll" style="white-space:nowrap;margin-bottom:8px">${tags.map(t=>`<span class="chip" data-act="lawTag" data-v="${esc(t)}">${esc(t)}</span>`).join('')}</div><div id="lawlist"></div>`;});
ACT.lawT=el=>{LAWT=el.dataset.v;$$('[data-act=lawT]').forEach(b=>b.classList.toggle('on',b===el));$('#lawlist').innerHTML=lawList($('#lawq').value)};
ACT.lawTag=el=>{const i=$('#lawq');i.value=i.value===el.dataset.v?'':el.dataset.v;$('#lawlist').innerHTML=lawList(i.value)};
function lawList(q){q=(q||'').toLowerCase();const l=DN.CASES.filter(c=>(!LAWT||c.t===LAWT)&&(!q||[c.n,c.c,c.ct,c.s,...c.tags].join(' ').toLowerCase().includes(q)));
 return l.length?l.map(c=>`<div class="card mat"><div class="row between"><span class="eyebrow">${esc(c.ct)}</span><span class="tag">${c.t}</span></div><h3 style="margin:6px 0 2px;font-size:17px">${esc(c.n)}</h3><div class="dim" style="font-family:ui-monospace,SFMono-Regular,monospace">${esc(c.c)}</div><p style="margin:10px 0">${esc(c.s)}</p><div>${c.tags.map(t=>`<span class="tag">${esc(t)}</span>`).join('')}</div></div>`).join(''):`<div class="card empty">No cases match.</div>`;}
/* ===== Settings ===== */
route(/^\/settings$/,()=>{NAV.title='Settings';const o=ST.officer;
 return `<h1 class="big">Settings</h1><p class="sub">All data stays on this device.</p>
 <div class="card mat"><div class="eyebrow" style="margin-bottom:10px">Role</div><div class="seg">${['Officer','DRE'].map(r=>`<button data-act="role" data-v="${r}" class="${ST.role===r?'on':''}">${r==='DRE'?'Drug Recognition Expert':'Officer'}</button>`).join('')}</div><p class="dim">DRE unlocks the 12-step evaluation and Facesheet.</p></div>
 <div class="card mat" id="officer"><div class="eyebrow" style="margin-bottom:10px">Evaluator</div>${['name','badge','agency','dre'].map(k=>`<div class="field"><label>${({name:'Name',badge:'Badge / ID',agency:'Agency',dre:'DRE certification #'})[k]}</label><input class="input" data-o="${k}" value="${esc(o[k]||'')}"></div>`).join('')}</div>
 <div class="card mat"><div class="eyebrow" style="margin-bottom:10px">Appearance</div><div class="seg" style="margin-bottom:12px">${['dark','light'].map(t=>`<button data-act="theme" data-v="${t}" class="${ST.theme===t?'on':''}">${t==='dark'?'Dark':'Light'}</button>`).join('')}</div>
 <div class="toggle ${ST.rt?'on okc':'okc'}" data-act="pref" data-k="rt"><div><div>Reduce transparency</div><div class="dim">Solid bars instead of glass</div></div><div class="sw"></div></div><div class="toggle ${ST.hc?'on okc':'okc'}" data-act="pref" data-k="hc"><div><div>Increase contrast</div></div><div class="sw"></div></div><p class="dim">Reduce Motion follows your system setting.</p></div>
 <div class="card mat"><div class="eyebrow" style="margin-bottom:10px">Instruction language</div><div class="seg"><button data-act="lang" data-v="en" class="${ST.lang==='en'?'on':''}">English</button><button data-act="lang" data-v="es" class="${ST.lang==='es'?'on':''}">Espa\u00f1ol</button></div></div>
 <div class="card mat"><div class="eyebrow" style="margin-bottom:10px">Security</div><button class="btn full" data-act="setPass">${A.i.lock.replace('<svg','<svg width="18" height="18"')}${ST.pass?'Change or remove passcode':'Set a passcode lock'}</button><p class="dim">On iPhone the native app uses Face ID and iOS Data Protection (complete file protection).</p></div>
 <div class="card mat"><div class="eyebrow" style="margin-bottom:10px">Data</div><div class="grid2"><button class="btn" data-act="exportAll">${A.i.share.replace('<svg','<svg width="18" height="18"')}Export JSON</button><button class="btn" data-act="importAll">Import JSON</button></div><button class="btn full danger" style="margin-top:10px" data-act="wipe">${A.i.trash.replace('<svg','<svg width="18" height="18"')}Erase all case data</button></div>
 <p class="dim" style="text-align:center">DRE Nexus 1.0 \u00b7 Reference tool for trained personnel. Not a substitute for training, agency policy or legal advice.</p>`;});
document.addEventListener('input',e=>{if(e.target.dataset.o){ST.officer[e.target.dataset.o]=e.target.value;saveST();}});
ACT.role=el=>{ST.role=el.dataset.v;saveST();render();toast(ST.role==='DRE'?'DRE tools unlocked':'Officer mode')};
ACT.theme=el=>{ST.theme=el.dataset.v;saveST();applyPrefs();render()};
ACT.pref=el=>{ST[el.dataset.k]=!ST[el.dataset.k];saveST();applyPrefs();el.classList.toggle('on',ST[el.dataset.k])};
function applyPrefs(){const h=document.documentElement;h.classList.toggle('light',ST.theme==='light');h.classList.toggle('rt',ST.rt);h.classList.toggle('hc',ST.hc);$('meta[name=theme-color]').content=ST.theme==='light'?'#F2F3F7':'#05070B';}
ACT.exportAll=()=>download('dre-nexus-export.json',JSON.stringify({exported:new Date().toISOString(),cases:CASES},null,2),'application/json');
ACT.importAll=()=>{const i=document.createElement('input');i.type='file';i.accept='application/json';i.onchange=async()=>{try{const j=JSON.parse(await i.files[0].text());for(const c of j.cases||[])await DB.put(c);CASES=await DB.all();toast(`Imported ${j.cases.length} cases`);render()}catch(e){toast('Invalid file','x')}};i.click()};
ACT.wipe=async()=>{if(!confirm('Erase all cases on this device? This cannot be undone.'))return;for(const c of CASES)await DB.del(c.id);CASES=[];CUR=null;toast('All case data erased');render()};
function download(name,data,type){const b=data instanceof Blob?data:new Blob([data],{type});const a=document.createElement('a');a.href=URL.createObjectURL(b);a.download=name;document.body.appendChild(a);a.click();setTimeout(()=>{URL.revokeObjectURL(a.href);a.remove()},1000);}
/* Passcode lock */
async function sha(s){const b=await crypto.subtle.digest('SHA-256',new TextEncoder().encode('dn:'+s));return [...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,'0')).join('');}
function showLock(mode,done){let pin='',first=null;const L=document.createElement('div');L.className='lock';const draw=(msg)=>{L.innerHTML=`<div style="color:var(--acc2)">${A.i.badge.replace('<svg','<svg width="44" height="44"')}</div><h2 style="margin:0">${msg}</h2><div class="pin">${[0,1,2,3,4,5].map(i=>`<i class="${i<pin.length?'f':''}"></i>`).join('')}</div><div class="keypad">${[1,2,3,4,5,6,7,8,9,'',0,'\u232b'].map(k=>k===''?'<span></span>':`<button class="glass" data-k="${k}">${k}</button>`).join('')}</div>${mode!=='unlock'?'<button class="btn sm" data-k="cancel">Cancel</button>':''}`};
 const title={unlock:'Enter passcode',set:'Create a 6-digit passcode',confirm:'Confirm passcode'};let m=mode==='unlock'?'unlock':'set';draw(title[m]);document.body.appendChild(L);
 L.addEventListener('click',async e=>{const b=e.target.closest('[data-k]');if(!b)return;const k=b.dataset.k;if(k==='cancel'){L.remove();return}if(k==='\u232b'){pin=pin.slice(0,-1)}else if(pin.length<6)pin+=k;draw(title[m]);
  if(pin.length===6){if(m==='unlock'){if(await sha(pin)===ST.pass){L.remove();done&&done()}else{L.querySelector('.pin').classList.add('shake');pin='';setTimeout(()=>draw('Try again'),400)}}
   else if(m==='set'){first=pin;pin='';m='confirm';draw(title[m])}else{if(pin===first){ST.pass=await sha(pin);saveST();L.remove();toast('Passcode set');render()}else{pin='';m='set';draw('Didn\u2019t match. Try again')}}}});}
ACT.setPass=()=>{if(ST.pass){openSheet('Passcode',`<button class="btn full" data-act="chPass">Change passcode</button><button class="btn full danger" style="margin-top:10px" data-act="rmPass">Remove passcode</button>`)}else showLock('set')};
ACT.chPass=()=>{closeSheet();showLock('set')};ACT.rmPass=()=>{ST.pass=null;saveST();closeSheet();toast('Passcode removed');render()};
/* Boot */
async function boot(){applyPrefs();await DB.open();CASES=await DB.all();if(!CASES.length&&!S_.get('seeded',false)){const d=demoCase();await DB.put(d);CASES=[d];S_.set('seeded',true)}
 window.addEventListener('hashchange',()=>{const m=location.hash.match(/^#\/case\/([\w]+)/);CUR=m?CASES.find(c=>c.id===m[1])||null:CUR&&location.hash.startsWith('#/case')?CUR:null;render()});
 const m=location.hash.match(/^#\/case\/([\w]+)/);if(m)CUR=CASES.find(c=>c.id===m[1])||null;
 $('#tb-back').addEventListener('click',()=>{const h=$('#tb-back').dataset.href;if(h)location.hash=h;});
 render();if(ST.pass)showLock('unlock');
 if('serviceWorker' in navigator&&location.protocol==='https:')navigator.serviceWorker.register('sw.js').catch(()=>{});
 window.addEventListener('resize',()=>setTab(($('#tabbar a.on')||{}).dataset?.tab));
}
document.addEventListener('DOMContentLoaded',boot);
