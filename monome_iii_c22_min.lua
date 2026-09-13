local A=grid_led local aj=ipairs local an=midi_note_off local ao=midi_note_on local aK=math.floor local aL=pcall local bf=collectgarbage local bs=math.max local dJ=pairs
current_page=1; menu_active=false; pages={}
function draw()
grid_led_all(0)
if pages[current_page] and pages[current_page].draw then pages[current_page]:draw() end
if menu_active then
for p=1,16 do A(p,8, p==current_page and 15 or (pages[p] and 4 or 0)) end
local pg=pages[current_page]; if pg.cm then pg:cm() end
end
A(16,8,menu_active and 15 or 6); grid_refresh()
end
event_grid=function(x,y,z)
if x==16 and y==8 then
if z==1 then menu_active=not menu_active end return
end
if menu_active then
local pg=pages[current_page]
if pg.bH and pg:bH(x,y,z) then return end
if y==8 and z==1 and pages[x] then current_page=x; menu_active=false end return
end
if pages[current_page] then pages[current_page]:bh(x,y,z) end
end
local aO=0; local a9=0; local a0=0
function event_midi(d1,d2,d3)
if d1==248 then
if SC.cj then return end
aO=aO+1; a0=a0+1; SC.bX=true
if pages[3] then pages[3]:dm() end
if pages[4] then pages[4]:dl() end
if a0>=96 then a0=0; if pages[3] then pages[3]:dc() end
if SC.a5 then SC.b2=SC.a5; SC.a5=nil end end
local s=pages[2]
if s then
if s.bb and a0==0 then
s.bu={}; s.aw=nil; s.bb=false; s.ae=1
for r=1,6 do s.N[r]=1 end; s:bD(); aO=0; a9=0; return
end
if s.aw then
a9=a9+1; if a9>=s.cz then
a9=0; s.bE=not s.bE; s.ae=s.aw
for r=1,6 do s.N[r]=((s.aw-1)%s.Y[r])+1 end; s:bD()
end
if aO>=6 then aO=0 end
elseif aO>=6 then aO=0; a9=0; s:dn() end
end
elseif d1==250 or d1==251 then
aO=1; a9=0; a0=0
if pages[2] then pages[2].ae=1; for y=1,6 do pages[2].N[y]=1 end; pages[2]:bD() end
if pages[3] then pages[3].bA=0; pages[3].V=1; pages[3].aZ=0; pages[3].ba=1; pages[3].aS=0
if pages[3].S then pages[3].G=1; pages[3]:bi() end
end
if pages[4] then pages[4]:dK() end
elseif d1==252 then
SC.bX=false
if pages[3] then pages[3]:aI(); pages[3]:ak() end
if pages[4] then pages[4]:cU() end
for n=0,127 do for c=1,7 do an(n,0,c) end end
end
end
function framework_tick() for i=1,#pages do if pages[i].bR then pages[i]:bR() end end; SC:dN(); draw() end
function vgv(g,i,cc)
if g<=1 then return cc end
local n=g-1; local p=(i-1)%16; local sh
if n<=4 then local k=(n==1 and 4)or(n==2 and 2)or(n==3 and 8)or 3; sh=(p%k==0) and 1 or 0.15
elseif n<=8 then local m=n-4; local k=(m<=2 and 4)or(m==3 and 2)or 8; local o=(m==1 and 2)or(m==4 and 4)or 1; sh=((p-o)%k==0) and 1 or 0.2
elseif n<=12 then local f=n-8; sh=(math.sin(p/16*f*6.2832)+1)*0.5
else local f=n-12; local a=(p%4==0) and 1 or 0; local b=(math.sin((p+1)/16*f*6.2832)+1)*0.35; sh=(a>b) and a or b end
return aK(76+32*sh+0.5)
end
pages[1]={cq="perf",dg=1,cH=20,FT=0.5,FD=0.03,bC=1,b6=5,
fv={},ft={},fs={},fr={},fl={},aH=0,bl=false,R=1,bm=5,
init=function(s)
for i=1,s.b6*8 do s.fv[i]=0;s.ft[i]=0;s.fs[i]=0;s.fr[i]=s.FT;s.fl[i]=-1 end
for f=1,8 do local i=f; s.fv[i]=102;s.ft[i]=102;s.fs[i]=102;s.fl[i]=102; s:c5(s.cH+i-1,102) end
end,
c5=function(s,dH,dU) midi_cc(dH,dU,s.dg) end,
cP=function(s,f) return (s.bC-1)*8+f end,
dO=function(s,b) if b>=1 and b<=s.b6 then s.bC=b end end,
dQ=function(s,r,aP)
local af=(aP-5)*s.R
if r==1 then local p=pages[3]; if p then p.bc=aP; p.bT=af end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.by=aP; t.b9=af end end
end,
c8=function(s)
for r=1,4 do
if r==1 then local p=pages[3]; if p then p.bT=(p.bc-5)*s.R end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.b9=(t.by-5)*s.R end end
end
if pages[4] then pages[4].bn=(s.bm-5)*s.R end
end,
bR=function(s)
s.aH=(s.aH+1)%16; s.bl=(s.aH<8)
for i=1,s.b6*8 do
if s.fr[i]<s.FT then
s.fr[i]=s.fr[i]+s.FD
local t=s.fr[i]/s.FT; if t>1 then t=1 end
local e=t*(2-t)
local v=s.fs[i]+(s.ft[i]-s.fs[i])*e; s.fv[i]=v
local iv=aK(v+0.5)
if iv~=s.fl[i] then s.fl[i]=iv; s:c5(s.cH+i-1,iv) end
end
end
end,
cm=function(s) for b=1,5 do A(16,b, b==s.bC and 15 or 4) end end,
bH=function(s,x,y,z) if z==1 and x==16 and y<=7 then s:dO(y);menu_active=false;return true end return false end,
draw=function(s)
if SC.ca then SC:dy(s); SC:dz(s) else
local cY=pages[2] and pages[2].Z
for x=1,8 do local u=1
if x<=6 then local m=cY and cY[x]; u=m and(s.bl and 15 or 3)or 6 end
A(x,1,u)
end
for y=2,5 do
local r=y-1; local F,cp
if r==1 then F=(pages[3] and pages[3].bc) or 5; cp=pages[3] and pages[3].aV
else local t=pages[4] and pages[4].tk[r-1]; F=(t and t.by) or 5; cp=t and t.Z end
for x=1,8 do local u
if x==1 then u=cp and(s.bl and 15 or 8)or 3
else u=(x==5) and 4 or 2; if x==F then u=15 end end
A(x,y,u)
end
end
for x=1,8 do A(x,6,(x==s.R) and 15 or 2) end
for x=1,8 do A(x,7,(x==s.bm) and 15 or((x==5) and 4 or 2)) end
for x=1,8 do A(x,8, x==1 and 8 or 1) end
end
for f=1,8 do
local i=s:cP(f); local x=8+f; local dC=aK(s.fv[i]/127*7+0.5)
for y=1,8 do local dh=9-y; A(x,y,((dh-1)<=dC) and 7 or 2) end
end
end,
dE=function(s,x,y,z)
if z~=1 then return end
local r=y-1
if x==1 then
if r==1 then local p=pages[3]; if p then p.aV=not p.aV; if p.aV then p:aI();p:ak() end end
else local t=pages[4] and pages[4].tk[r-1]; if t then t.Z=not t.Z end end
return
end
if x>=2 and x<=8 then s:dQ(r,x) end
end,
bh=function(s,x,y,z)
if x>=9 and x<=16 then
if z~=1 then return end
local i=s:cP(x-8); s.fs[i]=s.fv[i]; s.ft[i]=aK((8-y)/7*127+0.5); s.fr[i]=0; return
end
if SC.ca then SC:bh(x,y,z); return end
if y>=2 and y<=5 then s:dE(x,y,z); return end
if z~=1 then return end
if y==8 then if x==1 then SC.ca=true end return end
if y==1 then if x<=6 and pages[2] then pages[2].Z[x]=not pages[2].Z[x] end return end
if y==6 then s.R=x; s:c8(); return end
if y==7 then s.bm=x; if pages[4] then pages[4].bn=(x-5)*s.R end return end
end
}
pages[2]={cq="seq",I={},N={},Y={},vg={},ae=1,br=16,bu={},aw=nil,cz=6,bE=false,bb=false,cr={60,61,62,63,64,65},ch=2,bj={},b7=false,Z={},aU=1,bt={},bI={},cg=1,
init=function(s) for y=1,6 do s.I[y]={}; for x=1,16 do s.I[y][x]=false end; s.N[y]=1; s.Y[y]=16; s.bj[y]=nil; s.vg[y]=1 end; s.aU=1; s.ae=1; s.br=16; s.bu={}; s.aw=nil; s.cz=6; s.bE=false; s.bb=false end,
cu=function(s) local m=1; for y=1,6 do if s.Y[y]>m then m=s.Y[y] end end; s.br=m; if s.ae>s.br then s.ae=1 end end,
c2=function(s) local b5=99; local ck=0; local c=0; for x=1,15 do if s.bu[x] then c=c+1; if x<b5 then b5=x end; if x>ck then ck=x end end end
if c==0 then s.aw=nil; s.bb=false else s.aw=b5; local sp=ck-b5; s.cz=(sp==0 and 6 or (sp==1 and 12 or (sp==2 and 8 or (sp==3 and 6 or (sp==4 and 4 or 3))))) end end,
bD=function(s) for y=1,6 do if s.I[y][s.N[y]] and not s.Z[y] then local nt=s.cr[y];ao(nt,vgv(s.vg[y],s.N[y],100),s.ch);s.bt[y]=nt;s.bI[y]=s.cg end end end,
dn=function(s) s.ae=s.ae+1; if s.ae>s.br then s.ae=1 end; for y=1,6 do s.N[y]=s.N[y]+1; if s.N[y]>s.Y[y] then s.N[y]=1 end end; s:bD() end,
bR=function(s) for y=1,6 do local c=s.bI[y]; if c then if c<=1 then an(s.bt[y],0,s.ch);s.bI[y]=nil;s.bt[y]=nil else s.bI[y]=c-1 end end end end,
bH=function(s,x,y,z)
if z==1 and y>=1 and y<=6 then s.Y[y]=16; for i=1,16 do s.I[y][i]=false end; s.N[y]=1; s:cu(); return true end
return false
end,
draw=function(s)
for y=1,6 do local l=s.Y[y]; local p=s.N[y]; local cC=(y==s.aU)
for x=1,16 do local u=0
if x<=l then u=s.I[y][x] and 8 or (cC and 3 or 2); if x==1 or x==l then u=bs(u,cC and 6 or 4) end; if x==p then u=13 end end
A(x,y,u)
end
end
for x=1,16 do local u
if x==1 and s.aw~=nil then u=s.bb and 15 or 4
else u=(x==s.vg[s.aU]) and 15 or (x==1 and 3 or 2) end
A(x,7,u)
end
for x=1,15 do local u=0; if x<=s.br then if s.bu[x] then u=s.bE and 15 or 6 elseif x==s.ae and s.aw==nil then u=11 else u=4 end end; A(x,8,u) end; A(16,8,4)
end,
bh=function(s,x,y,z)
if y==8 then if x==16 then return end; if z==1 and x<=s.br then s.bu[x]=true; s:c2(); if s.aw==x then s.ae=x; for r=1,6 do s.N[r]=((x-1)%s.Y[r])+1 end; s.bE=true; s:bD() end else s.bu[x]=nil; s:c2() end return end
if y==7 then
if z~=1 then return end
if x==1 and s.aw~=nil then s.bb=true; return end
s.vg[s.aU]=x; return
end
if z==1 then if s.bj[y]==nil then s.bj[y]=x; s.b7=false else local st=s.bj[y]; if st==1 and x>1 then s.Y[y]=x; s.aU=y; s.b7=true; if s.N[y]>s.Y[y] then s.N[y]=1 end; s:cu() end end
else if s.bj[y]==x then if not s.b7 then s.I[y][x]=not s.I[y][x] end; s.bj[y]=nil; s.b7=false end end
end
}
pages[3]={cq="arp",ch=3,aX={{64,69,62,67,60,65},{61,66,71,64,69,62},{71,66,63,68,63,70},{68,63,70,65,60,67}},
bv={0,2,4,5,7,9,11},bw={0,2,3,5,7,8,10},
cI={{0},{0,1,4},{0,2,4},{0,3,4},{0,4},{0,2,4,5},{0,2,4,6},{0,2,4,6,8}},
df={{0,4,7,10},{0,4,7,11},{0,3,6},{0,4,8},{0,4,6,10},{0,4,8,10},{0,1,4,7}},
cS={65535,21845,52428,18761,61166,28013,6745,4369,22875,26214,48059,27437,19609,27997,61713,63761},
ah=1,bx=5,cn=false,D=nil,aV=false,bT=0,bc=5,
cb={},aA={},aY={},K={},aF={},aE={},ay={},ax={},aD={},aN={},aT={},aG={},ab={},
dp={},L={},dt={},ob={},sm={5,4,3,2},
H=1,J=1,a7=1,a8=1,bV=false,aH=0,S=true,
bO=nil,bM=nil,bK=nil,bN=nil,bL=nil,O=nil,ar=nil,
V=1,aZ=0,ba=1,aS=0,a3=nil,a4=nil,W=0,X=1,bo=1,
b4={[1]=12,[2]=8,[3]=6,[4]=4},
G=1,bA=0,C=nil,b0=nil,bk=0,aM=1,c0=8,pn=8,a2=0,ac=0,
M=1,am=60,aJ=false,bW=false,az=nil,
b1=false,bp=false,
da={1,3,2,4,3,5,4,6},
init=function(s)
for y=1,8 do s.aY[y]=1;s.aF[y]=1;s.ay[y]=1;s.ax[y]=1;s.aD[y]=1;s.aE[y]=1;s.aN[y]=1;s.aT[y]=false;s.aG[y]=1;s.ab[y]=nil end
end,
bF=function(s,g,i) local m=s.cS[g] or s.cS[1]; return (m>>(i-1))&1==1 end,
c4=function(s)
local r,mn
if s.M>=2 then r=s.am; mn=s.aJ
elseif s.D then r=s:rv(s.D); mn=(s.D.x%2==0)
elseif s.K[s.G] then r=s.K[s.G]; mn=s.aT[s.G] end
if type(r)~="number" then r=60; mn=false end
r=54+((r-54)%12)
return r,(mn and s.bw or s.bv)
end,
c3=function(s,d)
local r,iv=s:c4()
return r+12*(d//7)+iv[(d%7)+1]
end,
dq=function(s,d) return d%7==0 end,
dG=function(s,n)
local r,iv=s:c4()
local bP=n-r; local ct=bP//12; local pc=bP%12
local bU,bd=99,0
for di=0,6 do local dd=math.abs(iv[di+1]-pc); if dd<bU then bU=dd;bd=di end end
local dw=math.abs(12-pc); if dw<bU then bU=dw;bd=7 end
return ct*7+bd
end,
dr=function(s,cr,T)
local ai=s.dt; for i=#ai,1,-1 do ai[i]=nil end
for _,n in aj(cr) do ai[#ai+1]=s:dG(n) end
table.sort(ai)
for i=2,#ai do if ai[i]<=ai[i-1] then ai[i]=ai[i-1]+1 end end
local bJ=s.ob; for i=#bJ,1,-1 do bJ[i]=nil end
for _,d in aj(ai) do local nn=s:c3(d+T); if nn>=0 and nn<=127 then bJ[#bJ+1]=nn end end
return bJ
end,
rv=function(s,lr)
if not lr then return nil end
return s.aX[lr.x] and s.aX[lr.x][lr.y]
end,
cK=function(s,dF) local iv=s.aJ and s.bw or s.bv;local bP=dF-s.am;local ct=bP//12;local af=bP%12;local b=1;local bd=99;for i=1,7 do local dd=iv[i]-af;if dd<0 then dd=-dd end;if dd<bd then bd=dd;b=i end end;return ct*7+(b-1) end,
cT=function(s,x,y) local iv=s.aJ and s.bw or s.bv;local d=(x-1)*6+(6-y);return s.am+12*(d//7)+iv[(d%7)+1] end,
be=function(s,r,m,mn)
local p=s.dp; for i=#p,1,-1 do p[i]=nil end
if not r or s.aV then return p end
local ko=12*s.a2
local lk=s.M>=2 and s.am
if m>8 then local rr=r
if lk then local iv=s.aJ and s.bw or s.bv;local d=s:cK(r);rr=s.am+12*(d//7)+iv[(d%7)+1] end
for _,i in aj(s.df[m-8]) do p[#p+1]=rr+i+ko end
elseif lk then local iv=s.aJ and s.bw or s.bv;local d0=s:cK(r)
for _,cd in aj(s.cI[m]) do local d=d0+cd;p[#p+1]=s.am+12*(d//7)+iv[(d%7)+1]+ko end
else local iv=mn and s.bw or s.bv
for _,d in aj(s.cI[m]) do p[#p+1]=r+12*(d//7)+iv[(d%7)+1]+ko end
end
if #p>s.bx then for i=#p,s.bx+1,-1 do p[i]=nil end end
local T=(s.bT or 0)+((pages[4] and pages[4].bn) or 0)
if T~=0 then p=s:dr(p,T) end
local iv=s.ac or 0
if iv~=0 and #p>0 then local n=#p
for _=1,(iv>0 and iv or -iv) do
if iv>0 then local mi=1;for j=2,n do if p[j]<p[mi] then mi=j end end;p[mi]=p[mi]+12
else local ma=1;for j=2,n do if p[j]>p[ma] then ma=j end end;p[ma]=p[ma]-12 end
end
end
return p
end,
cR=function(s,r) if r then for x=1,4 do for y=1,6 do if s.aX[x][y]==r then return x,y end end end end end,
cX=function(s,rv,mn) if s.M==3 then return s.L end;return s:be(rv,s.ah,mn) end,
c6=function(s,r) if s.aG[r]==3 and s.ab[r] then return s.ab[r] end;return s:be(s.K[r],s.aF[r],s.aT[r]) end,
cG=function(s,p,d,st,c7)
if #p==0 then return nil end;local l=#p;local pi
if d==1 then pi=p[((st-1)%l)+1] elseif d==2 then pi=p[l-((st-1)%l)]
elseif d==3 then local cy=l*2;local ph=(st-1)%cy;pi=ph<l and p[ph+1] or p[cy-ph]
elseif d==4 then local sq=s.da;pi=p[((sq[((st-1)%#sq)+1]-1)%l)+1] end
if c7 and st%2==0 and pi then pi=pi+12 end;return pi
end,
aI=function(s) for n in dJ(s.cb) do an(n,0,s.ch);s.cb[n]=nil end;if s.a3 then an(s.a3,0,s.ch);s.a3=nil end end,
ak=function(s) for n in dJ(s.aA) do an(n,0,s.ch);s.aA[n]=nil end;if s.a4 then an(s.a4,0,s.ch);s.a4=nil end end,
cl=function(s,v) local g=2+(v-76)//8; return g<2 and 2 or(g>6 and 6 or g) end,
cM=function(s,r) s:aI();local v=vgv(s.aN[r] or s.aM,s.V,95);for _,n in aj(s:c6(r)) do ao(n,v,s.ch);s.cb[n]=true end;s.az=s:cl(v) end,
bi=function(s) s:aI();if not s.S then return end;if (s.ay[s.G] or 1)==1 and (s.ax[s.G] or 1)==1 and s.K[s.G] then s:cM(s.G) end end,
c9=function(s)
if s.O then
local ql=s.O;s.O=nil;s.ar=nil;s:ak();s.ah=ql.m
local qt=ql.t
if qt==1 and ql.s==1 then s.az=nil;for _,n in aj(s.M==3 and s.L or s:be(ql.rv,ql.m,ql.mn)) do ao(n,105,s.ch);s.aA[n]=true end
elseif qt==1 and ql.s>1 then s.W=999;s.X=1
elseif qt==2 or qt==3 then s.W=999;s.bo=1;s.X=1 end
elseif s.ar then
local qm=s.ar;s.ar=nil;s.ah=qm;s:ak()
local rv=s:rv(s.D)
if s.H==1 and s.J==1 then
if rv then for _,n in aj(s:be(rv,qm,s.D and s.D.x%2==0)) do ao(n,105,s.ch);s.aA[n]=true end end
elseif s.H==1 and s.J>1 then s.W=999;s.X=1
elseif s.H==2 or s.H==3 then s.W=999;s.bo=1;s.X=1 end
end
end,
dS=function(s,rv)
local mn=s.D and(s.D.x%2==0)or false
if s.H==1 and s.J>1 then
s.W=s.W+1
if s.W>=s.b4[s.J] then
s.W=0;s:ak()
if s:bF(s.a8,s.X) then local v=vgv(s.aM,s.X,105);for _,n in aj(s:cX(rv,mn)) do ao(n,v,s.ch);s.aA[n]=true end;s.az=s:cl(v) end
s.X=(s.X%16)+1
end
elseif s.H==2 or s.H==3 then
s.W=s.W+1
if s.W>=s.b4[s.J] then
s.W=0
if s:bF(s.a8,s.X) then
if s.a4 then an(s.a4,0,s.ch);s.a4=nil end
local p=s:cG(s:cX(rv,mn),s.a7,s.bo,s.H==3)
if p then local v=vgv(s.aM,s.X,105);ao(p,v,s.ch);s.a4=p;s.az=s:cl(v) end
s.bo=s.bo+1
end
s.X=(s.X%16)+1
end
end
end,
dm=function(s)
if a0%24==0 then s:c9() end
local rv=s:rv(s.D)
if rv then s:dS(rv) end
if s.S and not s.C and not s.b1 then
local t=s.ay[s.G] or 1;local sp=s.ax[s.G] or 1;local d=s.aD[s.G] or 1
if t==1 and sp>1 then
s.aZ=s.aZ+1
if s.aZ>=s.b4[sp] then s.aZ=0;s:aI();if s:bF(s.aE[s.G],s.V) then s:cM(s.G) end;s.V=(s.V%16)+1 end
elseif t==2 or t==3 then
s.aS=s.aS+1
if s.aS>=s.b4[sp] then
s.aS=0
if s:bF(s.aE[s.G],s.V) then
if s.a3 then an(s.a3,0,s.ch);s.a3=nil end
local p=s:cG(s:c6(s.G),d,s.ba,t==3)
if p then local v=vgv(s.aN[s.G] or s.aM,s.V,98);ao(p,v,s.ch);s.a3=p;s.az=s:cl(v) end;s.ba=s.ba+1
end
s.V=(s.V%16)+1
end
end
end
end,
dc=function(s)
local qc=false
if s.bO then s.H=s.bO;s.bO=nil;qc=true end
if s.bM then s.J=s.bM;s.bM=nil;qc=true end
if s.bK then s.a7=s.bK;s.bK=nil;qc=true end
if s.bN then s.bx=s.bN;s.bN=nil;qc=true end
if s.bL then s.a8=s.bL;s.bL=nil;qc=true end
if qc then s.W=999;s.X=1;s.bo=1 end
if s.bp then
s.bp=false;s.b1=false
s.V=1;s.ba=1;s.aZ=0;s.aS=0;s:bi()
end
if not s.S then return end
s.bA=s.bA+1
if s.bA>=(s.aY[s.G] or 1) then
s.bA=0;local le=1;for r=1,8 do if s.K[r] then le=r end end
s.G=(s.G%le)+1;s.V=1;s.ba=1;s.aZ=0;s.aS=0;s:bi()
end
end,
bR=function(s)
s.aH=(s.aH+1)%48;s.bV=(s.aH%16<8)
local ts=s.aH/48; local dT=ts<0.5 and ts*2 or 2-ts*2; s.c0=8+aK(dT*7+0.5)
local tn=(s.aH%10)/10; local cA=tn<0.5 and tn*2 or 2-tn*2; local en=cA*cA*(3-2*cA); s.pn=5+aK(en*10+0.5)
if s.b0 then s.bk=s.bk+1;if s.bk>14 then s.b0=nil;s.bk=0 end end
if s.az then if s.az<=1 then s:aI();s:ak();s.az=nil else s.az=s.az-1 end end
end,
draw=function(s)
local tg=s.C or s.G;local cN,cO=s:cR(s.K[tg])
local at=s.C and s.ay[s.C] or (s.bO or s.H)
local aB=s.c0
local cV,cW; if s.M==2 then cV,cW=s:cR(s.am) end
for y=1,6 do for x=1,4 do
local u
if s.M==3 then
u=(((x-1)*6+(6-y))%7==0) and (s.bV and 15 or 6) or 5
local gn=s:cT(x,y);for i=1,#s.L do if s.L[i]==gn then u=15;break end end
else
u=(x==1 or x==3) and 5 or 3
if s.C then if cN==x and cO==y and at~=4 then u=s.pn end
elseif s.S and cN==x and cO==y and at~=4 then u=s.pn end
if cV==x and cW==y then u=s.bV and 15 or 4 end
if s.D and y==s.D.y and x==s.D.x then u=15 end
end
A(x,y,u)
end end
local sm=s.sm;local db=s.bN or s.bx
for x=5,8 do
local v=x-4;local as=s.C and s.ax[s.C] or(s.bM or s.J);local ad=s.C and s.aD[s.C] or(s.bK or s.a7)
A(x,1,at==v and aB or 0)
A(x,2,as==v and aB or 0)
A(x,3,ad==v and aB or 0)
A(x,4,(sm[x-4]==db) and aB or 0)
end
local ag=s.C and s.aE[s.C] or(s.bL or s.a8)
for y=5,8 do for x=5,8 do local a1=((y-5)*4)+(x-4)
A(x,y, a1==ag and (s:bF(ag,s.V) and 15 or 7) or 6) end end
local bZ=(s.O and s.O.m) or s.ar
local b8=s.ah;local cx=b8<=8 and b8 or b8-7
local cL=bZ and(bZ<=8 and bZ or bZ-7)
local av=s.aF[tg];local cD=av and(av<=8 and av or av-7)
for y=7,8 do for x=1,4 do
local mi=((y-7)*4)+x;local u=0
if s.C then if cD==mi and at~=4 then u=aB end
elseif s.S and cD==mi and at~=4 then u=aB end
if mi==cx then u=15 end
if b8>8 and mi==1 and cx~=1 then u=aB end
if cL and mi==cL and mi~=cx then u=aB end
A(x,y,u)
end end
if s.O and s.O.co then local co=s.O.co;A(co.x,co.y,aB) end
for y=1,8 do
local dA=s.K[y]~=nil; local bY=s.aY[y] or 1
for x=9,12 do local aP=x-8; local u
if not dA then u=1 elseif aP<bY then u=3 elseif aP==bY then u=10 else u=2 end
if y==s.G and s.S then if aP==bY then u=aB elseif aP<bY then u=5 end end
if s.b0==y and s.bk%3<2 then u=15 end
A(x,y,u)
end
end
local cJ=s.C and s.aN[s.C] or s.aM
for y=1,4 do for x=13,16 do local a1=((y-1)*4)+(x-12); local u
if a1==cJ then local cv=vgv(cJ,s.V,100); u=4+aK((cv-76)/32*11+0.5); if u<4 then u=4 elseif u>15 then u=15 end
else u=(a1==1) and 3 or 2 end
A(x,y,u)
end end
for y=5,7 do A(13,y,0) end
A(14,5, s.M==1 and 15 or 3)
A(14,6, s.M==2 and 15 or (s.bW and 9 or 6))
A(14,7, s.M==3 and 15 or 3)
A(16,5, s.a2==1 and 15 or 3)
A(16,6, s.a2==0 and 12 or 5)
A(16,7, s.a2==-1 and 15 or 3)
A(15,6, 6)
A(15,5, s.ac>0 and math.min(15,6+s.ac*3) or 2)
A(15,7, s.ac<0 and math.min(15,6-s.ac*3) or 2)
A(13,8, s.S and 6 or (s.bV and 15 or 2))
A(14,8,0)
end,
bH=function(s,x,y,z)
if z==1 and x>=9 and x<=12 and y>=1 and y<=8 then
s.K[y]=nil;s.aY[y]=1;s.aF[y]=1;s.ay[y]=1;s.ax[y]=1;s.aD[y]=1;s.aE[y]=1;s.aG[y]=1;s.ab[y]=nil;return true
end
return false
end,
bh=function(s,x,y,z)
if x>=9 and x<=12 and y<=8 then
if z==1 then
if s.M==3 then
local E=s.ab[y]; if not E then E={};s.ab[y]=E end
for i=#E,1,-1 do E[i]=nil end
for i=1,#s.L do if i<=6 then E[i]=s.L[i] end end
s.aG[y]=3; s.K[y]=E[1]
else
local rv=s:rv(s.D)
s.K[y]=rv or s.K[y]; s.aG[y]=1; s.ab[y]=nil
if s.D then s.aT[y]=(s.D.x%2==0) end
s.aF[y]=(s.O and s.O.m) or s.ar or s.ah
end
s.ay[y]=s.H;s.ax[y]=s.J;s.aD[y]=s.a7;s.aE[y]=s.a8;s.aN[y]=s.aM;s.aY[y]=x-8
s.b0=y;s.bk=0;s.C=y
else if s.C==y then s.C=nil;s:bi() end end;return
end
if x>=13 and x<=16 and y<=4 then if z==1 then local a1=((y-1)*4)+(x-12); if s.C then s.aN[s.C]=a1 else s.aM=a1 end end;return end
if x==16 and y>=5 and y<=7 then if z==1 then s.a2=(y==5 and 1) or (y==6 and 0) or -1 end;return end
if x==15 and y>=5 and y<=7 then if z==1 then if y==6 then s.ac=0 elseif y==5 then s.ac=math.min(6,s.ac+1) else s.ac=bs(-6,s.ac-1) end end;return end
if x==14 and y>=5 and y<=7 then
if z==1 then s:ak();for i=#s.L,1,-1 do s.L[i]=nil end;s.D=nil;s.O=nil
if y==5 then s.M=1 elseif y==6 then s.M=2;s.bW=true else s.M=3 end
else if y==6 then s.bW=false end end
return
end
if x>=5 and x<=8 and y<=4 then
if z==1 then
local v=x-4;local tg=s.C or s.G
if y==4 then v=s.sm[v] end
if s.C then
if y==1 then s.ay[tg]=v;if v==4 then s:aI() end elseif y==2 then s.ax[tg]=v elseif y==3 then s.aD[tg]=v end
else
if y==1 then s.bO=v elseif y==2 then s.bM=v elseif y==3 then s.bK=v elseif y==4 then s.bN=v end
end
end;return
end
if x>=5 and x<=8 and y>=5 and y<=8 then
if z==1 then local g=((y-5)*4)+(x-4);if s.C then s.aE[s.C]=g else s.bL=g end end;return
end
if x==13 and y==8 then if z==1 then s.S=not s.S;if s.S then s:bi() else s:aI() end end;return end
if y>=7 and x<=4 then
local m=((y-7)*4)+x
if z==1 then
local mv=(s.cn and m>1) and (8+(m-1)) or m
if m==1 then s.cn=true end
if s.C then s.aF[s.C]=mv end
if s.H==1 and s.J==1 then
s.ah=mv;s.ar=nil;s:ak()
if s.D then
local rv=s:rv(s.D)
for _,n in aj(s:be(rv,mv,s.D.x%2==0)) do ao(n,105,s.ch);s.aA[n]=true end
end
elseif s.O then s.O.m=mv;s.ar=nil
else s.ar=mv end
else
if m==1 then s.cn=false end
end;return
end
if x<=4 and y<=6 then
if s.M==3 then
local n=s:cT(x,y)
if s.C then
if z==1 then local st=s.C; local E=s.ab[st]; if not E then E={};s.ab[st]=E end
local f=false; for i=1,#E do if E[i]==n then table.remove(E,i);f=true;break end end
if not f and #E<6 then E[#E+1]=n end
if #E==0 then s.aG[st]=1;s.ab[st]=nil;s.K[st]=nil else s.aG[st]=3;s.K[st]=E[1] end
end
return
end
if z==1 then
local f=false;for i=1,#s.L do if s.L[i]==n then f=true;break end end
if not f then s.L[#s.L+1]=n end
if not s.D then
s.D={x=x,y=y};s.b1=true;s.bp=false
if s.H==1 and s.J==1 then for _,nn in aj(s.L) do ao(nn,105,s.ch);s.aA[nn]=true end
else s.O={rv=n,t=s.H,s=s.J,m=s.ah,mn=false,co={x=x,y=y}} end
elseif s.H==1 and s.J==1 and not f then ao(n,105,s.ch);s.aA[n]=true end
else
for i=1,#s.L do if s.L[i]==n then table.remove(s.L,i);break end end
if s.H==1 and s.J==1 then an(n,0,s.ch);s.aA[n]=nil end
if #s.L==0 then s.D=nil;s.O=nil;s:ak();s.bp=true end
end
return
end
if z==1 then
if s.bW then s.am=s.aX[x] and s.aX[x][y];s.aJ=(x%2==0);return end
local rv=s.aX[x] and s.aX[x][y]
if rv then
if s.M==1 then s.am=rv;s.aJ=(x%2==0) end
if s.C then s.K[s.C]=rv;s.aT[s.C]=(x%2==0);s.aF[s.C]=s.ah;s.ay[s.C]=s.H;s.ax[s.C]=s.J;s.aD[s.C]=s.a7 end
s.D={x=x,y=y};s.b1=true;s.bp=false
local pm=s.ar or s.ah;s.ar=nil
if s.H==1 and s.J==1 then
for _,n in aj(s:be(rv,s.ah,x%2==0)) do ao(n,105,s.ch);s.aA[n]=true end
else s.O={rv=rv,t=s.H,s=s.J,m=pm,mn=(x%2==0),co={x=x,y=y}} end
end
else
if s.D and s.D.x==x and s.D.y==y then
s.D=nil;s.O=nil
s:ak()
s.bp=true
end
end
end
end
}
pages[4]={cq="mseq",dj=4,cZ=16,U=1,bn=0,fc=0,bl=false,tk={},
init=function(s)
for k=1,3 do s.tk[k]={I={},Q=1,al=16,F=1,aQ=0,Z=false,by=5,b9=0,vg=1,bQ=8,cf=6,pc=0,a6=nil,bq=nil,b3=nil} end
s.bn=0; s.fc=0
end,
aC=function(s) return s.tk[s.U] end,
ce=function(s,k) return s.dj+k-1 end,
cQ=function(s,k)
local t=s.tk[k]
if t.a6 then an(t.a6,0,s:ce(k)); t.a6=nil end
if t.Z then return end
local d=t.I[t.F]
if d~=nil then
local n=pages[3]:c3(d + t.b9 + s.bn)
if n and n>=0 and n<=127 then ao(n,vgv(t.vg,t.F,100),s:ce(k)); t.a6=n end
end
end,
cU=function(s) for k=1,3 do local t=s.tk[k]; if t.a6 then an(t.a6,0,s:ce(k)); t.a6=nil end end end,
dl=function(s) for k=1,3 do local t=s.tk[k]; t.pc=t.pc+1; if t.pc>=t.cf then t.pc=0; t.F=t.F+1; if t.F>t.al or t.F<t.Q then t.F=t.Q end; s:cQ(k) end end end,
dK=function(s) for k=1,3 do local t=s.tk[k]; t.pc=0; t.F=t.Q; s:cQ(k) end end,
bR=function(s) s.fc=s.fc+1; if s.fc>=16 then s.fc=0 end; s.bl=s.fc<8 end,
dP=function(s,F)
local t=s:aC(); t.bQ=F; local af=F-8
local R=af>=0 and (1+0.5*af) or 1/(1+0.5*(-af))
t.cf=bs(1,aK(6/R+0.5))
end,
dk=function(s) local t=s:aC(); t.I={}; t.Q=1; t.al=16; t.F=1 end,
c1=function(s,x,y) local t=s:aC(); local bg=t.aQ+(7-y)
if t.I[x]==bg then t.I[x]=nil else t.I[x]=bg end end,
cm=function(s)
local t=s:aC(); local bl=s.bl
for k=1,3 do A(16,k, k==s.U and 15 or 4) end
for x=1,15 do local u=(x==8) and 4 or 2; if x==t.bQ then u=bl and 15 or 8 end; A(x,1,u) end
for x=1,16 do local u=(x==1) and 3 or 2; if x==t.vg then u=bl and 15 or 8 end; A(x,7,u) end
A(15,5, bl and 9 or 4); A(15,6, bl and 9 or 4)
A(14,6, bl and 12 or 5)
end,
bH=function(s,x,y,z)
if x==16 and y<=3 then if z==1 then s.U=y end; return true end
if y==1 and x<=15 then if z==1 then s:dP(x) end; return true end
if y==7 then if z==1 then s.tk[s.U].vg=x end; return true end
if x==15 and y==5 then if z==1 then s:aC().aQ=s:aC().aQ+1 end; return true end
if x==15 and y==6 then if z==1 then s:aC().aQ=s:aC().aQ-1 end; return true end
if x==14 and y==6 then if z==1 then s:dk() end; return true end
if y>=2 and y<=6 then if z==1 then s:c1(x,y) end; return true end
return false
end,
draw=function(s)
local t=s:aC()
for x=1,s.cZ do
local dB=(x>=t.Q and x<=t.al)
for y=1,7 do
local bg=t.aQ+(7-y); local u=0
if pages[3]:dq(bg) then u=2 end
if dB then u=bs(u,1) end
if t.I[x]==bg then u=8 end
if x==t.F then u=bs(u,(t.I[x]==bg) and 15 or 5) end
A(x,y,u)
end
local l8=2
if x==t.Q or x==t.al then l8=8 elseif x>t.Q and x<t.al then l8=4 end
if x==t.F then l8=bs(l8,11) end
A(x,8,l8)
end
end,
bh=function(s,x,y,z)
local t=s:aC()
if y==8 then
if z==1 then
if t.bq==nil then t.bq=x
else t.b3=x; local a,b=t.bq,t.b3; if a>b then a,b=b,a end
t.Q=a; t.al=b; if t.F<a or t.F>b then t.F=a end
end
else
if t.b3~=nil then t.bq=nil; t.b3=nil elseif t.bq==x then t.bq=nil end
end
return
end
if z==1 and x>=1 and x<=s.cZ and y>=1 and y<=7 then s:c1(x,y) end
end
}
SC={ca=false,U=nil,bB=nil,a5=nil,b2=nil,cj=false,bX=false,aq=0,aR=127,bz=32,cB=1,bG=false,mt=0,ap={},de={},dD={},
q=nil,qs=0,aW=0,bS=8,cF=false,
cs=function() return (SC.aR+SC.bz-1)//SC.bz end,
dI=function()
local B=SC.de; for i=#B,1,-1 do B[i]=nil end; local n=0; local sf=string.format
local function w(v) if v<0 then v=0 elseif v>255 then v=255 end; n=n+1; B[n]=sf("%02x",v&255) end
local p1,p2,p3,p4=pages[1],pages[2],pages[3],pages[4]
w(4)
w(p1.bC); w(p1.R); w(p1.bm)
for i=1,40 do w(aK((p1.ft[i] or 0)+0.5)) end
for y=1,6 do local m=0; for x=1,16 do if p2.I[y][x] then m=m|(1<<(x-1)) end end; w(m&255); w((m>>8)&255) end
for y=1,6 do w(p2.Y[y]) end
for y=1,6 do w(p2.vg[y]) end
local mm=0; for y=1,6 do if p2.Z[y] then mm=mm|(1<<(y-1)) end end; w(mm); w(p2.cg); w(p2.aU)
w(p3.ah);w(p3.bx);w(p3.H);w(p3.J);w(p3.a7);w(p3.a8);w(p3.aM)
w(p3.a2+1);w(p3.ac+8);w(p3.M);w(p3.am);w(p3.aJ and 1 or 0);w(p3.bc);w(p3.aV and 1 or 0);w(p3.S and 1 or 0)
w(p3.D and p3.D.x or 0); w(p3.D and p3.D.y or 0)
for i=1,8 do
w(p3.K[i] or 0);w(p3.aF[i] or 1);w(p3.aT[i] and 1 or 0);w(p3.ay[i] or 1)
w(p3.ax[i] or 1);w(p3.aD[i] or 1);w(p3.aE[i] or 1);w(p3.aN[i] or 1);w(p3.aY[i] or 1)
w(p3.aG[i] or 1)
local E=p3.ab[i]; for j=1,6 do w(E and E[j] or 0) end
end
for k=1,3 do local t=p4.tk[k]
for x=1,16 do local d=t.I[x]; w(d==nil and 255 or (d+100)) end
w(t.Q);w(t.al);w(t.aQ+100);w(t.Z and 1 or 0);w(t.by);w(t.vg);w(t.bQ)
end
return {table.concat(B)}
end,
unpack=function(P)
local s=P and P[1]; if type(s)~="string" then return false end
if #s<570 then return false end
local ci=-1; local function r() ci=ci+2; return tonumber(s:sub(ci,ci+1),16) or 0 end
local function c(v,a,b) if v<a then return a elseif v>b then return b end return v end
local dV=r(); if dV<4 then return false end
local p1,p2,p3,p4=pages[1],pages[2],pages[3],pages[4]
p1.bC=c(r(),1,p1.b6); p1.R=c(r(),1,8); p1.bm=c(r(),1,8)
for i=1,40 do p1.ft[i]=r(); p1.fs[i]=p1.fv[i]; p1.fr[i]=0 end
for y=1,6 do local lo=r(); local hi=r(); local m=lo|(hi<<8); for x=1,16 do p2.I[y][x]=(m&(1<<(x-1)))~=0 end end
for y=1,6 do p2.Y[y]=c(r(),1,16) end
for y=1,6 do p2.vg[y]=c(r(),1,16) end
local mm=r(); for y=1,6 do p2.Z[y]=(mm&(1<<(y-1)))~=0 end; p2.cg=c(r(),1,16); p2.aU=c(r(),1,6)
for y=1,6 do if p2.N[y]>p2.Y[y] then p2.N[y]=1 end end; p2:cu()
p3.ah=c(r(),1,15);p3.bx=c(r(),1,8);p3.H=c(r(),1,4);p3.J=c(r(),1,4);p3.a7=c(r(),1,4);p3.a8=c(r(),1,16);p3.aM=c(r(),1,16)
p3.a2=c(r(),0,2)-1; p3.ac=c(r(),2,14)-8; p3.M=c(r(),1,3); p3.am=c(r(),0,127); p3.aJ=(r()==1); p3.bc=c(r(),1,8); p3.aV=(r()==1); p3.S=(r()==1)
local lx=r(); local ly=r(); if lx>0 and lx<=4 and ly>=1 and ly<=6 then p3.D={x=lx,y=ly} else p3.D=nil end
for i=1,8 do local v=r(); if v==0 then p3.K[i]=nil else p3.K[i]=v end
p3.aF[i]=c(r(),1,15); p3.aT[i]=(r()==1); p3.ay[i]=c(r(),1,4); p3.ax[i]=c(r(),1,4); p3.aD[i]=c(r(),1,4); p3.aE[i]=c(r(),1,16); p3.aN[i]=c(r(),1,16); p3.aY[i]=c(r(),1,4)
p3.aG[i]=c(r(),1,3)
local E=nil; for j=1,6 do local nn=r(); if nn>0 then if not E then E={} end; E[#E+1]=nn end end; p3.ab[i]=E
end
for k=1,3 do local t=p4.tk[k]
for x=1,16 do local d=r(); if d==255 then t.I[x]=nil else t.I[x]=d-100 end end
t.Q=c(r(),1,16); t.al=c(r(),1,16); t.aQ=r()-100; t.Z=(r()==1); t.by=c(r(),1,8); t.vg=c(r(),1,16); t.bQ=c(r(),1,15)
if t.al<t.Q then t.al=t.Q end
local af=t.bQ-8; local ml=af>=0 and (1+0.5*af) or 1/(1+0.5*(-af)); t.cf=bs(1,aK(6/ml+0.5))
if t.F<t.Q or t.F>t.al then t.F=t.Q end
end
p3.bT=(p3.bc-5)*p1.R
for k=1,3 do p4.tk[k].b9=(p4.tk[k].by-5)*p1.R end
p4.bn=(p1.bm-5)*p1.R
return true
end,
dR=function()
pages[3]:aI(); pages[3]:ak(); pages[4]:cU()
local p2=pages[2]; for y=1,6 do if p2.bt[y] then an(p2.bt[y],0,p2.ch); p2.bt[y]=nil; p2.bI[y]=nil end end
end,
dW=function(au)
local B=SC.dD; for i=#B,1,-1 do B[i]=nil end
local sf=string.format; B[1]="05"
for b=0,15 do local v=0
for k=0,7 do local i=b*8+k+1; if i<=SC.aR and SC.ap[i] then v=v|(1<<k) end end
B[#B+1]=sf("%02x",v)
end
aL(pset_write,SC.cB,{table.concat(B)})
end,
cE=function(au,aa)
bf()
local ok,B=aL(pset_read,aa+1); if not ok or not B then return end
SC.cj=true
SC.dR(); aL(SC.unpack,B); SC.bB=aa; B=nil
if SC.bX and pages[3].S then aL(pages[3].bi,pages[3]) end
SC.cj=false
if SC.bG then SC.mt=8 end; bf()
end,
dL=function(au,aa)
bf()
local ok,P=aL(SC.dI); if not ok then return end
if aL(pset_write,aa+1,P) then
SC.ap[aa]=true; SC.bB=aa; SC.bG=true; SC.mt=8
end
bf()
end,
ds=function(au,aa) aL(pset_delete,aa+1); SC.ap[aa]=false; if SC.bB==aa then SC.bB=nil end; SC.bG=true; SC.mt=8; bf() end,
vs=function(k) return type(k)=="number" and k>=1 and k<=SC.aR end,
cw=function(op,aa)
if SC.q or not SC.vs(aa) then return end
SC.q=op; SC.qs=aa
end,
dN=function(au)
if SC.aW>0 then SC.aW=SC.aW-1; return end
if not SC.cF then
SC.cF=true
aL(pset_init,"gridcomp"); aL(SC.dM,SC)
SC.aW=SC.bS; return
end
if SC.b2 then local s=SC.b2; SC.b2=nil
if SC.vs(s) then SC:cE(s) end; SC.mt=8; SC.aW=SC.bS; return end
local o=SC.q
if o then local s=SC.qs; SC.q=nil
if SC.vs(s) then
if o==1 then SC:dL(s) elseif o==2 then SC:cE(s) else SC:ds(s) end
end
SC.aW=SC.bS; return
end
if SC.bG then SC.mt=SC.mt-1
if SC.mt<=0 then SC.bG=false; SC:dW(); SC.aW=SC.bS; bf() end
end
end,
dM=function(au)
local ok,m=aL(pset_read,SC.cB)
for i=1,SC.aR do SC.ap[i]=false end
if ok and type(m)=="table" then
local h=m[1]
if type(h)=="string" and #h>=34 then
for i=1,SC.aR do
local b=(i-1)//8; local k=(i-1)%8
local v=tonumber(h:sub(3+b*2,4+b*2),16) or 0
SC.ap[i]=((v>>k)&1)==1
end
elseif h==4 then
for i=1,SC.aR do SC.ap[i]=(m[i+1]==1) end
end
end
m=nil; bf()
end,
dv=function(au) local i=SC.U; if not i or not SC.ap[i] then return end; if SC.bX then SC.a5=i else SC.cw(2,i); SC.a5=nil end end,
dx=function(au) local i=SC.U; if i then SC.cw(1,i) end end,
du=function(au) local i=SC.U; if i and SC.ap[i] then SC.cw(3,i); SC.U=nil end end,
dy=function(au,p1)
local bl=p1.bl; local cc=SC.aq*SC.bz
for li=1,SC.bz do local i=cc+li; local x=((li-1)%8)+1; local y=((li-1)//8)+1
local u=SC.ap[i] and 6 or 2
if SC.bB==i then u=11 end
if SC.a5==i or (SC.q and SC.qs==i) then u=bl and 15 or 1 elseif SC.U==i then u=bl and 15 or 4 end
A(x,y,u)
end
for y=5,7 do for x=1,8 do A(x,y,0) end end
for p=0,SC.cs()-1 do A(p+1,6, p==SC.aq and 12 or 3) end
end,
dz=function(au,p1)
A(1,8,15); A(2,8,0)
local a=SC.U
A(3,8,(a and SC.ap[a]) and (SC.a5 and (p1.bl and 15 or 3) or 12) or 3)
A(4,8, a and 12 or 3)
A(5,8,(a and SC.ap[a]) and 12 or 3)
A(6,8,0)
A(7,8, SC.aq>0 and 8 or 2)
A(8,8, SC.aq<SC.cs()-1 and 8 or 2)
end,
bh=function(au,x,y,z)
if z~=1 then return true end
if y==8 then
if x==1 then SC.ca=false; SC.U=nil
elseif x==3 then SC:dv()
elseif x==4 then SC:dx()
elseif x==5 then SC:du()
elseif x==7 then if SC.aq>0 then SC.aq=SC.aq-1 end
elseif x==8 then if SC.aq<SC.cs()-1 then SC.aq=SC.aq+1 end end
return true
end
if y>=1 and y<=4 then local i=SC.aq*SC.bz+((y-1)*8+x); if i>=1 and i<=SC.aR then SC.U=(SC.U==i) and nil or i end end
return true
end
}
for i=1,#pages do pages[i]:init() end
m_main=metro.init(framework_tick,0.03) m_main:start()