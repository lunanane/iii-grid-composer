  current_page=1; menu_active=false; pages={}
function draw()
  grid_led_all(0)
  if pages[current_page] and pages[current_page].draw then pages[current_page]:draw() end
  if menu_active then
    for p=1,16 do grid_led(p,8, p==current_page and 15 or (pages[p] and 4 or 0)) end
    local pg=pages[current_page]; if pg.menu_draw then pg:menu_draw() end
  end
  grid_led(16,8,menu_active and 15 or 6); grid_refresh()
end
event_grid=function(x,y,z)
  if x==16 and y==8 then
    if z==1 then menu_active=not menu_active end return
  end
  if menu_active then
    local pg=pages[current_page]
    if pg.menu_event and pg:menu_event(x,y,z) then return end
    if y==8 and z==1 and pages[x] then current_page=x; menu_active=false end return
  end
  if pages[current_page] then pages[current_page]:event(x,y,z) end
end
local clk=0; local stut=0; local g_meas=0
function event_midi(d1,d2,d3)
  if d1==248 then
    if SC.loading then return end
    clk=clk+1; g_meas=g_meas+1; SC.clk_run=true
    if pages[3] then pages[3]:clock_pulse_tick() end
    if pages[4] then pages[4]:clock_pulse() end
    if g_meas>=96 then g_meas=0; if pages[3] then pages[3]:bar_tick() end
      if SC.pend then SC.loadq=SC.pend; SC.pend=nil end end  -- queue quantized recall; applied off the clock ISR
    local s=pages[2]
    if s then
      if s.armed_sync_reset and g_meas==0 then
        s.row8_held={}; s.stutter_anchor=nil; s.armed_sync_reset=false; s.master_position=1
        for r=1,6 do s.positions[r]=1 end; s:fire_current_notes(); clk=0; stut=0; return
      end
      if s.stutter_anchor then
        stut=stut+1; if stut>=s.stutter_speed then
          stut=0; s.flash_state=not s.flash_state; s.master_position=s.stutter_anchor
          for r=1,6 do s.positions[r]=((s.stutter_anchor-1)%s.lengths[r])+1 end; s:fire_current_notes()
        end
        if clk>=6 then clk=0 end
      elseif clk>=6 then clk=0; stut=0; s:clock_tick() end
    end
  elseif d1==250 or d1==251 then
    clk=1; stut=0; g_meas=0
    if pages[2] then pages[2].master_position=1; for y=1,6 do pages[2].positions[y]=1 end; pages[2]:fire_current_notes() end
    if pages[3] then pages[3].bar_c=0; pages[3].g_ptr=1; pages[3].g_acc=0; pages[3].a_ptr=1; pages[3].a_acc=0
      if pages[3].run then pages[3].c_stage=1; pages[3]:f_st() end
    end
    if pages[4] then pages[4]:reset() end
  elseif d1==252 then
    SC.clk_run=false
    if pages[3] then pages[3]:k_c(); pages[3]:k_l() end
    if pages[4] then pages[4]:killall() end
    for n=0,127 do for c=1,7 do midi_note_off(n,0,c) end end
  end
end
function framework_tick() for i=1,#pages do if pages[i].update then pages[i]:update() end end; SC:service(); draw() end
-- GLOBAL velocity-groove engine. g=1 -> no groove (return base). g=2..16 -> math accent
-- patterns over a 16-step phase, velocity mapped into 60%..85% (76..108). No tables.
function vgv(g,i,base)
  if g<=1 then return base end
  local n=g-1; local p=(i-1)%16; local sh
  if n<=4 then local k=(n==1 and 4)or(n==2 and 2)or(n==3 and 8)or 3; sh=(p%k==0) and 1 or 0.15
  elseif n<=8 then local m=n-4; local k=(m<=2 and 4)or(m==3 and 2)or 8; local o=(m==1 and 2)or(m==4 and 4)or 1; sh=((p-o)%k==0) and 1 or 0.2
  elseif n<=12 then local f=n-8; sh=(math.sin(p/16*f*6.2832)+1)*0.5
  else local f=n-12; local a=(p%4==0) and 1 or 0; local b=(math.sin((p+1)/16*f*6.2832)+1)*0.35; sh=(a>b) and a or b end
  return math.floor(76+32*sh+0.5)
end

-- =============================================================================
-- PAGE 1: PERFORMANCE — left 8x8 = transpose/mutes, right 8x8 = faders
-- faders ease over FT seconds on the framework metro (FD period) — no MIDI clock needed
pages[1]={name="perf",cc_ch=1,cc_base=20,FT=0.5,FD=0.03,fbank=1,nbank=5,
  fv={},ft={},fs={},fr={},fl={},f_c=0,bl=false,mult=1,gpos=5,
  init=function(s)
    for i=1,s.nbank*8 do s.fv[i]=0;s.ft[i]=0;s.fs[i]=0;s.fr[i]=s.FT;s.fl[i]=-1 end
    for f=1,8 do local i=f; s.fv[i]=102;s.ft[i]=102;s.fs[i]=102;s.fl[i]=102; s:send_cc(s.cc_base+i-1,102) end  -- bank 1 ~80% (volume)
  end,
  send_cc=function(s,num,val) midi_cc(num,val,s.cc_ch) end,
  fidx=function(s,f) return (s.fbank-1)*8+f end,
  set_bank=function(s,b) if b>=1 and b<=s.nbank then s.fbank=b end end,
  set_tpose=function(s,r,col)
    local off=(col-5)*s.mult
    if r==1 then local p=pages[3]; if p then p.arp_tpos=col; p.arp_tpose=off end
    else local t=pages[4] and pages[4].tk[r-1]; if t then t.tpos=col; t.tpose=off end end
  end,
  apply_mult=function(s)  -- rescale all transposes live when the multiplier (row 6) changes
    for r=1,4 do
      if r==1 then local p=pages[3]; if p then p.arp_tpose=(p.arp_tpos-5)*s.mult end
      else local t=pages[4] and pages[4].tk[r-1]; if t then t.tpose=(t.tpos-5)*s.mult end end
    end
    if pages[4] then pages[4].gtpose=(s.gpos-5)*s.mult end
  end,
  update=function(s)
    s.f_c=(s.f_c+1)%16; s.bl=(s.f_c<8)
    for i=1,s.nbank*8 do
      if s.fr[i]<s.FT then
        s.fr[i]=s.fr[i]+s.FD
        local t=s.fr[i]/s.FT; if t>1 then t=1 end
        local e=t*(2-t)                       -- ease-out (logarithmic-ish settle)
        local v=s.fs[i]+(s.ft[i]-s.fs[i])*e; s.fv[i]=v
        local iv=math.floor(v+0.5)
        if iv~=s.fl[i] then s.fl[i]=iv; s:send_cc(s.cc_base+i-1,iv) end
      end
    end
  end,
  menu_draw=function(s) for b=1,5 do grid_led(16,b, b==s.fbank and 15 or 4) end end,
  menu_event=function(s,x,y,z) if z==1 and x==16 and y<=7 then s:set_bank(y);menu_active=false;return true end return false end,
  draw=function(s)
    if SC.view then SC:draw_left(s); SC:draw_row8(s) else
    local mut=pages[2] and pages[2].mute
    -- y1: drum mutes (x1..6), blink when muted
    for x=1,8 do local led=1
      if x<=6 then local m=mut and mut[x]; led=m and(s.bl and 15 or 3)or 6 end
      grid_led(x,1,led)
    end
    -- y2=arp, y3..5=mono 1..3 : col1=mute, cols2..8=transpose (center col5, -3..+3)
    for y=2,5 do
      local r=y-1; local pos,muted
      if r==1 then pos=(pages[3] and pages[3].arp_tpos) or 5; muted=pages[3] and pages[3].amute
      else local t=pages[4] and pages[4].tk[r-1]; pos=(t and t.tpos) or 5; muted=t and t.mute end
      for x=1,8 do local led
        if x==1 then led=muted and(s.bl and 15 or 8)or 3
        else led=(x==5) and 4 or 2; if x==pos then led=15 end end
        grid_led(x,y,led)
      end
    end
    -- y6: multiplier
    for x=1,8 do grid_led(x,6,(x==s.mult) and 15 or 2) end
    -- y7: global transpose radio (home col4)
    for x=1,8 do grid_led(x,7,(x==s.gpos) and 15 or((x==5) and 4 or 2)) end
    for x=1,8 do grid_led(x,8, x==1 and 8 or 1) end
    end
    -- RIGHT 8x8: 8 vertical faders; fill reaches the pressed cell (7-segment map)
    for f=1,8 do
      local i=s:fidx(f); local x=8+f; local lvl=math.floor(s.fv[i]/127*7+0.5)
      for y=1,8 do local cell=9-y; grid_led(x,y,((cell-1)<=lvl) and 7 or 2) end
    end
  end,
  melo=function(s,x,y,z)
    if z~=1 then return end
    local r=y-1
    if x==1 then
      if r==1 then local p=pages[3]; if p then p.amute=not p.amute; if p.amute then p:k_c();p:k_l() end end
      else local t=pages[4] and pages[4].tk[r-1]; if t then t.mute=not t.mute end end
      return
    end
    if x>=2 and x<=8 then s:set_tpose(r,x) end
  end,
  event=function(s,x,y,z)
    if x>=9 and x<=16 then
      if z~=1 then return end
      local i=s:fidx(x-8); s.fs[i]=s.fv[i]; s.ft[i]=math.floor((8-y)/7*127+0.5); s.fr[i]=0; return
    end
    if SC.view then SC:event(x,y,z); return end
    if y>=2 and y<=5 then s:melo(x,y,z); return end
    if z~=1 then return end
    if y==8 then if x==1 then SC.view=true end return end
    if y==1 then if x<=6 and pages[2] then pages[2].mute[x]=not pages[2].mute[x] end return end
    if y==6 then s.mult=x; s:apply_mult(); return end
    if y==7 then s.gpos=x; if pages[4] then pages[4].gtpose=(x-5)*s.mult end return end
  end
}
pages[2]={name="seq",steps={},positions={},lengths={},vg={},master_position=1,master_length=16,row8_held={},stutter_anchor=nil,stutter_speed=6,flash_state=false,armed_sync_reset=false,notes={60,61,62,63,64,65},ch=2,first_press={},resize_action_happened=false,mute={},active=1,off_n={},off_c={},dlen=1,
  init=function(s) for y=1,6 do s.steps[y]={}; for x=1,16 do s.steps[y][x]=false end; s.positions[y]=1; s.lengths[y]=16; s.first_press[y]=nil; s.vg[y]=1 end; s.active=1; s.master_position=1; s.master_length=16; s.row8_held={}; s.stutter_anchor=nil; s.stutter_speed=6; s.flash_state=false; s.armed_sync_reset=false end,
  recalc_mb=function(s) local m=1; for y=1,6 do if s.lengths[y]>m then m=s.lengths[y] end end; s.master_length=m; if s.master_position>s.master_length then s.master_position=1 end end,
  recalc_st=function(s) local min_x=99; local max_x=0; local c=0; for x=1,15 do if s.row8_held[x] then c=c+1; if x<min_x then min_x=x end; if x>max_x then max_x=x end end end
    if c==0 then s.stutter_anchor=nil; s.armed_sync_reset=false else s.stutter_anchor=min_x; local sp=max_x-min_x; s.stutter_speed=(sp==0 and 6 or (sp==1 and 12 or (sp==2 and 8 or (sp==3 and 6 or (sp==4 and 4 or 3))))) end end,
  fire_current_notes=function(s) for y=1,6 do if s.steps[y][s.positions[y]] and not s.mute[y] then local nt=s.notes[y];midi_note_on(nt,vgv(s.vg[y],s.positions[y],100),s.ch);s.off_n[y]=nt;s.off_c[y]=s.dlen end end end,
  clock_tick=function(s) s.master_position=s.master_position+1; if s.master_position>s.master_length then s.master_position=1 end; for y=1,6 do s.positions[y]=s.positions[y]+1; if s.positions[y]>s.lengths[y] then s.positions[y]=1 end end; s:fire_current_notes() end,
  update=function(s) for y=1,6 do local c=s.off_c[y]; if c then if c<=1 then midi_note_off(s.off_n[y],0,s.ch);s.off_c[y]=nil;s.off_n[y]=nil else s.off_c[y]=c-1 end end end end,
  menu_event=function(s,x,y,z)  -- menu on: tap any track row to clear it (full length, no notes)
    if z==1 and y>=1 and y<=6 then s.lengths[y]=16; for i=1,16 do s.steps[y][i]=false end; s.positions[y]=1; s:recalc_mb(); return true end
    return false
  end,
  draw=function(s)
    for y=1,6 do local l=s.lengths[y]; local p=s.positions[y]; local act=(y==s.active)
      for x=1,16 do local led=0
        if x<=l then led=s.steps[y][x] and 8 or (act and 3 or 2); if x==1 or x==l then led=math.max(led,act and 6 or 4) end; if x==p then led=13 end end
        grid_led(x,y,led)
      end
    end
    -- row 7: velocity-groove radio for the ACTIVE track; (1,7) overloads to stutter sync-arm when a stutter is live
    for x=1,16 do local led
      if x==1 and s.stutter_anchor~=nil then led=s.armed_sync_reset and 15 or 4
      else led=(x==s.vg[s.active]) and 15 or (x==1 and 3 or 2) end
      grid_led(x,7,led)
    end
    for x=1,15 do local led=0; if x<=s.master_length then if s.row8_held[x] then led=s.flash_state and 15 or 6 elseif x==s.master_position and s.stutter_anchor==nil then led=11 else led=4 end end; grid_led(x,8,led) end; grid_led(16,8,4)
  end,
  event=function(s,x,y,z)
    if y==8 then if x==16 then return end; if z==1 and x<=s.master_length then s.row8_held[x]=true; s:recalc_st(); if s.stutter_anchor==x then s.master_position=x; for r=1,6 do s.positions[r]=((x-1)%s.lengths[r])+1 end; s.flash_state=true; s:fire_current_notes() end else s.row8_held[x]=nil; s:recalc_st() end return end
    if y==7 then
      if z~=1 then return end
      if x==1 and s.stutter_anchor~=nil then s.armed_sync_reset=true; return end
      s.vg[s.active]=x; return
    end
    if z==1 then if s.first_press[y]==nil then s.first_press[y]=x; s.resize_action_happened=false else local st=s.first_press[y]; if st==1 and x>1 then s.lengths[y]=x; s.active=y; s.resize_action_happened=true; if s.positions[y]>s.lengths[y] then s.positions[y]=1 end; s:recalc_mb() end end
    else if s.first_press[y]==x then if not s.resize_action_happened then s.steps[y][x]=not s.steps[y][x] end; s.first_press[y]=nil; s.resize_action_happened=false end end
  end
}

-- =============================================================================
-- MONOME III — PAGE 3: ARP/CHORD ENGINE + CLIP LAUNCHER + PATTERN RECORDER
pages[3]={name="arp",ch=3,cam={{64,69,62,67,60,65},{61,66,71,64,69,62},{71,66,63,68,63,70},{68,63,70,65,60,67}},
sc_maj={0,2,4,5,7,9,11},sc_min={0,2,3,5,7,8,10},
-- chord types selectable by the 8 mod pads (1..8): maj, min, maj7, min7, dom7, sus4, dim, aug
cdeg={{0},{0,1,4},{0,2,4},{0,3,4},{0,4},{0,2,4,5},{0,2,4,6},{0,2,4,6,8}},
cabs={{0,4,7,10},{0,4,7,11},{0,3,6},{0,4,8},{0,4,6,10},{0,4,8,10},{0,1,4,7}},
-- grooves packed as 16-bit masks: bit (i-1) set => step i active
glib={65535,21845,52428,18761,61166,28013,6745,4369,22875,26214,48059,27437,19609,27997,61713,63761},
sel_mod=1,sel_size=5,mod_held=false,last_root=nil,amute=false,arp_tpose=0,arp_tpos=5,
a_n={},l_n={},durs={},a_r={},a_m={},a_g={},a_t={},a_s={},a_d={},a_vg={},a_min={},a_pm={},a_set={},
cpb={},cpool3={},dgb={},ob={},sm={5,4,3,2},
sel_t=1,sel_s=1,sel_d=1,sel_g=1,blink=false,f_c=0,run=true,
q_t=nil,q_s=nil,q_d=nil,q_size=nil,q_g=nil,q_lroot=nil,q_mod=nil,
g_ptr=1,g_acc=0,a_ptr=1,a_acc=0,l_arp=nil,ll_arp=nil,l_acc=0,l_g_ptr=1,l_a_ptr=1,
m_div={[1]=12,[2]=8,[3]=6,[4]=4},
c_stage=1,bar_c=0,h_row=nil,fl_row=nil,fl_c=0,sel_vg=1,pulse=8,pn=8,koct=0,inv=0,
pmode=1,lock_r=60,lock_mn=false,center_held=false,gate=nil,
live_override=false,live_pending_off=false,
arp_sq={1,3,2,4,3,5,4,6},

init=function(s)
  for y=1,8 do s.durs[y]=1;s.a_m[y]=1;s.a_t[y]=1;s.a_s[y]=1;s.a_d[y]=1;s.a_g[y]=1;s.a_vg[y]=1;s.a_min[y]=false;s.a_pm[y]=1;s.a_set[y]=nil end
end,

-- groove bit test (packed glib)
gbit=function(s,g,i) local m=s.glib[g] or s.glib[1]; return (m>>(i-1))&1==1 end,
-- scale exposed to follower pages: current root + diatonic interval set
scale_set=function(s)
  local r,mn
  if s.pmode>=2 then r=s.lock_r; mn=s.lock_mn
  elseif s.last_root then r=s:rv(s.last_root); mn=(s.last_root.x%2==0)
  elseif s.a_r[s.c_stage] then r=s.a_r[s.c_stage]; mn=s.a_min[s.c_stage]
  else r=60; mn=false end
  r=54+((r-54)%12)   -- fold tonic into one register so key changes move followers minimally
  return r,(mn and s.sc_min or s.sc_maj)
end,
scale_deg=function(s,d)  -- d = scale-degree index (can be -/+/multi-octave)
  local r,iv=s:scale_set()
  return r+12*(d//7)+iv[(d%7)+1]
end,
deg_is_root=function(s,d) return d%7==0 end,
-- nearest scale-degree index for a chromatic note (for the arp scale filter)
note_to_deg=function(s,n)
  local r,iv=s:scale_set()
  local rel=n-r; local oct=rel//12; local pc=rel%12
  local best,bd=99,0
  for di=0,6 do local dd=math.abs(iv[di+1]-pc); if dd<best then best=dd;bd=di end end
  local dw=math.abs(12-pc); if dw<best then best=dw;bd=7 end
  return oct*7+bd
end,
-- snap chord to scale, shift T degrees, keep voices distinct (bump collisions up)
deg_scale_filter=function(s,notes,T)
  local degs=s.dgb; for i=#degs,1,-1 do degs[i]=nil end
  for _,n in ipairs(notes) do degs[#degs+1]=s:note_to_deg(n) end
  table.sort(degs)
  for i=2,#degs do if degs[i]<=degs[i-1] then degs[i]=degs[i-1]+1 end end
  local out=s.ob; for i=#out,1,-1 do out[i]=nil end
  for _,d in ipairs(degs) do local nn=s:scale_deg(d+T); if nn>=0 and nn<=127 then out[#out+1]=nn end end
  return out
end,
-- resolve last_root to midi note
rv=function(s,lr)
  if not lr then return nil end
  return s.cam[lr.x] and s.cam[lr.x][lr.y]
end,
-- degree index of a note within the locked scale (nearest), and the scale-note at a grid cell
dlk=function(s,note) local iv=s.lock_mn and s.sc_min or s.sc_maj;local rel=note-s.lock_r;local oct=rel//12;local off=rel%12;local b=1;local bd=99;for i=1,7 do local dd=iv[i]-off;if dd<0 then dd=-dd end;if dd<bd then bd=dd;b=i end end;return oct*7+(b-1) end,
gnote=function(s,x,y) local iv=s.lock_mn and s.sc_min or s.sc_maj;local d=(x-1)*6+(6-y);return s.lock_r+12*(d//7)+iv[(d%7)+1] end,

c_pool=function(s,r,m,mn)
  local p=s.cpb; for i=#p,1,-1 do p[i]=nil end
  if not r or s.amute then return p end
  local ko=12*s.koct
  local lk=s.pmode>=2 and s.lock_r
  if m>8 then local rr=r
    if lk then local iv=s.lock_mn and s.sc_min or s.sc_maj;local d=s:dlk(r);rr=s.lock_r+12*(d//7)+iv[(d%7)+1] end
    for _,i in ipairs(s.cabs[m-8]) do p[#p+1]=rr+i+ko end
  elseif lk then local iv=s.lock_mn and s.sc_min or s.sc_maj;local d0=s:dlk(r)
    for _,cd in ipairs(s.cdeg[m]) do local d=d0+cd;p[#p+1]=s.lock_r+12*(d//7)+iv[(d%7)+1]+ko end
  else local iv=mn and s.sc_min or s.sc_maj
    for _,d in ipairs(s.cdeg[m]) do p[#p+1]=r+12*(d//7)+iv[(d%7)+1]+ko end
  end
  if #p>s.sel_size then for i=#p,s.sel_size+1,-1 do p[i]=nil end end
  local T=(s.arp_tpose or 0)+((pages[4] and pages[4].gtpose) or 0)
  if T~=0 then p=s:deg_scale_filter(p,T) end
  local iv=s.inv or 0
  if iv~=0 and #p>0 then local n=#p
    for _=1,(iv>0 and iv or -iv) do
      if iv>0 then local mi=1;for j=2,n do if p[j]<p[mi] then mi=j end end;p[mi]=p[mi]+12
      else local ma=1;for j=2,n do if p[j]>p[ma] then ma=j end end;p[ma]=p[ma]-12 end
    end
  end
  return p
end,
g_co=function(s,r) if r then for x=1,4 do for y=1,6 do if s.cam[x][y]==r then return x,y end end end end end,
-- live chord pool: held grid notes in mode 3, otherwise the built chord
lpool=function(s,rv,mn) if s.pmode==3 then return s.cpool3 end;return s:c_pool(rv,s.sel_mod,mn) end,
-- stage voicing: pmode-3 stages replay their stored custom note set; others build from root+type
spool=function(s,r) if s.a_pm[r]==3 and s.a_set[r] then return s.a_set[r] end;return s:c_pool(s.a_r[r],s.a_m[r],s.a_min[r]) end,
c_arp=function(s,p,d,st,alt)
  if #p==0 then return nil end;local l=#p;local pi
  if d==1 then pi=p[((st-1)%l)+1] elseif d==2 then pi=p[l-((st-1)%l)]
  elseif d==3 then local cy=l*2;local ph=(st-1)%cy;pi=ph<l and p[ph+1] or p[cy-ph]
  elseif d==4 then local sq=s.arp_sq;pi=p[((sq[((st-1)%#sq)+1]-1)%l)+1] end
  if alt and st%2==0 and pi then pi=pi+12 end;return pi
end,
k_c=function(s) for n in pairs(s.a_n) do midi_note_off(n,0,s.ch);s.a_n[n]=nil end;if s.l_arp then midi_note_off(s.l_arp,0,s.ch);s.l_arp=nil end end,
k_l=function(s) for n in pairs(s.l_n) do midi_note_off(n,0,s.ch);s.l_n[n]=nil end;if s.ll_arp then midi_note_off(s.ll_arp,0,s.ch);s.ll_arp=nil end end,
-- gate length in framework-ticks (~30ms each) scaled by velocity: louder = a touch longer
cl=function(s,v) local g=2+(v-76)//8; return g<2 and 2 or(g>6 and 6 or g) end,
-- f_r always kills previous arranger notes first — no l_n cross-check to avoid stale accumulation
f_r=function(s,r) s:k_c();local v=vgv(s.a_vg[r] or s.sel_vg,s.g_ptr,95);for _,n in ipairs(s:spool(r)) do midi_note_on(n,v,s.ch);s.a_n[n]=true end;s.gate=s:cl(v) end,
f_st=function(s) s:k_c();if not s.run then return end;if (s.a_t[s.c_stage] or 1)==1 and (s.a_s[s.c_stage] or 1)==1 and s.a_r[s.c_stage] then s:f_r(s.c_stage) end end,

-- apply q_lroot or q_mod on quarter-note boundary
apply_q=function(s)
  if s.q_lroot then
    local ql=s.q_lroot;s.q_lroot=nil;s.q_mod=nil;s:k_l();s.sel_mod=ql.m
    local qt=ql.t
    if qt==1 and ql.s==1 then s.gate=nil;for _,n in ipairs(s.pmode==3 and s.cpool3 or s:c_pool(ql.rv,ql.m,ql.mn)) do midi_note_on(n,105,s.ch);s.l_n[n]=true end
    elseif qt==1 and ql.s>1 then s.l_acc=999;s.l_g_ptr=1
    elseif qt==2 or qt==3 then s.l_acc=999;s.l_a_ptr=1;s.l_g_ptr=1 end
  elseif s.q_mod then
    local qm=s.q_mod;s.q_mod=nil;s.sel_mod=qm;s:k_l()
    local rv=s:rv(s.last_root)
    if s.sel_t==1 and s.sel_s==1 then
      if rv then for _,n in ipairs(s:c_pool(rv,qm,s.last_root and s.last_root.x%2==0)) do midi_note_on(n,105,s.ch);s.l_n[n]=true end end
    elseif s.sel_t==1 and s.sel_s>1 then s.l_acc=999;s.l_g_ptr=1
    elseif s.sel_t==2 or s.sel_t==3 then s.l_acc=999;s.l_a_ptr=1;s.l_g_ptr=1 end
  end
end,

-- tick live arp/groove layer (last_root held)
tick_live=function(s,rv)
  local mn=s.last_root and(s.last_root.x%2==0)or false
  if s.sel_t==1 and s.sel_s>1 then
    s.l_acc=s.l_acc+1
    if s.l_acc>=s.m_div[s.sel_s] then
      s.l_acc=0;s:k_l()
      if s:gbit(s.sel_g,s.l_g_ptr) then local v=vgv(s.sel_vg,s.l_g_ptr,105);for _,n in ipairs(s:lpool(rv,mn)) do midi_note_on(n,v,s.ch);s.l_n[n]=true end;s.gate=s:cl(v) end
      s.l_g_ptr=(s.l_g_ptr%16)+1
    end
  elseif s.sel_t==2 or s.sel_t==3 then
    s.l_acc=s.l_acc+1
    if s.l_acc>=s.m_div[s.sel_s] then
      s.l_acc=0
      if s:gbit(s.sel_g,s.l_g_ptr) then
        if s.ll_arp then midi_note_off(s.ll_arp,0,s.ch);s.ll_arp=nil end
        local p=s:c_arp(s:lpool(rv,mn),s.sel_d,s.l_a_ptr,s.sel_t==3)
        if p then local v=vgv(s.sel_vg,s.l_g_ptr,105);midi_note_on(p,v,s.ch);s.ll_arp=p;s.gate=s:cl(v) end
        s.l_a_ptr=s.l_a_ptr+1
      end
      s.l_g_ptr=(s.l_g_ptr%16)+1
    end
  end
end,

clock_pulse_tick=function(s)
  if g_meas%24==0 then s:apply_q() end
  local rv=s:rv(s.last_root)
  if rv then s:tick_live(rv) end
  if s.run and not s.h_row and not s.live_override then
    local t=s.a_t[s.c_stage] or 1;local sp=s.a_s[s.c_stage] or 1;local d=s.a_d[s.c_stage] or 1
    if t==1 and sp>1 then
      s.g_acc=s.g_acc+1
      if s.g_acc>=s.m_div[sp] then s.g_acc=0;s:k_c();if s:gbit(s.a_g[s.c_stage],s.g_ptr) then s:f_r(s.c_stage) end;s.g_ptr=(s.g_ptr%16)+1 end
    elseif t==2 or t==3 then
      s.a_acc=s.a_acc+1
      if s.a_acc>=s.m_div[sp] then
        s.a_acc=0
        if s:gbit(s.a_g[s.c_stage],s.g_ptr) then
          if s.l_arp then midi_note_off(s.l_arp,0,s.ch);s.l_arp=nil end
          local p=s:c_arp(s:spool(s.c_stage),d,s.a_ptr,t==3)
          if p then local v=vgv(s.a_vg[s.c_stage] or s.sel_vg,s.g_ptr,98);midi_note_on(p,v,s.ch);s.l_arp=p;s.gate=s:cl(v) end;s.a_ptr=s.a_ptr+1
        end
        s.g_ptr=(s.g_ptr%16)+1
      end
    end
  end
end,

bar_tick=function(s)
  local qc=false
  if s.q_t then s.sel_t=s.q_t;s.q_t=nil;qc=true end
  if s.q_s then s.sel_s=s.q_s;s.q_s=nil;qc=true end
  if s.q_d then s.sel_d=s.q_d;s.q_d=nil;qc=true end
  if s.q_size then s.sel_size=s.q_size;s.q_size=nil;qc=true end
  if s.q_g then s.sel_g=s.q_g;s.q_g=nil;qc=true end
  if qc then s.l_acc=999;s.l_g_ptr=1;s.l_a_ptr=1 end
  if s.live_pending_off then
    s.live_pending_off=false;s.live_override=false
    s.g_ptr=1;s.a_ptr=1;s.g_acc=0;s.a_acc=0;s:f_st()
  end
  if not s.run then return end
  s.bar_c=s.bar_c+1
  if s.bar_c>=(s.durs[s.c_stage] or 1) then
    s.bar_c=0;local le=1;for r=1,8 do if s.a_r[r] then le=r end end
    s.c_stage=(s.c_stage%le)+1;s.g_ptr=1;s.a_ptr=1;s.g_acc=0;s.a_acc=0;s:f_st()
  end
end,

update=function(s)
  s.f_c=(s.f_c+1)%48;s.blink=(s.f_c%16<8)
  local ts=s.f_c/48; local trs=ts<0.5 and ts*2 or 2-ts*2; s.pulse=8+math.floor(trs*7+0.5)   -- slow settings breath 8..15
  local tn=(s.f_c%10)/10; local trn=tn<0.5 and tn*2 or 2-tn*2; local en=trn*trn*(3-2*trn); s.pn=5+math.floor(en*10+0.5)  -- fast eased note pulse 5..15
  if s.fl_row then s.fl_c=s.fl_c+1;if s.fl_c>14 then s.fl_row=nil;s.fl_c=0 end end
  if s.gate then if s.gate<=1 then s:k_c();s:k_l();s.gate=nil else s.gate=s.gate-1 end end
end,

draw=function(s)
  local tg=s.h_row or s.c_stage;local fcx,fcy=s:g_co(s.a_r[tg])
  local at=s.h_row and s.a_t[s.h_row] or (s.q_t or s.sel_t)
  local pul=s.pulse
  -- SECTION: chord roots x1..4, y1..6 (mode3 = scale-note grid; else Camelot major-first)
  local lcx,lcy; if s.pmode==2 then lcx,lcy=s:g_co(s.lock_r) end
  for y=1,6 do for x=1,4 do
    local led
    if s.pmode==3 then
      led=(((x-1)*6+(6-y))%7==0) and (s.blink and 15 or 6) or 5   -- locked tonic strong-blinks
      local gn=s:gnote(x,y);for i=1,#s.cpool3 do if s.cpool3[i]==gn then led=15;break end end
    else
      led=(x==1 or x==3) and 5 or 3
      if s.h_row then if fcx==x and fcy==y and at~=4 then led=s.pn end
      elseif s.run and fcx==x and fcy==y and at~=4 then led=s.pn end
      if lcx==x and lcy==y then led=s.blink and 15 or 4 end   -- locked tonic strong-blinks
      if s.last_root and y==s.last_root.y and x==s.last_root.x then led=15 end
    end
    grid_led(x,y,led)
  end end
  -- SECTION: type/speed/dir/size x5..8, y1..4 (unselected OFF, selection breathes)
  local sm=s.sm;local asize=s.q_size or s.sel_size
  for x=5,8 do
    local v=x-4;local as=s.h_row and s.a_s[s.h_row] or(s.q_s or s.sel_s);local ad=s.h_row and s.a_d[s.h_row] or(s.q_d or s.sel_d)
    grid_led(x,1,at==v and pul or 0)
    grid_led(x,2,as==v and pul or 0)
    grid_led(x,3,ad==v and pul or 0)
    grid_led(x,4,(sm[x-4]==asize) and pul or 0)
  end
  -- SECTION: groove 4x4 x5..8, y5..8 (unselected base 6; selected pulses with its gate)
  local ag=s.h_row and s.a_g[s.h_row] or(s.q_g or s.sel_g)
  for y=5,8 do for x=5,8 do local idx=((y-5)*4)+(x-4)
    grid_led(x,y, idx==ag and (s:gbit(ag,s.g_ptr) and 15 or 7) or 6) end end
  -- SECTION: chord mod x1..4, y7..8 (single 1-8; two-button 9-15 shown on src pad, root pad dim)
  local eff_mod=(s.q_lroot and s.q_lroot.m) or s.q_mod
  local sm9=s.sel_mod;local selp=sm9<=8 and sm9 or sm9-7
  local effp=eff_mod and(eff_mod<=8 and eff_mod or eff_mod-7)
  local av=s.a_m[tg];local amp=av and(av<=8 and av or av-7)
  for y=7,8 do for x=1,4 do
    local mi=((y-7)*4)+x;local led=0
    if s.h_row then if amp==mi and at~=4 then led=pul end
    elseif s.run and amp==mi and at~=4 then led=pul end
    if mi==selp then led=15 end
    if sm9>8 and mi==1 and selp~=1 then led=pul end
    if effp and mi==effp and mi~=selp then led=pul end
    grid_led(x,y,led)
  end end
  if s.q_lroot and s.q_lroot.co then local co=s.q_lroot.co;grid_led(co.x,co.y,pul) end
  -- SECTION: arranger (tracker) x9..12, y1..8 — duration + playhead
  for y=1,8 do
    local has=s.a_r[y]~=nil; local dur=s.durs[y] or 1
    for x=9,12 do local col=x-8; local led
      if not has then led=1 elseif col<dur then led=3 elseif col==dur then led=10 else led=2 end
      if y==s.c_stage and s.run then if col==dur then led=pul elseif col<dur then led=5 end end
      if s.fl_row==y and s.fl_c%3<2 then led=15 end
      grid_led(x,y,led)
    end
  end
  -- SECTION: velocity-groove radio 4x4 x13..16, y1..4 (selected pad brightness = current output velocity)
  local cvg=s.h_row and s.a_vg[s.h_row] or s.sel_vg
  for y=1,4 do for x=13,16 do local idx=((y-1)*4)+(x-12); local led
    if idx==cvg then local cv=vgv(cvg,s.g_ptr,100); led=4+math.floor((cv-76)/32*11+0.5); if led<4 then led=4 elseif led>15 then led=15 end
    else led=(idx==1) and 3 or 2 end
    grid_led(x,y,led)
  end end
  -- modifier block x13..16, y5..7
  for y=5,7 do grid_led(13,y,0) end                                  -- x13 reserved (arp-octave)
  grid_led(14,5, s.pmode==1 and 15 or 3)                             -- x14: key mode
  grid_led(14,6, s.pmode==2 and 15 or (s.center_held and 9 or 6))    --      locked-scale (hold+key=lock)
  grid_led(14,7, s.pmode==3 and 15 or 3)                             --      scale-grid
  grid_led(16,5, s.koct==1 and 15 or 3)                               -- x16: key octave +1
  grid_led(16,6, s.koct==0 and 12 or 5)                               --      home (0)
  grid_led(16,7, s.koct==-1 and 15 or 3)                              --      -1
  grid_led(15,6, 6)                                                   -- x15: inversion dial center (press = 0)
  grid_led(15,5, s.inv>0 and math.min(15,6+s.inv*3) or 2)             --      up: brighter with +inversions
  grid_led(15,7, s.inv<0 and math.min(15,6-s.inv*3) or 2)             --      down: brighter with -inversions
  -- transport: (13,8)=run/stop
  grid_led(13,8, s.run and 6 or (s.blink and 15 or 2))
  grid_led(14,8,0)                                                 -- (14,8) free (strum removed)
end,

menu_event=function(s,x,y,z)  -- menu on: tap a tracker row (arranger zone x9..12) to clear it
  if z==1 and x>=9 and x<=12 and y>=1 and y<=8 then
    s.a_r[y]=nil;s.durs[y]=1;s.a_m[y]=1;s.a_t[y]=1;s.a_s[y]=1;s.a_d[y]=1;s.a_g[y]=1;s.a_pm[y]=1;s.a_set[y]=nil;return true
  end
  return false
end,
event=function(s,x,y,z)
  -- arranger (tracker) x9..12, y1..8: x encodes duration (1..4); writes current chord/params into row y
  if x>=9 and x<=12 and y<=8 then
    if z==1 then
      if s.pmode==3 then                                  -- capture live Plinky voicing into the stage
        local set=s.a_set[y]; if not set then set={};s.a_set[y]=set end
        for i=#set,1,-1 do set[i]=nil end
        for i=1,#s.cpool3 do if i<=6 then set[i]=s.cpool3[i] end end
        s.a_pm[y]=3; s.a_r[y]=set[1]
      else
        local rv=s:rv(s.last_root)
        s.a_r[y]=rv or s.a_r[y]; s.a_pm[y]=1; s.a_set[y]=nil
        if s.last_root then s.a_min[y]=(s.last_root.x%2==0) end
        s.a_m[y]=(s.q_lroot and s.q_lroot.m) or s.q_mod or s.sel_mod
      end
      s.a_t[y]=s.sel_t;s.a_s[y]=s.sel_s;s.a_d[y]=s.sel_d;s.a_g[y]=s.sel_g;s.a_vg[y]=s.sel_vg;s.durs[y]=x-8
      s.fl_row=y;s.fl_c=0;s.h_row=y
    else if s.h_row==y then s.h_row=nil;s:f_st() end end;return
  end
  -- velocity-groove radio x13..16, y1..4
  if x>=13 and x<=16 and y<=4 then if z==1 then local idx=((y-1)*4)+(x-12); if s.h_row then s.a_vg[s.h_row]=idx else s.sel_vg=idx end end;return end
  -- x16 key-octave radio (y5=+1, y6=0, y7=-1)
  if x==16 and y>=5 and y<=7 then if z==1 then s.koct=(y==5 and 1) or (y==6 and 0) or -1 end;return end
  -- x15 inversion dial (y6 center=reset, y5=up, y7=down)
  if x==15 and y>=5 and y<=7 then if z==1 then if y==6 then s.inv=0 elseif y==5 then s.inv=math.min(6,s.inv+1) else s.inv=math.max(-6,s.inv-1) end end;return end
  -- x14 play-mode radio (y5=key, y6=locked-scale[hold+key=lock], y7=scale-grid)
  if x==14 and y>=5 and y<=7 then
    if z==1 then s:k_l();for i=#s.cpool3,1,-1 do s.cpool3[i]=nil end;s.last_root=nil;s.q_lroot=nil
      if y==5 then s.pmode=1 elseif y==6 then s.pmode=2;s.center_held=true else s.pmode=3 end
    else if y==6 then s.center_held=false end end
    return
  end
  -- type/speed/dir/size x5..8, y1..4
  if x>=5 and x<=8 and y<=4 then
    if z==1 then
      local v=x-4;local tg=s.h_row or s.c_stage
      if y==4 then v=s.sm[v] end
      if s.h_row then
        if y==1 then s.a_t[tg]=v;if v==4 then s:k_c() end elseif y==2 then s.a_s[tg]=v elseif y==3 then s.a_d[tg]=v end
      else
        if y==1 then s.q_t=v elseif y==2 then s.q_s=v elseif y==3 then s.q_d=v elseif y==4 then s.q_size=v end
      end
    end;return
  end
  -- groove 4x4 x5..8, y5..8
  if x>=5 and x<=8 and y>=5 and y<=8 then
    if z==1 then local g=((y-5)*4)+(x-4);if s.h_row then s.a_g[s.h_row]=g else s.q_g=g end end;return
  end
  -- transport: run/stop (13,8)
  if x==13 and y==8 then if z==1 then s.run=not s.run;if s.run then s:f_st() else s:k_c() end end;return end
  -- chord mod x1..4, y7..8  (pad1="root"; hold pad1 + another = two-button extended type)
  if y>=7 and x<=4 then
    local m=((y-7)*4)+x
    if z==1 then
      local mv=(s.mod_held and m>1) and (8+(m-1)) or m
      if m==1 then s.mod_held=true end
      if s.h_row then s.a_m[s.h_row]=mv end
      if s.sel_t==1 and s.sel_s==1 then
        s.sel_mod=mv;s.q_mod=nil;s:k_l()
        if s.last_root then
          local rv=s:rv(s.last_root)
          for _,n in ipairs(s:c_pool(rv,mv,s.last_root.x%2==0)) do midi_note_on(n,105,s.ch);s.l_n[n]=true end
        end
      elseif s.q_lroot then s.q_lroot.m=mv;s.q_mod=nil
      else s.q_mod=mv end
    else
      if m==1 then s.mod_held=false end
    end;return
  end
  -- chord roots x1..4, y1..6
  if x<=4 and y<=6 then
    if s.pmode==3 then                                   -- scale-grid: held notes feed the live engine
      local n=s:gnote(x,y)
      if s.h_row then                                     -- editing a stage: toggle this note in its set
        if z==1 then local st=s.h_row; local set=s.a_set[st]; if not set then set={};s.a_set[st]=set end
          local f=false; for i=1,#set do if set[i]==n then table.remove(set,i);f=true;break end end
          if not f and #set<6 then set[#set+1]=n end
          if #set==0 then s.a_pm[st]=1;s.a_set[st]=nil;s.a_r[st]=nil else s.a_pm[st]=3;s.a_r[st]=set[1] end
        end
        return
      end
      if z==1 then
        local f=false;for i=1,#s.cpool3 do if s.cpool3[i]==n then f=true;break end end
        if not f then s.cpool3[#s.cpool3+1]=n end
        if not s.last_root then                            -- first held note: engage override
          s.last_root={x=x,y=y};s.live_override=true;s.live_pending_off=false
          if s.sel_t==1 and s.sel_s==1 then for _,nn in ipairs(s.cpool3) do midi_note_on(nn,105,s.ch);s.l_n[nn]=true end
          else s.q_lroot={rv=n,t=s.sel_t,s=s.sel_s,m=s.sel_mod,mn=false,co={x=x,y=y}} end
        elseif s.sel_t==1 and s.sel_s==1 and not f then midi_note_on(n,105,s.ch);s.l_n[n]=true end
      else
        for i=1,#s.cpool3 do if s.cpool3[i]==n then table.remove(s.cpool3,i);break end end
        if s.sel_t==1 and s.sel_s==1 then midi_note_off(n,0,s.ch);s.l_n[n]=nil end
        if #s.cpool3==0 then s.last_root=nil;s.q_lroot=nil;s:k_l();s.live_pending_off=true end
      end
      return
    end
    if z==1 then
      if s.center_held then s.lock_r=s.cam[x] and s.cam[x][y];s.lock_mn=(x%2==0);return end
      local rv=s.cam[x] and s.cam[x][y]
      if rv then
        if s.pmode==1 then s.lock_r=rv;s.lock_mn=(x%2==0) end
        if s.h_row then s.a_r[s.h_row]=rv;s.a_min[s.h_row]=(x%2==0);s.a_m[s.h_row]=s.sel_mod;s.a_t[s.h_row]=s.sel_t;s.a_s[s.h_row]=s.sel_s;s.a_d[s.h_row]=s.sel_d end
        s.last_root={x=x,y=y};s.live_override=true;s.live_pending_off=false
        local pm=s.q_mod or s.sel_mod;s.q_mod=nil
        if s.sel_t==1 and s.sel_s==1 then
          for _,n in ipairs(s:c_pool(rv,s.sel_mod,x%2==0)) do midi_note_on(n,105,s.ch);s.l_n[n]=true end
        else s.q_lroot={rv=rv,t=s.sel_t,s=s.sel_s,m=pm,mn=(x%2==0),co={x=x,y=y}} end
      end
    else
      if s.last_root and s.last_root.x==x and s.last_root.y==y then
        s.last_root=nil;s.q_lroot=nil
        s:k_l()
        s.live_pending_off=true
      end
    end
  end
end
}

-- =============================================================================
-- PAGE 4: 3 MONOPHONIC SEQUENCERS (scale-following) — piano-roll style
-- x=step(time), y1..6=pitch(scale degrees, top=high). y7=loop region (hold start+
-- end pads). y8=ratchet (page-2 style: held pad(s); leftmost=anchor, spread=clock
-- division). notes resolve through page 3's current scale; root degrees marked faint.
-- menu overlay: seq select (col16, y1..3) + window scroll ((15,6) up / (15,7) down).
-- transpose/mute come from the performance page (tk[].tpose / tk[].mute / .gtpose).
pages[4]={name="mseq",ch_base=4,nstep=16,sel=1,gtpose=0,fc=0,bl=false,tk={},
  init=function(s)
    for k=1,3 do s.tk[k]={steps={},lstart=1,lend=16,pos=1,win=0,mute=false,tpos=5,tpose=0,vg=1,sp_pos=8,div=6,pc=0,playing=nil,lp_s=nil,lp_e=nil} end
    s.gtpose=0; s.fc=0
  end,
  trk=function(s) return s.tk[s.sel] end,
  chn=function(s,k) return s.ch_base+k-1 end,
  fire=function(s,k)
    local t=s.tk[k]
    if t.playing then midi_note_off(t.playing,0,s:chn(k)); t.playing=nil end
    if t.mute then return end
    local d=t.steps[t.pos]
    if d~=nil then
      local n=pages[3]:scale_deg(d + t.tpose + s.gtpose)
      if n and n>=0 and n<=127 then midi_note_on(n,vgv(t.vg,t.pos,100),s:chn(k)); t.playing=n end
    end
  end,
  killall=function(s) for k=1,3 do local t=s.tk[k]; if t.playing then midi_note_off(t.playing,0,s:chn(k)); t.playing=nil end end end,
  clock_pulse=function(s) for k=1,3 do local t=s.tk[k]; t.pc=t.pc+1; if t.pc>=t.div then t.pc=0; t.pos=t.pos+1; if t.pos>t.lend or t.pos<t.lstart then t.pos=t.lstart end; s:fire(k) end end end,
  reset=function(s) for k=1,3 do local t=s.tk[k]; t.pc=0; t.pos=t.lstart; s:fire(k) end end,
  update=function(s) s.fc=s.fc+1; if s.fc>=16 then s.fc=0 end; s.bl=s.fc<8 end,
  set_speed=function(s,pos)  -- row-1 radio: center pos8=x1; up=x1.5..x4.5, down=÷1.5..÷4.5
    local t=s:trk(); t.sp_pos=pos; local off=pos-8
    local mult=off>=0 and (1+0.5*off) or 1/(1+0.5*(-off))
    t.div=math.max(1,math.floor(6/mult+0.5))
  end,
  clearseq=function(s) local t=s:trk(); t.steps={}; t.lstart=1; t.lend=16; t.pos=1 end,
  -- write/clear a note (shared by normal + menu-mode editing)
  putnote=function(s,x,y) local t=s:trk(); local deg=t.win+(7-y)
    if t.steps[x]==deg then t.steps[x]=nil else t.steps[x]=deg end end,
  menu_draw=function(s)
    local t=s:trk(); local bl=s.bl
    for k=1,3 do grid_led(16,k, k==s.sel and 15 or 4) end             -- seq select
    for x=1,15 do local led=(x==8) and 4 or 2; if x==t.sp_pos then led=bl and 15 or 8 end; grid_led(x,1,led) end  -- row1 speed
    for x=1,16 do local led=(x==1) and 3 or 2; if x==t.vg then led=bl and 15 or 8 end; grid_led(x,7,led) end       -- row7 velocity
    grid_led(15,5, bl and 9 or 4); grid_led(15,6, bl and 9 or 4)      -- scroll up/down (moved up a row)
    grid_led(14,6, bl and 12 or 5)                                    -- clear sequence
  end,
  menu_event=function(s,x,y,z)
    if x==16 and y<=3 then if z==1 then s.sel=y end; return true end
    if y==1 and x<=15 then if z==1 then s:set_speed(x) end; return true end
    if y==7 then if z==1 then s.tk[s.sel].vg=x end; return true end
    if x==15 and y==5 then if z==1 then s:trk().win=s:trk().win+1 end; return true end
    if x==15 and y==6 then if z==1 then s:trk().win=s:trk().win-1 end; return true end
    if x==14 and y==6 then if z==1 then s:clearseq() end; return true end
    if y>=2 and y<=6 then if z==1 then s:putnote(x,y) end; return true end
    return false  -- y8 -> page switch
  end,
  draw=function(s)
    local t=s:trk()
    for x=1,s.nstep do
      local inloop=(x>=t.lstart and x<=t.lend)
      for y=1,7 do  -- pitch: 7 visible scale degrees (top=high)
        local deg=t.win+(7-y); local led=0
        if pages[3]:deg_is_root(deg) then led=2 end       -- faint root bar
        if inloop then led=math.max(led,1) end
        if t.steps[x]==deg then led=8 end                 -- note
        if x==t.pos then led=math.max(led,(t.steps[x]==deg) and 15 or 5) end  -- playhead
        grid_led(x,y,led)
      end
      local l8=2                                          -- y8: loop region (hold start+end)
      if x==t.lstart or x==t.lend then l8=8 elseif x>t.lstart and x<t.lend then l8=4 end
      if x==t.pos then l8=math.max(l8,11) end
      grid_led(x,8,l8)
    end
  end,
  event=function(s,x,y,z)
    local t=s:trk()
    if y==8 then  -- LOOP region: hold start pad + end pad
      if z==1 then
        if t.lp_s==nil then t.lp_s=x
        else t.lp_e=x; local a,b=t.lp_s,t.lp_e; if a>b then a,b=b,a end
          t.lstart=a; t.lend=b; if t.pos<a or t.pos>b then t.pos=a end
        end
      else
        if t.lp_e~=nil then t.lp_s=nil; t.lp_e=nil elseif t.lp_s==x then t.lp_s=nil end
      end
      return
    end
    if z==1 and x>=1 and x<=s.nstep and y>=1 and y<=7 then s:putnote(x,y) end
  end
}
-- =============================================================================
-- SCENE / PRESET SYSTEM  (perform page; bottom-left button toggles the launcher)
-- Storage model: ONE pset index per scene slot (native iii idiom). A scene is a
-- flat, version-tagged integer array (no string keys, no nesting) — bitmasks for
-- booleans, 16-bit ints for step rows. Only persistent musical state is captured;
-- transient cursors/accumulators are rebuilt on recall. One reused pack buffer.
-- =============================================================================
-- SCENE / PRESET SYSTEM  (perform page; bottom-left button toggles the launcher)
-- Storage: ONE small pset per slot (native iii idiom) + ONE tiny manifest pset
-- holding an occupancy bitmask, so boot reads a single ~50-byte file instead of
-- parsing every slot. A scene is a TIGHT bit-packed integer array (v2): small
-- fields share 64-bit words, 16-step rows are single ints. Keeps each slot file
-- tiny so one recall parses cheaply; GC runs after every pset op to release the
-- Lua parser's transient memory. Only persistent musical state is captured.
-- =============================================================================
-- SCENE / PRESET SYSTEM  (perform page; bottom-left button toggles the launcher)
-- Storage: ONE small pset per slot + ONE tiny manifest pset (occupancy flags).
-- CRITICAL: iii writes psets as Lua SOURCE and serializes numbers with limited
-- float precision (~6 significant digits), so any value > ~1e6 is corrupted on
-- read. Therefore EVERY stored value is kept to a single byte (0..255): 16-bit
-- fields are split into lo/hi bytes, signed values are offset, nil uses a 255
-- sentinel. Boot reads only the manifest. GC runs after each pset op.
-- =============================================================================
-- SCENE / PRESET SYSTEM  (perform page; bottom-left button toggles the launcher)
-- Storage: ONE small pset per slot + ONE tiny manifest pset (occupancy flags).
-- All stored values are a single byte (0..255) so the device's low-precision
-- number serialization can't corrupt them. 128 slots across 4 clip pages of 32.
-- A scene captures all persistent musical state, incl. per-stage playmode and
-- (for Plinky/pmode-3 stages) up to 6 custom notes. Boot reads only the manifest.
SC={view=false,sel=nil,cur=nil,pend=nil,loadq=nil,loading=false,clk_run=false,page=0,NSLOT=127,PER=32,MANI=1,mdirty=false,mt=0,occ={},buf={},mbuf={},
  npg=function() return (SC.NSLOT+SC.PER-1)//SC.PER end,
  pack=function()
    local B=SC.buf; for i=#B,1,-1 do B[i]=nil end; local n=0; local sf=string.format
    local function w(v) if v<0 then v=0 elseif v>255 then v=255 end; n=n+1; B[n]=sf("%02x",v&255) end
    local p1,p2,p3,p4=pages[1],pages[2],pages[3],pages[4]
    w(4)                                                          -- [1] format version
    w(p1.fbank); w(p1.mult); w(p1.gpos)
    for i=1,40 do w(math.floor((p1.ft[i] or 0)+0.5)) end
    for y=1,6 do local m=0; for x=1,16 do if p2.steps[y][x] then m=m|(1<<(x-1)) end end; w(m&255); w((m>>8)&255) end
    for y=1,6 do w(p2.lengths[y]) end
    for y=1,6 do w(p2.vg[y]) end
    local mm=0; for y=1,6 do if p2.mute[y] then mm=mm|(1<<(y-1)) end end; w(mm); w(p2.dlen); w(p2.active)
    w(p3.sel_mod);w(p3.sel_size);w(p3.sel_t);w(p3.sel_s);w(p3.sel_d);w(p3.sel_g);w(p3.sel_vg)
    w(p3.koct+1);w(p3.inv+8);w(p3.pmode);w(p3.lock_r);w(p3.lock_mn and 1 or 0);w(p3.arp_tpos);w(p3.amute and 1 or 0);w(p3.run and 1 or 0)
    w(p3.last_root and p3.last_root.x or 0); w(p3.last_root and p3.last_root.y or 0)
    for i=1,8 do                                                  -- 8 tracker stages, 16 bytes each
      w(p3.a_r[i] or 0);w(p3.a_m[i] or 1);w(p3.a_min[i] and 1 or 0);w(p3.a_t[i] or 1)
      w(p3.a_s[i] or 1);w(p3.a_d[i] or 1);w(p3.a_g[i] or 1);w(p3.a_vg[i] or 1);w(p3.durs[i] or 1)
      w(p3.a_pm[i] or 1)                                          -- stage playmode
      local set=p3.a_set[i]; for j=1,6 do w(set and set[j] or 0) end  -- up to 6 custom notes (0=empty)
    end
    for k=1,3 do local t=p4.tk[k]
      for x=1,16 do local d=t.steps[x]; w(d==nil and 255 or (d+100)) end
      w(t.lstart);w(t.lend);w(t.win+100);w(t.mute and 1 or 0);w(t.tpos);w(t.vg);w(t.sp_pos)
    end
    return {table.concat(B)}                                      -- one short hex string, not 285 numbers
  end,
  unpack=function(P)
    local s=P and P[1]; if type(s)~="string" then return false end
    local ci=-1; local function r() ci=ci+2; return tonumber(s:sub(ci,ci+1),16) or 0 end
    if r()~=4 then return false end                               -- version byte (first 2 hex chars)
    local p1,p2,p3,p4=pages[1],pages[2],pages[3],pages[4]
    p1.fbank=r(); p1.mult=r(); p1.gpos=r()
    for i=1,40 do p1.ft[i]=r(); p1.fs[i]=p1.fv[i]; p1.fr[i]=0 end
    for y=1,6 do local lo=r(); local hi=r(); local m=lo|(hi<<8); for x=1,16 do p2.steps[y][x]=(m&(1<<(x-1)))~=0 end end
    for y=1,6 do p2.lengths[y]=r() end
    for y=1,6 do p2.vg[y]=r() end
    local mm=r(); for y=1,6 do p2.mute[y]=(mm&(1<<(y-1)))~=0 end; p2.dlen=r(); p2.active=r(); if p2.active<1 then p2.active=1 end
    for y=1,6 do if p2.positions[y]>p2.lengths[y] then p2.positions[y]=1 end end; p2:recalc_mb()
    p3.sel_mod=r();p3.sel_size=r();p3.sel_t=r();p3.sel_s=r();p3.sel_d=r();p3.sel_g=r();p3.sel_vg=r()
    p3.koct=r()-1; p3.inv=r()-8; p3.pmode=r(); p3.lock_r=r(); p3.lock_mn=(r()==1); p3.arp_tpos=r(); p3.amute=(r()==1); p3.run=(r()==1)
    local lx=r(); local ly=r(); if lx>0 then p3.last_root={x=lx,y=ly} else p3.last_root=nil end
    for i=1,8 do local v=r(); if v==0 then p3.a_r[i]=nil else p3.a_r[i]=v end
      p3.a_m[i]=r(); p3.a_min[i]=(r()==1); p3.a_t[i]=r(); p3.a_s[i]=r(); p3.a_d[i]=r(); p3.a_g[i]=r(); p3.a_vg[i]=r(); p3.durs[i]=r()
      p3.a_pm[i]=r()
      local set=nil; for j=1,6 do local nn=r(); if nn>0 then if not set then set={} end; set[#set+1]=nn end end; p3.a_set[i]=set
    end
    for k=1,3 do local t=p4.tk[k]
      for x=1,16 do local d=r(); if d==255 then t.steps[x]=nil else t.steps[x]=d-100 end end
      t.lstart=r(); t.lend=r(); t.win=r()-100; t.mute=(r()==1); t.tpos=r(); t.vg=r(); t.sp_pos=r()
      local off=t.sp_pos-8; local ml=off>=0 and (1+0.5*off) or 1/(1+0.5*(-off)); t.div=math.max(1,math.floor(6/ml+0.5))
      if t.pos<t.lstart or t.pos>t.lend then t.pos=t.lstart end
    end
    p3.arp_tpose=(p3.arp_tpos-5)*p1.mult
    for k=1,3 do p4.tk[k].tpose=(p4.tk[k].tpos-5)*p1.mult end
    p4.gtpose=(p1.gpos-5)*p1.mult
    return true
  end,
  silence=function()
    pages[3]:k_c(); pages[3]:k_l(); pages[4]:killall()
    local p2=pages[2]; for y=1,6 do if p2.off_n[y] then midi_note_off(p2.off_n[y],0,p2.ch); p2.off_n[y]=nil; p2.off_c[y]=nil end end
  end,
  writemani=function(self) local M=SC.mbuf; M[1]=4; for i=1,SC.NSLOT do M[i+1]=SC.occ[i] and 1 or 0 end; pcall(pset_write,SC.MANI,M) end,
  apply=function(self,slot)
    collectgarbage()                                              -- free heap before the parse (esp. mid-song)
    local ok,B=pcall(pset_read,slot+1); if not ok or not B then return end
    SC.loading=true
    SC.silence(); SC.unpack(B); SC.cur=slot; B=nil
    if SC.clk_run and pages[3].run then pages[3]:f_st() end        -- sound the recalled stage promptly
    SC.loading=false
    if SC.mdirty then SC.mt=8 end; collectgarbage()
  end,
  save=function(self,slot) pset_write(slot+1,SC.pack()); SC.occ[slot]=true; SC.cur=slot; SC.mdirty=true; SC.mt=8; collectgarbage() end,
  del=function(self,slot) pcall(pset_delete,slot+1); SC.occ[slot]=false; if SC.cur==slot then SC.cur=nil end; SC.mdirty=true; SC.mt=8; collectgarbage() end,
  flush=function() if SC.mdirty then SC.mt=SC.mt-1; if SC.mt<=0 then SC.mdirty=false; SC:writemani(); collectgarbage() end end end,
  service=function(self)                                          -- one pset op per tick: a queued load takes priority over the manifest flush
    if SC.loadq then local s=SC.loadq; SC.loadq=nil; SC:apply(s); SC.mt=8; return end
    SC.flush()
  end,
  scan=function(self)
    local ok,m=pcall(pset_read,SC.MANI)
    if ok and type(m)=="table" and m[1]==4 then for i=1,SC.NSLOT do SC.occ[i]=(m[i+1]==1) end
    else for i=1,SC.NSLOT do SC.occ[i]=false end end
    m=nil; collectgarbage()
  end,
  do_load=function(self) local i=SC.sel; if not i or not SC.occ[i] then return end; if SC.clk_run then SC.pend=i else SC:apply(i); SC.pend=nil end end,
  do_save=function(self) local i=SC.sel; if i then SC:save(i) end end,
  do_delete=function(self) local i=SC.sel; if i and SC.occ[i] then SC:del(i); SC.sel=nil end end,
  draw_left=function(self,p1)
    local bl=p1.bl; local base=SC.page*SC.PER
    for li=1,SC.PER do local i=base+li; local x=((li-1)%8)+1; local y=((li-1)//8)+1
      local led=SC.occ[i] and 6 or 2
      if SC.cur==i then led=11 end
      if SC.pend==i then led=bl and 15 or 1 elseif SC.sel==i then led=bl and 15 or 4 end
      grid_led(x,y,led)
    end
    for y=5,7 do for x=1,8 do grid_led(x,y,0) end end
    for p=0,SC.npg()-1 do grid_led(p+1,6, p==SC.page and 12 or 3) end  -- clip-page indicator
  end,
  draw_row8=function(self,p1)
    grid_led(1,8,15); grid_led(2,8,0)
    local a=SC.sel
    grid_led(3,8,(a and SC.occ[a]) and (SC.pend and (p1.bl and 15 or 3) or 12) or 3)  -- LOAD
    grid_led(4,8, a and 12 or 3)                                                       -- SAVE
    grid_led(5,8,(a and SC.occ[a]) and 12 or 3)                                        -- DELETE
    grid_led(6,8,0)
    grid_led(7,8, SC.page>0 and 8 or 2)                                                -- clip page left
    grid_led(8,8, SC.page<SC.npg()-1 and 8 or 2)                                      -- clip page right
  end,
  event=function(self,x,y,z)
    if z~=1 then return true end
    if y==8 then
      if x==1 then SC.view=false; SC.sel=nil
      elseif x==3 then SC:do_load()
      elseif x==4 then SC:do_save()
      elseif x==5 then SC:do_delete()
      elseif x==7 then if SC.page>0 then SC.page=SC.page-1 end
      elseif x==8 then if SC.page<SC.npg()-1 then SC.page=SC.page+1 end end
      return true
    end
    if y>=1 and y<=4 then local i=SC.page*SC.PER+((y-1)*8+x); if i>=1 and i<=SC.NSLOT then SC.sel=(SC.sel==i) and nil or i end end
    return true
  end
}
for i=1,#pages do pages[i]:init() end
pset_init("gridcomp"); SC:scan()
m_main=metro.init(framework_tick,0.03) m_main:start()
