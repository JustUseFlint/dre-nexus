import math
from playwright.sync_api import sync_playwright
dots=''.join(f'<circle cx="{512+290*math.cos(i/7*6.283-1.2):.0f}" cy="{512+290*math.sin(i/7*6.283-1.2):.0f}" r="28" fill="{c}"/>' for i,c in enumerate(['#5B8CFF','#FF6B4A','#C77DFF','#FFC145','#3DDC97','#4FD1E8','#8BD35B']))
svg='''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="W" height="W"><defs><radialGradient id="b" cx=".3" cy=".2" r="1"><stop offset="0" stop-color="#1E4FB8"/><stop offset=".55" stop-color="#0A1630"/><stop offset="1" stop-color="#04060B"/></radialGradient><radialGradient id="g" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#9CC2FF"/><stop offset="1" stop-color="#4C8DFF" stop-opacity="0"/></radialGradient></defs><rect width="1024" height="1024" fill="url(#b)"/><circle cx="512" cy="512" r="330" fill="url(#g)" opacity=".35"/><g fill="none" stroke="#BFD6FF"><circle cx="512" cy="512" r="190" stroke-width="22"/><circle cx="512" cy="512" r="290" stroke-width="8" stroke-dasharray="10 34" opacity=".7"/></g><circle cx="512" cy="512" r="86" fill="#BFD6FF"/><circle cx="480" cy="480" r="26" fill="#fff"/>'''+dots+'</svg>'
open('/workspace/dre-nexus/ios/AppIcon.svg','w').write(svg.replace('width="W" height="W"',''))
with sync_playwright() as p:
  b=p.chromium.launch(executable_path="/usr/bin/google-chrome");pg=b.new_page()
  for s,n in [(1024,'icon-1024.png'),(512,'icon-512.png'),(192,'icon-192.png'),(180,'apple-touch-icon.png')]:
    pg.set_viewport_size({'width':s,'height':s});pg.set_content('<body style="margin:0">'+svg.replace('"W"',f'"{s}"')+'</body>');pg.screenshot(path=f'/workspace/dre-nexus/web/icons/{n}')
  b.close()
