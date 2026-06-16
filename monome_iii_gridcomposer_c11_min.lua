-- Grid Composer by Luna Nane // lunanane.com
current_page=1; menu_active=false; pages={}
function draw()
grid_led_all(0)
if pages[current_page] and pages[current_page].draw then pages[current_page]:draw() end
if menu_active then
for p=1,16 do grid_led(p,8, p==current_page and 15 or (pages[p] and 4 or 0)) end
local pg=pages[current_page]; if pg.ce then pg:ce() end
end
grid_led(16,8,menu_active and 15 or 6); grid_refresh()
end
event_grid=function(x,y,z)
if x==16 and y==8 then
if z==1 then menu_active=not menu_active end return
end
if menu_active then
local pg=pages[current_page]
if pg.cf and pg:cf(x,y,z) then return end
if y==8 and z==1 and pages[x] then current_page=x; menu_active=false end return
end
if pages[current_page] then pages[current_page]:bf(x,y,z) end
end
local aU=0; local dk=0; local bw=0
function event_midi(d1,d2,d3)
if d1==248 then
aU=aU+1; bw=bw+1
if pages[3] then pages[3]:aW() end
if pages[4] then pages[4]:aV() end
if bw>=96 then bw=0; if pages[3] then pages[3]:aD() end end
local s=pages[2]
if s then
if s.ax and bw==0 then
s.cW={}; s.dl=nil; s.ax=false; s.ca=1
for r=1,6 do s.cG[r]=1 end; s:bp(); aU=0; dk=0; return
end
if s.dl then
dk=dk+1; if dk>=s.dm then
dk=0; s.bt=not s.bt; s.ca=s.dl
for r=1,6 do s.cG[r]=((s.dl-1)%s.bX[r])+1 end; s:bp()
end
if aU>=6 then aU=0 end
elseif aU>=6 then aU=0; dk=0; s:aX() end
end
elseif d1==250 or d1==251 then
aU=1; dk=0; bw=0
if pages[2] then pages[2].ca=1; for y=1,6 do pages[2].cG[y]=1 end; pages[2]:bp() end
if pages[3] then pages[3].aC=0; pages[3].bx=1; pages[3].bu=0; pages[3].ai=1; pages[3].aa=0
if pages[3].cX then pages[3].aJ=1; pages[3]:bi() end
end
if pages[4] then pages[4]:cU() end
elseif d1==252 then
if pages[3] then pages[3]:bJ(); pages[3]:bK() end
if pages[4] then pages[4]:bL() end
for n=0,127 do for c=1,7 do midi_note_off(n,0,c) end end
end
end
function framework_tick() for i=1,#pages do if pages[i].du then pages[i]:du() end end; draw() end
function vgv(g,i,aE)
if g<=1 then return aE end
local n=g-1; local p=(i-1)%16; local sh
if n<=4 then local k=(n==1 and 4)or(n==2 and 2)or(n==3 and 8)or 3; sh=(p%k==0) and 1 or 0.15
elseif n<=8 then local m=n-4; local k=(m<=2 and 4)or(m==3 and 2)or 8; local o=(m==1 and 2)or(m==4 and 4)or 1; sh=((p-o)%k==0) and 1 or 0.2
elseif n<=12 then local f=n-8; sh=(math.sin(p/16*f*6.2832)+1)*0.5
else local f=n-12; local a=(p%4==0) and 1 or 0; local b=(math.sin((p+1)/16*f*6.2832)+1)*0.35; sh=(a>b) and a or b end
return math.floor(76+32*sh+0.5)
end
pages[1]={cp="perf",aN=1,aM=20,FT=0.5,FD=0.03,bj=1,cq=5,
fv={},ft={},fs={},fr={},fl={},bg=0,bl=false,cj=1,bC=5,
init=function(s)
for i=1,s.cq*8 do s.fv[i]=0;s.ft[i]=0;s.fs[i]=0;s.fr[i]=s.FT;s.fl[i]=-1 end
for f=1,8 do local i=f; s.fv[i]=102;s.ft[i]=102;s.fs[i]=102;s.fl[i]=102; s:db(s.aM+i-1,102) end
end,
db=function(s,cw,dv) midi_cc(cw,dv,s.aN) end,
bn=function(s,f) return (s.bj-1)*8+f end,
dc=function(s,b) if b>=1 and b<=s.cq then s.bj=b end end,
df=function(s,r,aY)
local cz=(aY-5)*s.cj
if r==1 then local p=pages[3]; if p then p.az=aY; p.aA=cz end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.dp=aY; t.dq=cz end end
end,
au=function(s)
for r=1,4 do
if r==1 then local p=pages[3]; if p then p.aA=(p.az-5)*s.cj end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.dq=(t.dp-5)*s.cj end end
end
if pages[4] then pages[4].bD=(s.bC-5)*s.cj end
end,
du=function(s)
s.bg=(s.bg+1)%16; s.bl=(s.bg<8)
for i=1,s.cq*8 do
if s.fr[i]<s.FT then
s.fr[i]=s.fr[i]+s.FD
local t=s.fr[i]/s.FT; if t>1 then t=1 end
local e=t*(2-t)
local v=s.fs[i]+(s.ft[i]-s.fs[i])*e; s.fv[i]=v
local iv=math.floor(v+0.5)
if iv~=s.fl[i] then s.fl[i]=iv; s:db(s.aM+i-1,iv) end
end
end
end,
ce=function(s) for b=1,5 do grid_led(16,b, b==s.bj and 15 or 4) end end,
cf=function(s,x,y,z) if z==1 and x==16 and y<=7 then s:dc(y);menu_active=false;return true end return false end,
draw=function(s)
local ck=pages[2] and pages[2].cm
for x=1,8 do local bV=1
if x<=6 then local m=ck and ck[x]; bV=m and(s.bl and 15 or 3)or 6 end
grid_led(x,1,bV)
end
for y=2,5 do
local r=y-1; local cF,cn
if r==1 then cF=(pages[3] and pages[3].az) or 5; cn=pages[3] and pages[3].ar
else local t=pages[4] and pages[4].tk[r-1]; cF=(t and t.dp) or 5; cn=t and t.cm end
for x=1,8 do local bV
if x==1 then bV=cn and(s.bl and 15 or 8)or 3
else bV=(x==5) and 4 or 2; if x==cF then bV=15 end end
grid_led(x,y,bV)
end
end
for x=1,8 do grid_led(x,6,(x==s.cj) and 15 or 2) end
for x=1,8 do grid_led(x,7,(x==s.bC) and 15 or((x==5) and 4 or 2)) end
for x=1,8 do grid_led(x,8,1) end
for f=1,8 do
local i=s:bn(f); local x=8+f; local b7=math.floor(s.fv[i]/127*7+0.5)
for y=1,8 do local aP=9-y; grid_led(x,y,((aP-1)<=b7) and 7 or 2) end
end
end,
cc=function(s,x,y,z)
if z~=1 then return end
local r=y-1
if x==1 then
if r==1 then local p=pages[3]; if p then p.ar=not p.ar; if p.ar then p:bJ();p:bK() end end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.cm=not t.cm end end
return
end
if x>=2 and x<=8 then s:df(r,x) end
end,
bf=function(s,x,y,z)
if x>=9 and x<=16 then
if z~=1 then return end
local i=s:bn(x-8); s.fs[i]=s.fv[i]; s.ft[i]=math.floor((8-y)/7*127+0.5); s.fr[i]=0; return
end
if y>=2 and y<=5 then s:cc(x,y,z); return end
if z~=1 then return end
if y==1 then if x<=6 and pages[2] then pages[2].cm[x]=not pages[2].cm[x] end return end
if y==6 then s.cj=x; s:au(); return end
if y==7 then s.bC=x; if pages[4] then pages[4].bD=(x-5)*s.cj end return end
end
}
pages[2]={cp="seq",dj={},cG={},bX={},vg={},ca=1,b9=16,cW={},dl=nil,dm=6,bt=false,ax=false,ct={60,61,62,63,64,65},ch=2,bq={},cV=false,cm={},ao=1,cB={},cA={},a8=1,
init=function(s) for y=1,6 do s.dj[y]={}; for x=1,16 do s.dj[y][x]=false end; s.cG[y]=1; s.bX[y]=16; s.bq[y]=nil; s.vg[y]=1 end; s.ao=1; s.ca=1; s.b9=16; s.cW={}; s.dl=nil; s.dm=6; s.bt=false; s.ax=false end,
cR=function(s) local m=1; for y=1,6 do if s.bX[y]>m then m=s.bX[y] end end; s.b9=m; if s.ca>s.b9 then s.ca=1 end end,
cS=function(s) local cg=99; local cb=0; local c=0; for x=1,15 do if s.cW[x] then c=c+1; if x<cg then cg=x end; if x>cb then cb=x end end end
if c==0 then s.dl=nil; s.ax=false else s.dl=cg; local sp=cb-cg; s.dm=(sp==0 and 6 or (sp==1 and 12 or (sp==2 and 8 or (sp==3 and 6 or (sp==4 and 4 or 3))))) end end,
bp=function(s) for y=1,6 do if s.dj[y][s.cG[y]] and not s.cm[y] then local nt=s.ct[y];midi_note_on(nt,vgv(s.vg[y],s.cG[y],100),s.ch);s.cB[y]=nt;s.cA[y]=s.a8 end end end,
aX=function(s) s.ca=s.ca+1; if s.ca>s.b9 then s.ca=1 end; for y=1,6 do s.cG[y]=s.cG[y]+1; if s.cG[y]>s.bX[y] then s.cG[y]=1 end end; s:bp() end,
du=function(s) for y=1,6 do local c=s.cA[y]; if c then if c<=1 then midi_note_off(s.cB[y],0,s.ch);s.cA[y]=nil;s.cB[y]=nil else s.cA[y]=c-1 end end end end,
cf=function(s,x,y,z)
if z==1 and y>=1 and y<=6 then s.bX[y]=16; for i=1,16 do s.dj[y][i]=false end; s.cG[y]=1; s:cR(); return true end
return false
end,
draw=function(s)
for y=1,6 do local l=s.bX[y]; local p=s.cG[y]; local an=(y==s.ao)
for x=1,16 do local bV=0
if x<=l then bV=s.dj[y][x] and 8 or (an and 3 or 2); if x==1 or x==l then bV=math.max(bV,an and 6 or 4) end; if x==p then bV=13 end end
grid_led(x,y,bV)
end
end
for x=1,16 do local bV
if x==1 and s.dl~=nil then bV=s.ax and 15 or 4
else bV=(x==s.vg[s.ao]) and 15 or (x==1 and 3 or 2) end
grid_led(x,7,bV)
end
for x=1,15 do local bV=0; if x<=s.b9 then if s.cW[x] then bV=s.bt and 15 or 6 elseif x==s.ca and s.dl==nil then bV=11 else bV=4 end end; grid_led(x,8,bV) end; grid_led(16,8,4)
end,
bf=function(s,x,y,z)
if y==8 then if x==16 then return end; if z==1 and x<=s.b9 then s.cW[x]=true; s:cS(); if s.dl==x then s.ca=x; for r=1,6 do s.cG[r]=((x-1)%s.bX[r])+1 end; s.bt=true; s:bp() end else s.cW[x]=nil; s:cS() end return end
if y==7 then
if z~=1 then return end
if x==1 and s.dl~=nil then s.ax=true; return end
s.vg[s.ao]=x; return
end
if z==1 then if s.bq[y]==nil then s.bq[y]=x; s.cV=false else local st=s.bq[y]; if st==1 and x>1 then s.bX[y]=x; s.ao=y; s.cV=true; if s.cG[y]>s.bX[y] then s.cG[y]=1 end; s:cR() end end
else if s.bq[y]==x then if not s.cV then s.dj[y][x]=not s.dj[y][x] end; s.bq[y]=nil; s.cV=false end end
end
}
pages[3]={cp="arp",ch=3,aL={{64,69,62,67,60,65},{61,66,71,64,69,62},{71,66,63,68,63,70},{68,63,70,65,60,67}},
cY={0,2,4,5,7,9,11},cZ={0,2,3,5,7,8,10},
aO={{0},{0,1,4},{0,2,4},{0,3,4},{0,4},{0,2,4,5},{0,2,4,6},{0,2,4,6,8}},
aK={{0,4,7,10},{0,4,7,11},{0,3,6},{0,4,8},{0,4,6,10},{0,4,8,10},{0,1,4,7}},
bA={65535,21845,52428,18761,61166,28013,6745,4369,22875,26214,48059,27437,19609,27997,61713,63761},
c5=1,c7=5,ci=false,bS=nil,ar=false,aA=0,az=5,
ah={},bR={},bb={},aj={},ae={},ac={},al={},ak={},ab={},am={},af={},
aZ={},a0={},a6={},ob={},sm={5,4,3,2},
c8=1,c6=1,c3=1,c4=1,aG=false,bg=0,cX=true,
cQ=nil,cO=nil,cK=nil,cP=nil,cL=nil,cM=nil,cN=nil,
bx=1,bu=0,ai=1,aa=0,bP=nil,b0=nil,bO=0,bQ=1,bN=1,
b8={[1]=12,[2]=8,[3]=6,[4]=4},
aJ=1,aC=0,bE=nil,bs=nil,br=0,c9=1,cI=8,pn=8,bM=0,bI=0,
cE=1,b2=60,b1=false,aQ=false,by=nil,
bY=false,bZ=false,
ay={1,3,2,4,3,5,4,6},
init=function(s)
for y=1,8 do s.bb[y]=1;s.ae[y]=1;s.al[y]=1;s.ak[y]=1;s.ab[y]=1;s.ac[y]=1;s.am[y]=1;s.af[y]=false end
end,
bz=function(s,g,i) local m=s.bA[g] or s.bA[1]; return (m>>(i-1))&1==1 end,
c1=function(s)
local r,mn
if s.cE>=2 then r=s.b2; mn=s.b1
elseif s.bS then r=s:rv(s.bS); mn=(s.bS.x%2==0)
elseif s.aj[s.aJ] then r=s.aj[s.aJ]; mn=s.af[s.aJ]
else r=60; mn=false end
r=54+((r-54)%12)
return r,(mn and s.cZ or s.cY)
end,
c0=function(s,d)
local r,iv=s:c1()
return r+12*(d//7)+iv[(d%7)+1]
end,
a3=function(s,d) return d%7==0 end,
cs=function(s,n)
local r,iv=s:c1()
local cT=n-r; local cx=cT//12; local pc=cT%12
local aF,bd=99,0
for di=0,6 do local dd=math.abs(iv[di+1]-pc); if dd<aF then aF=dd;bd=di end end
local dw=math.abs(12-pc); if dw<aF then aF=dw;bd=7 end
return cx*7+bd
end,
a4=function(s,ct,T)
local a5=s.a6; for i=#a5,1,-1 do a5[i]=nil end
for _,n in ipairs(ct) do a5[#a5+1]=s:cs(n) end
table.sort(a5)
for i=2,#a5 do if a5[i]<=a5[i-1] then a5[i]=a5[i-1]+1 end end
local cC=s.ob; for i=#cC,1,-1 do cC[i]=nil end
for _,d in ipairs(a5) do local nn=s:c0(d+T); if nn>=0 and nn<=127 then cC[#cC+1]=nn end end
return cC
end,
rv=function(s,lr)
if not lr then return nil end
return s.aL[lr.x] and s.aL[lr.x][lr.y]
end,
a9=function(s,cr) local iv=s.b1 and s.cZ or s.cY;local cT=cr-s.b2;local cx=cT//12;local cz=cT%12;local b=1;local bd=99;for i=1,7 do local dd=iv[i]-cz;if dd<0 then dd=-dd end;if dd<bd then bd=dd;b=i end end;return cx*7+(b-1) end,
bB=function(s,x,y) local iv=s.b1 and s.cZ or s.cY;local d=(x-1)*6+(6-y);return s.b2+12*(d//7)+iv[(d%7)+1] end,
aI=function(s,r,m,mn)
local p=s.aZ; for i=#p,1,-1 do p[i]=nil end
if not r or s.ar then return p end
local ko=12*s.bM
local lk=s.cE>=2 and s.b2
if m>8 then local rr=r
if lk then local iv=s.b1 and s.cZ or s.cY;local d=s:a9(r);rr=s.b2+12*(d//7)+iv[(d%7)+1] end
for _,i in ipairs(s.aK[m-8]) do p[#p+1]=rr+i+ko end
elseif lk then local iv=s.b1 and s.cZ or s.cY;local d0=s:a9(r)
for _,cd in ipairs(s.aO[m]) do local d=d0+cd;p[#p+1]=s.b2+12*(d//7)+iv[(d%7)+1]+ko end
else local iv=mn and s.cZ or s.cY
for _,d in ipairs(s.aO[m]) do p[#p+1]=r+12*(d//7)+iv[(d%7)+1]+ko end
end
if #p>s.c7 then for i=#p,s.c7+1,-1 do p[i]=nil end end
local T=(s.aA or 0)+((pages[4] and pages[4].bD) or 0)
if T~=0 then p=s:a4(p,T) end
local iv=s.bI or 0
if iv~=0 and #p>0 then local n=#p
for _=1,(iv>0 and iv or -iv) do
if iv>0 then local mi=1;for j=2,n do if p[j]<p[mi] then mi=j end end;p[mi]=p[mi]+12
else local ma=1;for j=2,n do if p[j]>p[ma] then ma=j end end;p[ma]=p[ma]-12 end
end
end
return p
end,
bv=function(s,r) if r then for x=1,4 do for y=1,6 do if s.aL[x][y]==r then return x,y end end end end end,
b5=function(s,rv,mn) if s.cE==3 then return s.a0 end;return s:aI(rv,s.c5,mn) end,
aH=function(s,p,d,st,ap)
if #p==0 then return nil end;local l=#p;local pi
if d==1 then pi=p[((st-1)%l)+1] elseif d==2 then pi=p[l-((st-1)%l)]
elseif d==3 then local cy=l*2;local ph=(st-1)%cy;pi=ph<l and p[ph+1] or p[cy-ph]
elseif d==4 then local sq=s.ay;pi=p[((sq[((st-1)%#sq)+1]-1)%l)+1] end
if ap and st%2==0 and pi then pi=pi+12 end;return pi
end,
bJ=function(s) for n in pairs(s.ah) do midi_note_off(n,0,s.ch);s.ah[n]=nil end;if s.bP then midi_note_off(s.bP,0,s.ch);s.bP=nil end end,
bK=function(s) for n in pairs(s.bR) do midi_note_off(n,0,s.ch);s.bR[n]=nil end;if s.b0 then midi_note_off(s.b0,0,s.ch);s.b0=nil end end,
cl=function(s,v) local g=2+(v-76)//8; return g<2 and 2 or(g>6 and 6 or g) end,
bh=function(s,r) s:bJ();local v=vgv(s.am[r] or s.c9,s.bx,95);for _,n in ipairs(s:aI(s.aj[r],s.ae[r],s.af[r])) do midi_note_on(n,v,s.ch);s.ah[n]=true end;s.by=s:cl(v) end,
bi=function(s) s:bJ();if not s.cX then return end;if (s.al[s.aJ] or 1)==1 and (s.ak[s.aJ] or 1)==1 and s.aj[s.aJ] then s:bh(s.aJ) end end,
aw=function(s)
if s.cM then
local ql=s.cM;s.cM=nil;s.cN=nil;s:bK();s.c5=ql.m
local qt=ql.t
if qt==1 and ql.s==1 then s.by=nil;for _,n in ipairs(s.cE==3 and s.a0 or s:aI(ql.rv,ql.m,ql.mn)) do midi_note_on(n,105,s.ch);s.bR[n]=true end
elseif qt==1 and ql.s>1 then s.bO=999;s.bQ=1
elseif qt==2 or qt==3 then s.bO=999;s.bN=1;s.bQ=1 end
elseif s.cN then
local qm=s.cN;s.cN=nil;s.c5=qm;s:bK()
local rv=s:rv(s.bS)
if s.c8==1 and s.c6==1 then
if rv then for _,n in ipairs(s:aI(rv,qm,s.bS and s.bS.x%2==0)) do midi_note_on(n,105,s.ch);s.bR[n]=true end end
elseif s.c8==1 and s.c6>1 then s.bO=999;s.bQ=1
elseif s.c8==2 or s.c8==3 then s.bO=999;s.bN=1;s.bQ=1 end
end
end,
dn=function(s,rv)
local mn=s.bS and(s.bS.x%2==0)or false
if s.c8==1 and s.c6>1 then
s.bO=s.bO+1
if s.bO>=s.b8[s.c6] then
s.bO=0;s:bK()
if s:bz(s.c4,s.bQ) then local v=vgv(s.c9,s.bQ,105);for _,n in ipairs(s:b5(rv,mn)) do midi_note_on(n,v,s.ch);s.bR[n]=true end;s.by=s:cl(v) end
s.bQ=(s.bQ%16)+1
end
elseif s.c8==2 or s.c8==3 then
s.bO=s.bO+1
if s.bO>=s.b8[s.c6] then
s.bO=0
if s:bz(s.c4,s.bQ) then
if s.b0 then midi_note_off(s.b0,0,s.ch);s.b0=nil end
local p=s:aH(s:b5(rv,mn),s.c3,s.bN,s.c8==3)
if p then local v=vgv(s.c9,s.bQ,105);midi_note_on(p,v,s.ch);s.b0=p;s.by=s:cl(v) end
s.bN=s.bN+1
end
s.bQ=(s.bQ%16)+1
end
end
end,
aW=function(s)
if bw%24==0 then s:aw() end
local rv=s:rv(s.bS)
if rv then s:dn(rv) end
if s.cX and not s.bE and not s.bY then
local t=s.al[s.aJ] or 1;local sp=s.ak[s.aJ] or 1;local d=s.ab[s.aJ] or 1
if t==1 and sp>1 then
s.bu=s.bu+1
if s.bu>=s.b8[sp] then s.bu=0;s:bJ();if s:bz(s.ac[s.aJ],s.bx) then s:bh(s.aJ) end;s.bx=(s.bx%16)+1 end
elseif t==2 or t==3 then
s.aa=s.aa+1
if s.aa>=s.b8[sp] then
s.aa=0
if s:bz(s.ac[s.aJ],s.bx) then
if s.bP then midi_note_off(s.bP,0,s.ch);s.bP=nil end
local p=s:aH(s:aI(s.aj[s.aJ],s.ae[s.aJ],s.af[s.aJ]),d,s.ai,t==3)
if p then local v=vgv(s.am[s.aJ] or s.c9,s.bx,98);midi_note_on(p,v,s.ch);s.bP=p;s.by=s:cl(v) end;s.ai=s.ai+1
end
s.bx=(s.bx%16)+1
end
end
end
end,
aD=function(s)
local qc=false
if s.cQ then s.c8=s.cQ;s.cQ=nil;qc=true end
if s.cO then s.c6=s.cO;s.cO=nil;qc=true end
if s.cK then s.c3=s.cK;s.cK=nil;qc=true end
if s.cP then s.c7=s.cP;s.cP=nil;qc=true end
if s.cL then s.c4=s.cL;s.cL=nil;qc=true end
if qc then s.bO=999;s.bQ=1;s.bN=1 end
if s.bZ then
s.bZ=false;s.bY=false
s.bx=1;s.ai=1;s.bu=0;s.aa=0;s:bi()
end
if not s.cX then return end
s.aC=s.aC+1
if s.aC>=(s.bb[s.aJ] or 1) then
s.aC=0;local le=1;for r=1,8 do if s.aj[r] then le=r end end
s.aJ=(s.aJ%le)+1;s.bx=1;s.ai=1;s.bu=0;s.aa=0;s:bi()
end
end,
du=function(s)
s.bg=(s.bg+1)%48;s.aG=(s.bg%16<8)
local ts=s.bg/48; local dt=ts<0.5 and ts*2 or 2-ts*2; s.cI=8+math.floor(dt*7+0.5)
local tn=(s.bg%10)/10; local ds=tn<0.5 and tn*2 or 2-tn*2; local en=ds*ds*(3-2*ds); s.pn=5+math.floor(en*10+0.5)
if s.bs then s.br=s.br+1;if s.br>14 then s.bs=nil;s.br=0 end end
if s.by then if s.by<=1 then s:bJ();s:bK();s.by=nil else s.by=s.by-1 end end
end,
draw=function(s)
local tg=s.bE or s.aJ;local bk,bm=s:bv(s.aj[tg])
local at=s.bE and s.al[s.bE] or (s.cQ or s.c8)
local cH=s.cI
local bT,bU; if s.cE==2 then bT,bU=s:bv(s.b2) end
for y=1,6 do for x=1,4 do
local bV
if s.cE==3 then
bV=(((x-1)*6+(6-y))%7==0) and (s.aG and 15 or 6) or 5
local gn=s:bB(x,y);for i=1,#s.a0 do if s.a0[i]==gn then bV=15;break end end
else
bV=(x==1 or x==3) and 5 or 3
if s.bE then if bk==x and bm==y and at~=4 then bV=s.pn end
elseif s.cX and bk==x and bm==y and at~=4 then bV=s.pn end
if bT==x and bU==y then bV=s.aG and 15 or 4 end
if s.bS and y==s.bS.y and x==s.bS.x then bV=15 end
end
grid_led(x,y,bV)
end end
local sm=s.sm;local aB=s.cP or s.c7
for x=5,8 do
local v=x-4;local as=s.bE and s.ak[s.bE] or(s.cO or s.c6);local ad=s.bE and s.ab[s.bE] or(s.cK or s.c3)
grid_led(x,1,at==v and cH or 0)
grid_led(x,2,as==v and cH or 0)
grid_led(x,3,ad==v and cH or 0)
grid_led(x,4,(sm[x-4]==aB) and cH or 0)
end
local ag=s.bE and s.ac[s.bE] or(s.cL or s.c4)
for y=5,8 do for x=5,8 do local bG=((y-5)*4)+(x-4)
grid_led(x,y, bG==ag and (s:bz(ag,s.bx) and 15 or 7) or 6) end end
local bc=(s.cM and s.cM.m) or s.cN
local dg=s.c5;local da=dg<=8 and dg or dg-7
local be=bc and(bc<=8 and bc or bc-7)
local av=s.ae[tg];local aq=av and(av<=8 and av or av-7)
for y=7,8 do for x=1,4 do
local mi=((y-7)*4)+x;local bV=0
if s.bE then if aq==mi and at~=4 then bV=cH end
elseif s.cX and aq==mi and at~=4 then bV=cH end
if mi==da then bV=15 end
if dg>8 and mi==1 and da~=1 then bV=cH end
if be and mi==be and mi~=da then bV=cH end
grid_led(x,y,bV)
end end
if s.cM and s.cM.co then local co=s.cM.co;grid_led(co.x,co.y,cH) end
for y=1,8 do
local bF=s.aj[y]~=nil; local ba=s.bb[y] or 1
for x=9,12 do local aY=x-8; local bV
if not bF then bV=1 elseif aY<ba then bV=3 elseif aY==ba then bV=10 else bV=2 end
if y==s.aJ and s.cX then if aY==ba then bV=cH elseif aY<ba then bV=5 end end
if s.bs==y and s.br%3<2 then bV=15 end
grid_led(x,y,bV)
end
end
local a1=s.bE and s.am[s.bE] or s.c9
for y=1,4 do for x=13,16 do local bG=((y-1)*4)+(x-12); local bV
if bG==a1 then local cv=vgv(a1,s.bx,100); bV=4+math.floor((cv-76)/32*11+0.5); if bV<4 then bV=4 elseif bV>15 then bV=15 end
else bV=(bG==1) and 3 or 2 end
grid_led(x,y,bV)
end end
for y=5,7 do grid_led(13,y,0) end
grid_led(14,5, s.cE==1 and 15 or 3)
grid_led(14,6, s.cE==2 and 15 or (s.aQ and 9 or 6))
grid_led(14,7, s.cE==3 and 15 or 3)
grid_led(16,5, s.bM==1 and 15 or 3)
grid_led(16,6, s.bM==0 and 12 or 5)
grid_led(16,7, s.bM==-1 and 15 or 3)
grid_led(15,6, 6)
grid_led(15,5, s.bI>0 and math.min(15,6+s.bI*3) or 2)
grid_led(15,7, s.bI<0 and math.min(15,6-s.bI*3) or 2)
grid_led(13,8, s.cX and 6 or (s.aG and 15 or 2))
grid_led(14,8,0)
end,
cf=function(s,x,y,z)
if z==1 and x>=9 and x<=12 and y>=1 and y<=8 then
s.aj[y]=nil;s.bb[y]=1;s.ae[y]=1;s.al[y]=1;s.ak[y]=1;s.ab[y]=1;s.ac[y]=1;return true
end
return false
end,
bf=function(s,x,y,z)
if x>=9 and x<=12 and y<=8 then
if z==1 then
local rv=s:rv(s.bS)
s.aj[y]=rv or s.aj[y]
if s.bS then s.af[y]=(s.bS.x%2==0) end
s.ae[y]=(s.cM and s.cM.m) or s.cN or s.c5
s.al[y]=s.c8;s.ak[y]=s.c6;s.ab[y]=s.c3;s.ac[y]=s.c4;s.am[y]=s.c9;s.bb[y]=x-8
s.bs=y;s.br=0;s.bE=y
else if s.bE==y then s.bE=nil;s:bi() end end;return
end
if x>=13 and x<=16 and y<=4 then if z==1 then local bG=((y-1)*4)+(x-12); if s.bE then s.am[s.bE]=bG else s.c9=bG end end;return end
if x==16 and y>=5 and y<=7 then if z==1 then s.bM=(y==5 and 1) or (y==6 and 0) or -1 end;return end
if x==15 and y>=5 and y<=7 then if z==1 then if y==6 then s.bI=0 elseif y==5 then s.bI=math.min(6,s.bI+1) else s.bI=math.max(-6,s.bI-1) end end;return end
if x==14 and y>=5 and y<=7 then
if z==1 then s:bK();for i=#s.a0,1,-1 do s.a0[i]=nil end;s.bS=nil;s.cM=nil
if y==5 then s.cE=1 elseif y==6 then s.cE=2;s.aQ=true else s.cE=3 end
else if y==6 then s.aQ=false end end
return
end
if x>=5 and x<=8 and y<=4 then
if z==1 then
local v=x-4;local tg=s.bE or s.aJ
if y==4 then v=s.sm[v] end
if s.bE then
if y==1 then s.al[tg]=v;if v==4 then s:bJ() end elseif y==2 then s.ak[tg]=v elseif y==3 then s.ab[tg]=v end
else
if y==1 then s.cQ=v elseif y==2 then s.cO=v elseif y==3 then s.cK=v elseif y==4 then s.cP=v end
end
end;return
end
if x>=5 and x<=8 and y>=5 and y<=8 then
if z==1 then local g=((y-5)*4)+(x-4);if s.bE then s.ac[s.bE]=g else s.cL=g end end;return
end
if x==13 and y==8 then if z==1 then s.cX=not s.cX;if s.cX then s:bi() else s:bJ() end end;return end
if y>=7 and x<=4 then
local m=((y-7)*4)+x
if z==1 then
local mv=(s.ci and m>1) and (8+(m-1)) or m
if m==1 then s.ci=true end
if s.bE then s.ae[s.bE]=mv end
if s.c8==1 and s.c6==1 then
s.c5=mv;s.cN=nil;s:bK()
if s.bS then
local rv=s:rv(s.bS)
for _,n in ipairs(s:aI(rv,mv,s.bS.x%2==0)) do midi_note_on(n,105,s.ch);s.bR[n]=true end
end
elseif s.cM then s.cM.m=mv;s.cN=nil
else s.cN=mv end
else
if m==1 then s.ci=false end
end;return
end
if x<=4 and y<=6 then
if s.cE==3 then
local n=s:bB(x,y)
if z==1 then
local f=false;for i=1,#s.a0 do if s.a0[i]==n then f=true;break end end
if not f then s.a0[#s.a0+1]=n end
if not s.bS then
s.bS={x=x,y=y};s.bY=true;s.bZ=false
if s.c8==1 and s.c6==1 then for _,nn in ipairs(s.a0) do midi_note_on(nn,105,s.ch);s.bR[nn]=true end
else s.cM={rv=n,t=s.c8,s=s.c6,m=s.c5,mn=false,co={x=x,y=y}} end
elseif s.c8==1 and s.c6==1 and not f then midi_note_on(n,105,s.ch);s.bR[n]=true end
else
for i=1,#s.a0 do if s.a0[i]==n then table.remove(s.a0,i);break end end
if s.c8==1 and s.c6==1 then midi_note_off(n,0,s.ch);s.bR[n]=nil end
if #s.a0==0 then s.bS=nil;s.cM=nil;s:bK();s.bZ=true end
end
return
end
if z==1 then
if s.aQ then s.b2=s.aL[x] and s.aL[x][y];s.b1=(x%2==0);return end
local rv=s.aL[x] and s.aL[x][y]
if rv then
if s.cE==1 then s.b2=rv;s.b1=(x%2==0) end
if s.bE then s.aj[s.bE]=rv;s.af[s.bE]=(x%2==0);s.ae[s.bE]=s.c5;s.al[s.bE]=s.c8;s.ak[s.bE]=s.c6;s.ab[s.bE]=s.c3 end
s.bS={x=x,y=y};s.bY=true;s.bZ=false
local pm=s.cN or s.c5;s.cN=nil
if s.c8==1 and s.c6==1 then
for _,n in ipairs(s:aI(rv,s.c5,x%2==0)) do midi_note_on(n,105,s.ch);s.bR[n]=true end
else s.cM={rv=rv,t=s.c8,s=s.c6,m=pm,mn=(x%2==0),co={x=x,y=y}} end
end
else
if s.bS and s.bS.x==x and s.bS.y==y then
s.bS=nil;s.cM=nil
s:bK()
s.bZ=true
end
end
end
end
}
pages[4]={cp="mseq",aR=4,cu=16,c2=1,bD=0,fc=0,bl=false,tk={},
init=function(s)
for k=1,3 do s.tk[k]={dj={},b6=1,bW=16,cF=1,dx=0,cm=false,dp=5,dq=0,vg=1,dh=8,a7=6,pc=0,cD=nil,b4=nil,b3=nil} end
s.bD=0; s.fc=0
end,
dr=function(s) return s.tk[s.c2] end,
aS=function(s,k) return s.aR+k-1 end,
bo=function(s,k)
local t=s.tk[k]
if t.cD then midi_note_off(t.cD,0,s:aS(k)); t.cD=nil end
if t.cm then return end
local d=t.dj[t.cF]
if d~=nil then
local n=pages[3]:c0(d + t.dq + s.bD)
if n and n>=0 and n<=127 then midi_note_on(n,vgv(t.vg,t.cF,100),s:aS(k)); t.cD=n end
end
end,
bL=function(s) for k=1,3 do local t=s.tk[k]; if t.cD then midi_note_off(t.cD,0,s:aS(k)); t.cD=nil end end end,
aV=function(s) for k=1,3 do local t=s.tk[k]; t.pc=t.pc+1; if t.pc>=t.a7 then t.pc=0; t.cF=t.cF+1; if t.cF>t.bW or t.cF<t.b6 then t.cF=t.b6 end; s:bo(k) end end end,
cU=function(s) for k=1,3 do local t=s.tk[k]; t.pc=0; t.cF=t.b6; s:bo(k) end end,
du=function(s) s.fc=s.fc+1; if s.fc>=16 then s.fc=0 end; s.bl=s.fc<8 end,
de=function(s,cF)
local t=s:dr(); t.dh=cF; local cz=cF-8
local cj=cz>=0 and (1+0.5*cz) or 1/(1+0.5*(-cz))
t.a7=math.max(1,math.floor(6/cj+0.5))
end,
aT=function(s) local t=s:dr(); t.dj={}; t.b6=1; t.bW=16; t.cF=1 end,
cJ=function(s,x,y) local t=s:dr(); local a2=t.dx+(7-y)
if t.dj[x]==a2 then t.dj[x]=nil else t.dj[x]=a2 end end,
ce=function(s)
local t=s:dr(); local bl=s.bl
for k=1,3 do grid_led(16,k, k==s.c2 and 15 or 4) end
for x=1,15 do local bV=(x==8) and 4 or 2; if x==t.dh then bV=bl and 15 or 8 end; grid_led(x,1,bV) end
for x=1,16 do local bV=(x==1) and 3 or 2; if x==t.vg then bV=bl and 15 or 8 end; grid_led(x,7,bV) end
grid_led(15,5, bl and 9 or 4); grid_led(15,6, bl and 9 or 4)
grid_led(14,6, bl and 12 or 5)
end,
cf=function(s,x,y,z)
if x==16 and y<=3 then if z==1 then s.c2=y end; return true end
if y==1 and x<=15 then if z==1 then s:de(x) end; return true end
if y==7 then if z==1 then s.tk[s.c2].vg=x end; return true end
if x==15 and y==5 then if z==1 then s:dr().dx=s:dr().dx+1 end; return true end
if x==15 and y==6 then if z==1 then s:dr().dx=s:dr().dx-1 end; return true end
if x==14 and y==6 then if z==1 then s:aT() end; return true end
if y>=2 and y<=6 then if z==1 then s:cJ(x,y) end; return true end
return false
end,
draw=function(s)
local t=s:dr()
for x=1,s.cu do
local bH=(x>=t.b6 and x<=t.bW)
for y=1,7 do
local a2=t.dx+(7-y); local bV=0
if pages[3]:a3(a2) then bV=2 end
if bH then bV=math.max(bV,1) end
if t.dj[x]==a2 then bV=8 end
if x==t.cF then bV=math.max(bV,(t.dj[x]==a2) and 15 or 5) end
grid_led(x,y,bV)
end
local l8=2
if x==t.b6 or x==t.bW then l8=8 elseif x>t.b6 and x<t.bW then l8=4 end
if x==t.cF then l8=math.max(l8,11) end
grid_led(x,8,l8)
end
end,
bf=function(s,x,y,z)
local t=s:dr()
if y==8 then
if z==1 then
if t.b4==nil then t.b4=x
else t.b3=x; local a,b=t.b4,t.b3; if a>b then a,b=b,a end
t.b6=a; t.bW=b; if t.cF<a or t.cF>b then t.cF=a end
end
else
if t.b3~=nil then t.b4=nil; t.b3=nil elseif t.b4==x then t.b4=nil end
end
return
end
if z==1 and x>=1 and x<=s.cu and y>=1 and y<=7 then s:cJ(x,y) end
end
}
for i=1,#pages do pages[i]:init() end
m_main=metro.init(framework_tick,0.03) m_main:start()
