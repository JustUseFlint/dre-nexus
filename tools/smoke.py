import sys,json
from playwright.sync_api import sync_playwright
BASE=sys.argv[1] if len(sys.argv)>1 else 'http://localhost:8765/'
OUT='/workspace/dre-nexus/docs/screenshots/'
errs=[]
with sync_playwright() as p:
  b=p.chromium.launch(executable_path='/usr/bin/google-chrome')
  for name,vp,mob in [('iphone',{'width':390,'height':844},True),('desktop',{'width':1280,'height':900},False)]:
    ctx=b.new_context(viewport=vp,device_scale_factor=3 if mob else 1,is_mobile=mob,has_touch=mob,accept_downloads=True)
    pg=ctx.new_page()
    pg.on('console',lambda m:errs.append(f'{name} console {m.type}: {m.text}') if m.type in('error','warning') else None)
    pg.on('pageerror',lambda e:errs.append(f'{name} pageerror: {e}'))
    pg.goto(BASE);pg.wait_for_timeout(1200)
    cid=pg.evaluate('CASES[0].id')
    def shot(h,fn,scroll=0,full=False):
      pg.evaluate(f'location.hash="{h}"');pg.wait_for_timeout(900)
      if scroll: pg.evaluate(f'scrollTo(0,{scroll})');pg.wait_for_timeout(500)
      ov=pg.evaluate('document.documentElement.scrollWidth>innerWidth+1')
      if ov: errs.append(f'{name} overflow on {h}: '+str(pg.evaluate('''[...document.querySelectorAll("#view *")].filter(e=>e.getBoundingClientRect().right>innerWidth+1).slice(0,3).map(e=>e.tagName+"."+e.className).join(" | ")''')))
      if mob or fn in ('home','drug'): pg.screenshot(path=f'{OUT}{name}-{fn}.png',full_page=full)
    routes=[('#/','home'),('#/hub','hub'),('#/drug/fentanyl','drug'),('#/drug/carisoprodol','drug-soma'),('#/match','match'),('#/matrix','matrix'),('#/law','law'),('#/cases','cases'),('#/settings','settings'),
      (f'#/case/{cid}','case'),(f'#/case/{cid}/sfst','sfst'),(f'#/case/{cid}/facesheet','facesheet')]
    for k in ['cues','contact','info','pbt','hgn','wat','ols','loc','rom','ftn','aride']: routes.append((f'#/case/{cid}/sfst/{k}','sfst-'+k))
    routes.append((f'#/case/{cid}/dre','dre'))
    for n in range(1,13): routes.append((f'#/case/{cid}/dre/{n}',f'dre-step{n:02d}'))
    for h,fn in routes: shot(h,fn)
    if mob:
      shot('#/drug/fentanyl','drug-full',full=True); shot(f'#/case/{cid}/facesheet','facesheet-full',full=True)
      shot(f'#/case/{cid}/sfst/wat','sfst-wat-scrolled',scroll=700)
      shot(f'#/case/{cid}/dre/7','dre-step07-scrolled',scroll=0)
      # matrix sheet
      pg.evaluate(f'location.hash="#/case/{cid}/dre/11"');pg.wait_for_timeout(800);pg.click('#fab');pg.wait_for_timeout(900);pg.screenshot(path=OUT+'iphone-matrix-sheet.png');pg.click('#sheet [data-act=closeSheet]');pg.wait_for_timeout(600)
      # match tool interaction
      pg.evaluate('location.hash="#/match"');pg.wait_for_timeout(700)
      for k,v in [('hgn','present'),('vgn','present'),('loc','present'),('pupil','normal'),('pulse','up'),('bp','up'),('temp','up'),('tone','rigid')]:
        pg.click(f'#match-form [data-seg="{k}"] button[data-v="{v}"]')
      pg.wait_for_timeout(500);top=pg.evaluate('evaluate(MATCH).cats[0].cat.id');print('match DA test top:',top);pg.screenshot(path=OUT+'iphone-match-result.png',full_page=True)
      # new case walk-through SFST
      pg.evaluate('location.hash="#/cases"');pg.wait_for_timeout(600);pg.click('.view .btn.pri');pg.wait_for_timeout(900)
      nid=pg.evaluate('CUR.id')
      pg.evaluate(f'location.hash="#/case/{nid}/sfst/hgn"');pg.wait_for_timeout(700)
      for e in ['L','R']:
        for k in ['smooth','maxdev','onset']: pg.click(f'[data-tog="sfst.hgn.{e}.{k}"]')
      pg.wait_for_timeout(300);print('hgn clues',pg.evaluate('hgnClues(CUR.sfst.hgn)'))
      pg.screenshot(path=OUT+'iphone-hgn-6clues.png')
      pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      pg.click('[data-tog="sfst.wat.balance"]');pg.click('[data-arr="sfst.wat.ht1"][data-v="4"]');pg.click('[data-tog="sfst.wat.turn"]')
      print('wat',pg.evaluate('watClues(CUR.sfst.wat).n'))
      pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      pg.click('[data-tog="sfst.ols.sway"]');pg.click('[data-inc="sfst.ols.down"][data-d="1"]');print('ols',pg.evaluate('olsClues(CUR.sfst.ols)'))
      pg.click('[data-act=tStart]');pg.wait_for_timeout(1200);pg.click('[data-act=tStop]');print('timer ms',pg.evaluate('tVal("sfst.ols.timer")'))
      pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      pg.click('[data-seg="sfst.loc.L"] button[data-v=present]');pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      pg.click('[data-act=tStart]');pg.wait_for_timeout(1100);pg.click('[data-act=romStop]');print('rom est',pg.evaluate('CUR.sfst.rom.est'));pg.click('[data-tog="sfst.rom.eyelid"]');pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      for i in range(6): pg.click(f'[data-seg="sfst.ftn.att.{i}.loc"] button[data-v="{"tip" if i%2 else "pad"}"]')
      pg.screenshot(path=OUT+'iphone-ftn-entered.png');pg.click('[data-act=secDone]');pg.wait_for_timeout(800)
      pg.fill('#note-aride','Subject evaluated, DRE requested.');pg.click('[data-act=addNote][data-sec=aride]')
      # DRE wizard walk with complete
      pg.evaluate(f'location.hash="#/case/{nid}/dre/1"');pg.wait_for_timeout(700)
      for n in range(1,13):
        if n==3: pg.fill('[data-b="dre.prelim.pulse"]','96')
        if n==6: pg.fill('[data-b="dre.vitals.sys"]','150');pg.fill('[data-b="dre.vitals.dia"]','96');pg.fill('[data-b="dre.vitals.temp"]','100.1')
        if n==7:
          for k in ['roomL','roomR']: pg.click(f'[data-pp="dre.dark.{k}"][data-v="6"]')
          pg.click('[data-seg="dre.dark.rtl"] button[data-v=slow]')
        if n==8: pg.click('[data-seg="dre.tone.overall"] button[data-v=rigid]');pg.click('.bodymap .hot[data-k="front.thighL"]')
        if n==9: pg.click('.bodymap .hot[data-k="front.elbowR"]')
        if n==11: pg.wait_for_timeout(300);print('opinion top',pg.evaluate('evaluate(caseIndicators(CUR)).cats.slice(0,3).map(x=>x.cat.id+":"+Math.round(x.score*100))'));pg.screenshot(path=OUT+'iphone-dre-step11-opinion.png')
        pg.click('[data-act=stepDone]');pg.wait_for_timeout(700)
      print('dre progress',pg.evaluate('dreProgress(CUR)'),'at',pg.evaluate('location.hash'))
      with pg.expect_download() as d: pg.click('.view [data-act=exportPDF]')
      d.value.save_as('/workspace/dre-nexus/docs/sample-new-case.pdf')
      pg.evaluate(f'CUR=CASES.find(c=>c.id=="{cid}");location.hash="#/case/{cid}/facesheet"');pg.wait_for_timeout(800)
      with pg.expect_download() as d: pg.click('.view [data-act=exportPDF]')
      d.value.save_as('/workspace/dre-nexus/docs/sample-facesheet.pdf')
      # light mode shot
      pg.evaluate('ST.theme="light";applyPrefs();location.hash="#/drug/methamphetamine"');pg.wait_for_timeout(900);pg.screenshot(path=OUT+'iphone-light-drug.png')
      pg.evaluate('ST.theme="dark";saveST();applyPrefs()')
    ctx.close()
  b.close()
print('\n'.join(errs) or 'NO ERRORS')
