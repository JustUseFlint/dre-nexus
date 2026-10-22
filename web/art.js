/* Custom SVG icon + illustration system for DRE Nexus */
const A = {};
const sv=(vb,inner,cls='')=>`<svg viewBox="${vb}" class="${cls}" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${inner}</svg>`;
A.i = {
 home:sv('0 0 24 24','<path d="M3.5 10.5 12 4l8.5 6.5V19a1.5 1.5 0 0 1-1.5 1.5h-4v-6h-6v6H5A1.5 1.5 0 0 1 3.5 19z"/>'),
 hub:sv('0 0 24 24','<rect x="4" y="4" width="7" height="7" rx="2"/><rect x="13" y="4" width="7" height="7" rx="3.5"/><rect x="4" y="13" width="7" height="7" rx="3.5"/><rect x="13" y="13" width="7" height="7" rx="2"/>'),
 cases:sv('0 0 24 24','<path d="M4 7.5A1.5 1.5 0 0 1 5.5 6H9l2 2h7.5A1.5 1.5 0 0 1 20 9.5v8A1.5 1.5 0 0 1 18.5 19h-13A1.5 1.5 0 0 1 4 17.5z"/><path d="M8 13h8"/>'),
 matrix:sv('0 0 24 24','<rect x="3.5" y="3.5" width="17" height="17" rx="3"/><path d="M3.5 9.5h17M3.5 14.5h17M9.5 3.5v17"/><circle cx="15" cy="12" r="1.4" fill="currentColor"/>'),
 law:sv('0 0 24 24','<path d="M12 4v16M6 20h12M5 8h14"/><path d="m5 8-2.5 6a3 3 0 0 0 5 0zM19 8l-2.5 6a3 3 0 0 0 5 0z"/>'),
 gear:sv('0 0 24 24','<circle cx="12" cy="12" r="3"/><path d="M12 2.8v2.4M12 18.8v2.4M2.8 12h2.4M18.8 12h2.4M5.5 5.5l1.7 1.7M16.8 16.8l1.7 1.7M5.5 18.5l1.7-1.7M16.8 7.2l1.7-1.7"/>'),
 back:sv('0 0 24 24','<path d="M15 5l-7 7 7 7"/>'),
 chev:sv('0 0 24 24','<path d="M9 6l6 6-6 6"/>'),
 plus:sv('0 0 24 24','<path d="M12 5v14M5 12h14"/>'),
 minus:sv('0 0 24 24','<path d="M5 12h14"/>'),
 x:sv('0 0 24 24','<path d="M6 6l12 12M18 6 6 18"/>'),
 check:sv('0 0 24 24','<path d="m5 12.5 4.5 4.5L19 7.5"/>'),
 search:sv('0 0 24 24','<circle cx="11" cy="11" r="6.5"/><path d="m20 20-4.2-4.2"/>'),
 mic:sv('0 0 24 24','<rect x="9" y="3.5" width="6" height="11" rx="3"/><path d="M5.5 11.5a6.5 6.5 0 0 0 13 0M12 18v2.5"/>'),
 speak:sv('0 0 24 24','<path d="M4 9.5h3.5L12 5.5v13l-4.5-4H4z"/><path d="M15.5 9a4 4 0 0 1 0 6M18 6.5a7.5 7.5 0 0 1 0 11"/>'),
 cam:sv('0 0 24 24','<path d="M4 8.5A1.5 1.5 0 0 1 5.5 7h2l1.5-2h6l1.5 2h2A1.5 1.5 0 0 1 20 8.5v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 17.5z"/><circle cx="12" cy="13" r="3.5"/>'),
 timer:sv('0 0 24 24','<circle cx="12" cy="13.5" r="7"/><path d="M12 13.5V9.5M10 3h4M18 7l1.5-1.5"/>'),
 doc:sv('0 0 24 24','<path d="M6.5 3.5h7l4 4v12a1 1 0 0 1-1 1h-10a1 1 0 0 1-1-1v-15a1 1 0 0 1 1-1z"/><path d="M13.5 3.5v4h4M8.5 12h7M8.5 15.5h7"/>'),
 share:sv('0 0 24 24','<path d="M12 15V3.5M8 7.5l4-4 4 4"/><path d="M6.5 11H6a1.5 1.5 0 0 0-1.5 1.5v6A1.5 1.5 0 0 0 6 20h12a1.5 1.5 0 0 0 1.5-1.5v-6A1.5 1.5 0 0 0 18 11h-.5"/>'),
 eye:sv('0 0 24 24','<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/><circle cx="12" cy="12" r="3"/>'),
 pulse:sv('0 0 24 24','<path d="M3 12h4l2-5 4 10 2-5h6"/>'),
 lock:sv('0 0 24 24','<rect x="5" y="10.5" width="14" height="10" rx="2.5"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/>'),
 badge:sv('0 0 24 24','<path d="M12 3 19 6v5.5c0 4.4-3 8.2-7 9.5-4-1.3-7-5.1-7-9.5V6z"/><path d="m9 12 2 2 4-4"/>'),
 car:sv('0 0 24 24','<path d="M4 16.5v-4l2-5h12l2 5v4"/><path d="M3.5 12.5h17v4h-17z"/><circle cx="7.5" cy="17" r="1.6"/><circle cx="16.5" cy="17" r="1.6"/>'),
 flask:sv('0 0 24 24','<path d="M9.5 3.5h5M10.5 3.5v5L5 18.5A1.5 1.5 0 0 0 6.3 20.5h11.4a1.5 1.5 0 0 0 1.3-2L13.5 8.5v-5"/><path d="M7.5 14.5h9"/>'),
 trash:sv('0 0 24 24','<path d="M5 7h14M10 7V4.5h4V7M7 7l1 13h8l1-13"/>'),
 play:sv('0 0 24 24','<path d="M8 5.5v13l10-6.5z" fill="currentColor"/>'),
 pause:sv('0 0 24 24','<path d="M8 5v14M16 5v14" stroke-width="3"/>'),
 reset:sv('0 0 24 24','<path d="M4.5 12a7.5 7.5 0 1 0 2.2-5.3M4.5 4.5v4h4"/>'),
 pen:sv('0 0 24 24','<path d="M4 20l4-1 11-11-3-3L5 16z"/><path d="M14 6l3 3"/>'),
 moon:sv('0 0 24 24','<path d="M19 14.5A7.5 7.5 0 0 1 9.5 5a7.5 7.5 0 1 0 9.5 9.5z"/>'),
 scan:sv('0 0 24 24','<path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"/><path d="M7.5 9v6M10.5 9v6M13 9v6M16.5 9v6"/>')
};
/* 7 DRE category glyphs, drawn on a 48 grid with category color */
A.cat = function(id,size=44){
 const c=(DN.CATS_ALL.find(x=>x.id===id)||{color:'#888'}).color;
 const g={
  DEP:`<path d="M10 18c4 0 4 6 8 6s4-6 8-6 4 6 8 6" /><path d="M10 27c4 0 4 6 8 6s4-6 8-6 4 6 8 6" opacity=".55"/><path d="M24 8v6m-3-3 3 3 3-3"/>`,
  STI:`<path d="M26 7 14 26h9l-2 15 13-21h-9z" fill="${c}" fill-opacity=".18"/>`,
  HAL:`<path d="M6 24s7-11 18-11 18 11 18 11-7 11-18 11S6 24 6 24z"/><path d="M24 24m-1.5 0a1.5 1.5 0 1 1 3 0 4 4 0 1 1-8 0 6.5 6.5 0 1 1 13 0" />`,
  DA:`<circle cx="24" cy="24" r="14" stroke-dasharray="4 4"/><path d="M24 10v28" /><circle cx="17" cy="24" r="3" fill="${c}" fill-opacity=".3"/><path d="M28 21h6M28 27h4"/>`,
  NA:`<circle cx="24" cy="22" r="3.2" fill="${c}"/><path d="M24 18.8c-2-6-8-8-10-4s3 7 6.8 7.2M27.2 22c6 .2 9-4 6-7s-7 0-8.4 3.8M24 25.2c2 6 8 7 10 3s-3-7-6.8-6.2M20.8 22c-6-.2-9 4-6 7s7 0 8.4-3.8"/><path d="M24 25v15"/>`,
  INH:`<rect x="15" y="16" width="12" height="24" rx="3"/><path d="M18 16v-4h6v4M21 12V9h5"/><path d="M31 12c3-1 4 2 7 1M31 18c3-1 4 2 7 1M30 24c3-1 4 2 7 1" opacity=".7"/>`,
  CAN:`<path d="M24 40V22"/><path d="M24 22c-1-6 0-11 0-14 0 3 1 8 0 14zM24 24c-4-4-9-5-12-5 3 1 7 4 12 5zM24 24c4-4 9-5 12-5-3 1-7 4-12 5zM24 27c-4-1-8 0-11 2 3 0 7-1 11-2zM24 27c4-1 8 0 11 2-3 0-7-1-11-2z" fill="${c}" fill-opacity=".25"/>`,
  NONE:`<rect x="12" y="18" width="24" height="12" rx="6"/><path d="M24 18v12"/>`
 }[id]||'';
 return `<svg viewBox="0 0 48 48" width="${size}" height="${size}" fill="none" stroke="${c}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="1" y="1" width="46" height="46" rx="14" fill="${c}" fill-opacity=".12" stroke="${c}" stroke-opacity=".25" stroke-width="1"/>${g}</svg>`;
};
/* Reference visuals: packaging / paraphernalia illustrations */
A.ref = function(s){
 const c=(DN.CATS_ALL.find(x=>x.id===s.cat)||{}).color||'#888';
 const kinds=[];
 const r=s.routes.toLowerCase(), id=s.id;
 if(/lsd/.test(id)) kinds.push('blotter'); else if(/psilo/.test(id)) kinds.push('mush');
 else if(['cannabis','delta8','syncann'].includes(id)) kinds.push(id==='syncann'?'packet':'leaf');
 else if(s.cat==='INH') kinds.push(id==='nitrous'?'charger':'can');
 else if(/powder|insuff|smoked/.test(r)&&s.type==='Illicit') kinds.push('powder');
 if(/oral|sublingual/.test(r)&&!kinds.includes('blotter')&&!kinds.includes('mush')&&!kinds.includes('leaf')) kinds.push(/syrup|codeine|dxm|ghb/.test(id+s.official.toLowerCase())?'bottle':'pill');
 if(/inject/.test(r)) kinds.push('syringe');
 if(/transdermal/.test(r)) kinds.push('patch');
 if(/smoked/.test(r)&&s.cat!=='CAN'&&s.cat!=='INH') kinds.push('pipe');
 const art={
  pill:`<ellipse cx="60" cy="62" rx="34" ry="17" fill="${c}" fill-opacity=".85"/><ellipse cx="60" cy="58" rx="34" ry="17" fill="${c}"/><path d="M42 58h36" stroke="#000" stroke-opacity=".35" stroke-width="2.5"/><ellipse cx="50" cy="52" rx="10" ry="3" fill="#fff" opacity=".35"/>`,
  powder:`<path d="M18 78h84l-12-14c-8-10-18-24-30-24S38 54 30 64z" fill="#EDEFF3"/><path d="M40 60c8-6 16-4 22 0" stroke="#C9CED8" stroke-width="2"/><rect x="66" y="22" width="34" height="24" rx="4" fill="${c}" fill-opacity=".3" stroke="${c}" stroke-width="2"/><path d="M66 30h34" stroke="${c}"/>`,
  blotter:`<rect x="22" y="22" width="76" height="56" rx="4" fill="#F5F1E6"/><path d="M41 22v56M60 22v56M79 22v56M22 40h76M22 59h76" stroke="#BFB7A0" stroke-dasharray="2 3"/><circle cx="60" cy="50" r="16" fill="${c}" opacity=".6"/><circle cx="60" cy="50" r="8" fill="#FFC145" opacity=".8"/>`,
  mush:`<path d="M30 52c0-18 14-26 30-26s30 8 30 26z" fill="#B78A5A"/><circle cx="48" cy="40" r="4" fill="#E7D2B4"/><circle cx="70" cy="36" r="3" fill="#E7D2B4"/><path d="M54 52c0 12-4 20-6 26h22c-2-6-6-14-6-26" fill="#EDE3D3"/>`,
  leaf:`<g transform="translate(60 80)" fill="${c}"><path d="M0 0C-2-20 0-44 0-56 0-44 2-20 0 0z"/><path d="M0-4C-12-18-30-24-40-24-30-20-16-10 0-4z"/><path d="M0-4C12-18 30-24 40-24 30-20 16-10 0-4z"/><path d="M0-8C-8-26-18-40-26-46-20-36-10-20 0-8z"/><path d="M0-8C8-26 18-40 26-46 20-36 10-20 0-8z"/></g>`,
  packet:`<path d="M30 20h60l-4 60H34z" fill="${c}" fill-opacity=".85"/><path d="M30 20h60v8H30z" fill="#000" opacity=".25"/><circle cx="60" cy="54" r="12" fill="#fff" opacity=".85"/><path d="M54 54l4 4 8-8" stroke="${c}" stroke-width="3" fill="none"/>`,
  can:`<rect x="42" y="26" width="36" height="56" rx="6" fill="#C9D1DE"/><rect x="42" y="40" width="36" height="22" fill="${c}"/><rect x="52" y="14" width="16" height="12" rx="2" fill="#8A93A3"/><path d="M68 18h12" stroke="#8A93A3" stroke-width="4"/><path d="M86 14c6-2 8 3 14 1M86 22c6-2 8 3 14 1" stroke="${c}" stroke-width="2" opacity=".7"/>`,
  charger:`<rect x="30" y="38" width="58" height="22" rx="11" fill="#C9D1DE"/><path d="M88 44h10v10H88" fill="#8A93A3"/><ellipse cx="38" cy="30" rx="12" ry="14" fill="${c}" opacity=".8"/><path d="M38 44v-2" stroke="${c}"/>`,
  bottle:`<rect x="44" y="34" width="32" height="46" rx="6" fill="${c}" fill-opacity=".75"/><rect x="47" y="20" width="26" height="14" rx="3" fill="#E9ECF1"/><rect x="48" y="46" width="24" height="18" rx="2" fill="#fff" opacity=".9"/><path d="M52 52h16M52 57h10" stroke="#9AA3B2" stroke-width="2"/>`,
  syringe:`<g transform="rotate(-35 60 50)"><rect x="30" y="44" width="50" height="12" rx="2" fill="#E9ECF1"/><rect x="34" y="46" width="26" height="8" fill="${c}" opacity=".7"/><path d="M80 50h22M24 50h6M20 42v16" stroke="#C9D1DE" stroke-width="3"/></g>`,
  patch:`<rect x="30" y="28" width="60" height="44" rx="12" fill="#E9DCCB"/><rect x="40" y="38" width="40" height="24" rx="6" fill="${c}" opacity=".35"/><path d="M48 50h24" stroke="${c}" stroke-width="2"/>`,
  pipe:`<path d="M24 64h50" stroke="#C9D1DE" stroke-width="6"/><circle cx="84" cy="58" r="14" fill="none" stroke="#C9D1DE" stroke-width="4"/><circle cx="84" cy="58" r="6" fill="${c}" opacity=".5"/><path d="M84 40c-2-6 4-8 2-14" stroke="#9AA3B2" stroke-width="2" opacity=".6"/>`
 };
 const names={pill:'Tablet / capsule',powder:'Powder / bindle',blotter:'Blotter paper',mush:'Dried mushroom',leaf:'Plant material',packet:'Retail packet',can:'Canister / aerosol',charger:'Charger & balloon',bottle:'Liquid / syrup',syringe:'Injection kit',patch:'Transdermal patch',pipe:'Smoking device'};
 return [...new Set(kinds)].slice(0,4).map(k=>`<figure class="card" style="margin:0;padding:10px;text-align:center"><svg viewBox="0 0 120 100" class="svgbox"><rect width="120" height="100" rx="14" fill="#0E131C"/>${art[k]}</svg><figcaption class="dim" style="margin-top:6px">${names[k]}</figcaption></figure>`).join('');
};
/* SFST diagrams */
A.wat = function(p1=[],p2=[],turnBad=false){
 const step=(i,y,bad,pass)=>{const x=24+i*30;return `<g><rect x="${x-9}" y="${y-6}" width="22" height="12" rx="6" fill="${bad?'#FF5A5F':'#4C8DFF'}" opacity="${bad?1:.8}" transform="rotate(${pass===1?0:180} ${x+2} ${y})"/><text x="${x+2}" y="${y+22}" text-anchor="middle" font-size="9" fill="currentColor" opacity=".6">${i+1}</text></g>`;};
 let s='';for(let i=0;i<9;i++){s+=step(i,36,p1.includes(i+1),1);s+=step(8-i,82,p2.includes(i+1),2);} 
 return `<svg viewBox="0 0 300 120" class="svgbox"><path d="M10 59h280" stroke="currentColor" stroke-opacity=".35" stroke-width="2" stroke-dasharray="6 5"/><text x="10" y="14" font-size="10" fill="currentColor" opacity=".6">PASS 1 \u2192</text><text x="290" y="114" text-anchor="end" font-size="10" fill="currentColor" opacity=".6">\u2190 PASS 2</text>${s}<path d="M282 36c14 6 14 40 0 46" stroke="${turnBad?'#FF5A5F':'#7FB0FF'}" stroke-width="2" fill="none" stroke-dasharray="3 3"/><text x="270" y="62" font-size="9" fill="currentColor" opacity=".7">turn</text></svg>`;
};
A.ols = ()=>`<svg viewBox="0 0 200 160" class="svgbox"><g stroke="currentColor" stroke-width="5" stroke-linecap="round" fill="none"><circle cx="100" cy="24" r="12"/><path d="M100 36v52M100 50l-14 34M100 50l14 34M100 88l-6 60M100 88l22 34 18 0"/></g><path d="M140 122v26" stroke="#4C8DFF" stroke-width="2" stroke-dasharray="3 3"/><text x="146" y="140" font-size="11" fill="#7FB0FF">~6 in</text><path d="M60 150h80" stroke="currentColor" opacity=".3"/><text x="12" y="20" font-size="11" fill="currentColor" opacity=".6">Count \u201cone thousand one\u2026\u201d</text></svg>`;
A.hgn = ()=>`<svg viewBox="0 0 240 140" class="svgbox"><circle cx="120" cy="120" r="10" fill="currentColor" opacity=".8"/><path d="M120 120 L20 120 A100 100 0 0 1 220 120 Z" fill="#4C8DFF" fill-opacity=".06" stroke="currentColor" stroke-opacity=".25"/><path d="M120 120 L49.3 49.3" stroke="#FFB547" stroke-width="2" stroke-dasharray="4 3"/><path d="M120 120 L190.7 49.3" stroke="#FFB547" stroke-width="2" stroke-dasharray="4 3"/><text x="40" y="44" font-size="11" fill="#FFB547">45\u00b0</text><text x="186" y="44" font-size="11" fill="#FFB547">45\u00b0</text><path d="M120 120 L20 120M120 120 L220 120" stroke="#FF5A5F" stroke-width="2"/><text x="10" y="136" font-size="10" fill="#FF9A9D">max deviation</text><text x="168" y="136" font-size="10" fill="#FF9A9D">max deviation</text><text x="120" y="14" text-anchor="middle" font-size="10" fill="currentColor" opacity=".6">12\u201315 in from nose, slightly above eye level</text></svg>`;
A.loc = ()=>`<svg viewBox="0 0 240 150" class="svgbox"><circle cx="120" cy="58" r="40" fill="none" stroke="#4C8DFF" stroke-width="2" stroke-dasharray="5 4"/><path d="M120 18 a40 40 0 1 1 -0.1 0" stroke="#4C8DFF" stroke-width="2" fill="none" marker-end="url(#ah)"/><path d="M120 98 V128" stroke="#FFB547" stroke-width="2.5"/><path d="m114 122 6 8 6-8" stroke="#FFB547" stroke-width="2.5" fill="none"/><text x="132" y="122" font-size="10" fill="#FFB547">to bridge of nose (~2 in)</text><ellipse cx="96" cy="142" rx="12" ry="6" fill="none" stroke="currentColor"/><ellipse cx="144" cy="142" rx="12" ry="6" fill="none" stroke="currentColor"/><circle cx="101" cy="142" r="3" fill="currentColor"/><circle cx="139" cy="142" r="3" fill="currentColor"/></svg>`;
A.rom = ()=>`<svg viewBox="0 0 200 170" class="svgbox"><g stroke="currentColor" stroke-width="5" stroke-linecap="round" fill="none"><circle cx="104" cy="26" r="12" transform="rotate(-18 100 40)"/><path d="M100 40v56M100 54l-8 40M100 54l8 40M98 96l-4 64M102 96l4 64"/></g><path d="M70 30a40 40 0 0 1 20-18" stroke="#7FB0FF" stroke-width="2" fill="none"/><text x="20" y="24" font-size="10" fill="#7FB0FF">head back, eyes closed</text><path d="M60 110c-12 0-12-20 0-20M140 110c12 0 12-20 0-20" stroke="#FFB547" stroke-width="2" fill="none"/><text x="148" y="104" font-size="10" fill="#FFB547">sway</text><text x="100" y="168" text-anchor="middle" font-size="10" fill="currentColor" opacity=".6">estimate 30 seconds</text></svg>`;
A.ftn = (marks={})=>{ const pts={tip:[100,84],pad:[100,92],bridge:[100,58],upperlip:[100,104],cheekL:[78,86],cheekR:[122,86],missed:[60,120]};
 const dots=Object.entries(marks).map(([i,loc])=>{const p=pts[loc]||pts.missed;const off=(+i-3)*5;return `<g><circle cx="${p[0]+off}" cy="${p[1]}" r="7" fill="${loc==='tip'?'#34D399':'#FF5A5F'}" opacity=".9"/><text x="${p[0]+off}" y="${p[1]+3.5}" text-anchor="middle" font-size="9" fill="#000" font-weight="700">${+i+1}</text></g>`;}).join('');
 return `<svg viewBox="0 0 200 150" class="svgbox"><path d="M100 20c30 0 46 22 46 52 0 34-20 62-46 62s-46-28-46-62c0-30 16-52 46-52z" fill="currentColor" fill-opacity=".06" stroke="currentColor" stroke-opacity=".35"/><path d="M80 66h12M108 66h12" stroke="currentColor" stroke-opacity=".5" stroke-width="2.5"/><path d="M100 60v24l-6 4" stroke="currentColor" stroke-opacity=".45" fill="none"/><path d="M88 108c8 4 16 4 24 0" stroke="currentColor" stroke-opacity=".45"/>${dots}</svg>`;};
A.pupil = (mm)=>{const r=Math.max(1.5,Math.min(9,mm))*2.4;return `<svg viewBox="0 0 48 48" width="40" height="40"><circle cx="24" cy="24" r="22" fill="#5B6F8F"/><circle cx="24" cy="24" r="22" fill="none" stroke="#2C3A52" stroke-width="2"/><circle cx="24" cy="24" r="${r}" fill="#000"/><circle cx="${24-r/2.2}" cy="${24-r/2.2}" r="${Math.max(1,r/4)}" fill="#fff" opacity=".7"/></svg>`;};
A.body = function(sel={},side='front',mode='inject'){
 const regions=[['head',100,30,16,18],['neck',100,56,8,6],['chestL',84,86,14,16],['chestR',116,86,14,16],['abdomen',100,124,22,18],['armUL',62,92,7,22],['armUR',138,92,7,22],['elbowL',58,122,7,7],['elbowR',142,122,7,7],['forearmL',54,146,6,18],['forearmR',146,146,6,18],['handL',52,176,7,9],['handR',148,176,7,9],['thighL',88,182,10,26],['thighR',112,182,10,26],['kneeL',88,214,8,7],['kneeR',112,214,8,7],['calfL',88,242,7,20],['calfR',112,242,7,20],['footL',86,272,9,6],['footR',114,272,9,6]];
 const col=mode==='tone'?{normal:'#34D399',flaccid:'#5B8CFF',rigid:'#FF6B4A'}:null;
 const hs=regions.map(([k,cx,cy,rx,ry])=>{const key=side+'.'+k;const v=sel[key];const fill=v?(col?col[v]||'#FF5A5F':(v==='fresh'?'#FF5A5F':'#FFB547')):'rgba(127,176,255,.10)';return `<ellipse class="hot" data-k="${key}" cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="${fill}" stroke="rgba(127,176,255,.35)"/>`;}).join('');
 return `<svg viewBox="0 0 200 290" class="svgbox"><path d="M100 12c10 0 17 8 17 18s-7 20-17 20-17-10-17-20 7-18 17-18zM92 50h16l2 10c14 2 26 6 30 14l10 44 6 54-8 4-12-52-6-20 2 40 4 36-6 60 2 30h-16l-4-62-3-40-3 40-4 62H83l2-30-6-60 4-36 2-40-6 20-12 52-8-4 6-54 10-44c4-8 16-12 30-14z" fill="currentColor" fill-opacity=".07" stroke="currentColor" stroke-opacity=".3"/>${hs}<text x="100" y="288" text-anchor="middle" font-size="9" fill="currentColor" opacity=".55">${side==='front'?'FRONT':'BACK'} \u00b7 subject\u2019s left on right</text></svg>`;
};
A.heroArt = ()=>`<svg viewBox="0 0 240 240"><defs><radialGradient id="g1" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#7FB0FF" stop-opacity=".9"/><stop offset="1" stop-color="#4C8DFF" stop-opacity="0"/></radialGradient></defs><circle cx="130" cy="110" r="90" fill="url(#g1)" opacity=".35"/><g fill="none" stroke="#9CC2FF" stroke-opacity=".55"><circle cx="130" cy="110" r="44"/><circle cx="130" cy="110" r="64" stroke-dasharray="2 6"/><circle cx="130" cy="110" r="84" stroke-opacity=".25"/></g><circle cx="130" cy="110" r="22" fill="#0B1428" stroke="#9CC2FF"/><circle cx="130" cy="110" r="9" fill="#9CC2FF"/><circle cx="124" cy="104" r="3" fill="#fff"/>${DN.CATS.map((c,i)=>{const a=i/7*Math.PI*2-1.2;return `<circle cx="${130+64*Math.cos(a)}" cy="${110+64*Math.sin(a)}" r="5" fill="${c.color}"/>`}).join('')}</svg>`;
A.reportArt = (k)=>{const m={vehicle:A.i.car,sfst:A.i.pulse,dre:A.i.eye,tox:A.i.flask,opinion:A.i.matrix};return `<span style="display:inline-grid;place-items:center;width:36px;height:36px;border-radius:11px;background:rgba(76,141,255,.14);color:#7FB0FF">${(m[k]||A.i.doc).replace('<svg','<svg width="20" height="20"')}</span>`;};
