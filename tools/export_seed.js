global.window=global;require('../web/data.js');const fs=require('fs');
const out={categories:DN.CATS,matrixRows:DN.MATRIX_ROWS,matrix:DN.MATRIX,footnotes:DN.FOOTNOTES,general:DN.GENERAL,onset:DN.ONSET,admin:DN.ADMIN,overdose:DN.OD,
 substances:DN.SUBSTANCES.map(s=>({...s,flags:s.flags})),caseLaw:DN.CASES,cues:DN.CUES,postStop:DN.POST_STOP,instructions:DN.INSTR,steps:DN.STEPS,norms:DN.NORMS,trendsNote:DN.TRENDS_NOTE,years:DN.YEARS,
 trends:Object.fromEntries(DN.SUBSTANCES.map(s=>[s.id,DN.trend(s)]))};
fs.writeFileSync(__dirname+'/../ios/DRENexus/Seed/seed.json',JSON.stringify(out,null,1));console.log('seed ok',out.substances.length);
