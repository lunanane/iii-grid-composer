local u=pages local C=grid_led local al=ipairs local ap=midi_note_on local aB=midi_note_off local aH=current_page local aM=math.floor local aN=pcall local aT=menu_active local bh=collectgarbage local b9=math.max local dA=pairs
aH=1; aT=false; u={}
function draw()
grid_led_all(0)
if u[aH] and u[aH].draw then u[aH]:draw() end
if aT then
for p=1,16 do C(p,8, p==aH and 15 or (u[p] and 4 or 0)) end
local pg=u[aH]; if pg.cs then pg:cs() end
end
C(16,8,aT and 15 or 6)
grid_refresh()
end
event_grid=function(x,y,z)
if x==16 and y==8 then
if z==1 then aT=not aT end return
end
if aT then
local pg=u[aH]
if pg.bI and pg:bI(x,y,z) then return end
if y==8 and z==1 and u[x] then aH=x; aT=false end return
end
if u[aH] then u[aH]:bi(x,y,z) end
end
local aS=0; local bc=0; local a4=0
function event_midi(d1,d2,d3)
if d1==248 then
if SC.cq then return end
aS=aS+1; a4=a4+1; SC.bZ=true
if u[3] then u[3]:df() end
if u[4] then u[4]:de() end
if a4>=96 then a4=0; if u[3] then u[3]:c9() end
if SC.a9 then SC.b6=SC.a9; SC.a9=nil end end
local s=u[2]
if s then
if s.bf and a4==0 then
s.bv={}; s.aw=nil; s.bf=false; s.ai=1
for r=1,6 do s.O[r]=1 end; s:bE(); aS=0; bc=0; return
end
if s.aw then
bc=bc+1; if bc>=s.cB then
bc=0; s.bF=not s.bF; s.ai=s.aw
for r=1,6 do s.O[r]=((s.aw-1)%s.Z[r])+1 end; s:bE()
end
if aS>=6 then aS=0 end
elseif aS>=6 then aS=0; bc=0; s.ai=s.ai+1; if s.ai>s.bt then s.ai=1 end; for y=1,6 do s.O[y]=s.O[y]+1; if s.O[y]>s.Z[y] then s.O[y]=1 end end; s:bE() end
end
elseif d1==250 or d1==251 then
aS=1; bc=0; a4=0
if u[2] then u[2].ai=1; for y=1,6 do u[2].O[y]=1 end; u[2]:bE() end
if u[3] then u[3].bB=0; u[3].R=1; u[3].a3=0; u[3].be=1; u[3].aV=0
if u[3].ab then u[3].H=1; u[3]:bj() end
end
if u[4] then local rp=u[4]; for k=1,3 do local t=rp.tk[k]; t.pc=0; t.I=t.U; t.pg=1; rp:cQ(k) end end
elseif d1==252 then
SC.bZ=false
if u[3] then u[3]:aK(); u[3]:am() end
if u[4] then for k=1,3 do u[4]:b4(k) end end
for n=0,127 do for c=1,7 do aB(n,0,c) end end
end
end
local ck=0
function framework_tick()
for i=1,#u do if u[i].bT then u[i]:bT() end end
if SC:dD() then return end
ck=1-ck; if ck==0 then draw() end
end
function vgv(g,i,bC)
if g<=1 then return bC end
local n=g-1; local p=(i-1)%16; local sh
if n<=4 then local k=(n==1 and 4)or(n==2 and 2)or(n==3 and 8)or 3; sh=(p%k==0) and 1 or 0.15
elseif n<=8 then local m=n-4; local k=(m<=2 and 4)or(m==3 and 2)or 8; local o=(m==1 and 2)or(m==4 and 4)or 1; sh=((p-o)%k==0) and 1 or 0.2
elseif n<=12 then local f=n-8; sh=(math.sin(p/16*f*6.2832)+1)*0.5
else local f=n-12; local a=(p%4==0) and 1 or 0; local b=(math.sin((p+1)/16*f*6.2832)+1)*0.35; sh=(a>b) and a or b end
return aM(76+32*sh+0.5)
end
u[1]={cJ=1,cI=20,FT=0.5,FD=0.03,bk=1,cb=5,
fv={},ft={},fs={},fr={},fl={},aJ=0,bl=false,V=1,bo=5,ez=false,
init=function(s)
for i=1,s.cb*8 do s.fv[i]=0;s.ft[i]=0;s.fs[i]=0;s.fr[i]=s.FT;s.fl[i]=-1 end
for f=1,8 do local i=f; s.fv[i]=102;s.ft[i]=102;s.fs[i]=102;s.fl[i]=102; midi_cc(s.cI+i-1,102,s.cJ) end
end,
bT=function(s)
s.aJ=(s.aJ+1)%16; s.bl=(s.aJ<8)
if not s.ez then return end
local cE=false
for i=1,s.cb*8 do
if s.fr[i]<s.FT then cE=true
s.fr[i]=s.fr[i]+s.FD
local t=s.fr[i]/s.FT; if t>1 then t=1 end
local e=t*(2-t)
local v=s.fs[i]+(s.ft[i]-s.fs[i])*e; s.fv[i]=v
local iv=aM(v+0.5)
if iv~=s.fl[i] then s.fl[i]=iv; midi_cc(s.cI+i-1,iv,s.cJ) end
end
end
s.ez=cE
end,
cs=function(s) for b=1,5 do C(16,b, b==s.bk and 15 or 4) end end,
bI=function(s,x,y,z) if z==1 and x==16 and y<=7 then if y>=1 and y<=s.cb then s.bk=y end;aT=false;return true end return false end,
draw=function(s)
if SC.cj then SC:dn(s); SC:dp(s) else
local cW=u[2] and u[2].aa
for x=1,8 do local A=1
if x<=6 then local m=cW and cW[x]; A=m and(s.bl and 15 or 3)or 6 end
C(x,1,A)
end
for y=2,5 do
local r=y-1; local I,cu
if r==1 then I=(u[3] and u[3].bg) or 5; cu=u[3] and u[3].aY
else local t=u[4] and u[4].tk[r-1]; I=(t and t.bz) or 5; cu=t and t.aa end
for x=1,8 do local A
if x==1 then A=cu and(s.bl and 15 or 8)or 3
else A=(x==5) and 4 or 2; if x==I then A=15 end end
C(x,y,A)
end
end
for x=1,8 do C(x,6,(x==s.V) and 15 or 2) end
for x=1,8 do C(x,7,(x==s.bo) and 15 or((x==5) and 4 or 2)) end
for x=1,8 do C(x,8, x==1 and 8 or 1) end
end
for f=1,8 do
local i=((s.bk-1)*8+f); local x=8+f; local du=aM(s.fv[i]/127*7+0.5)
for y=1,8 do local dc=9-y; C(x,y,((dc-1)<=du) and 7 or 2) end
end
end,
bi=function(s,x,y,z)
if x>=9 and x<=16 then
if z~=1 then return end
local i=((s.bk-1)*8+(x-8)); s.fs[i]=s.fv[i]; s.ft[i]=aM((8-y)/7*127+0.5); s.fr[i]=0; s.ez=true; return
end
if SC.cj then SC:bi(x,y,z); return end
if y>=2 and y<=5 then
if z~=1 then return end
local r=y-1
if x==1 then
if r==1 then local p=u[3]; if p then p.aY=not p.aY; if p.aY then p:aK();p:am() end end
else local t=u[4] and u[4].tk[r-1]; if t then t.aa=not t.aa end end
return
end
if x>=2 and x<=8 then local aj=(x-5)*s.V
if r==1 then local p=u[3]; if p then p.bg=x; p.bV=aj end
else local t=u[4] and u[4].tk[r-1]; if t then t.bz=x; t.cg=aj end end
end
return
end
if z~=1 then return end
if y==8 then if x==1 then SC.cj=true end return end
if y==1 then if x<=6 and u[2] then u[2].aa[x]=not u[2].aa[x] end return end
if y==6 then s.V=x
for r=1,4 do
if r==1 then local p=u[3]; if p then p.bV=(p.bg-5)*s.V end
else local t=u[4] and u[4].tk[r-1]; if t then t.cg=(t.bz-5)*s.V end end
end
if u[4] then u[4].bp=(s.bo-5)*s.V end
return
end
if y==7 then s.bo=x; if u[4] then u[4].bp=(x-5)*s.V end return end
end
}
u[2]={G={},O={},Z={},vg={},ai=1,bt=16,bv={},aw=nil,cB=6,bF=false,bf=false,dy={60,61,62,63,64,65},ch=2,bm={},ce=false,aa={},aX=1,bu={},bJ={},cp=1,
init=function(s) for y=1,6 do s.G[y]={}; for x=1,16 do s.G[y][x]=false end; s.O[y]=1; s.Z[y]=16; s.bm[y]=nil; s.vg[y]=1 end; s.aX=1; s.ai=1; s.bt=16; s.bv={}; s.aw=nil; s.cB=6; s.bF=false; s.bf=false end,
cx=function(s) local m=1; for y=1,6 do if s.Z[y]>m then m=s.Z[y] end end; s.bt=m; if s.ai>s.bt then s.ai=1 end end,
cZ=function(s) local ca=99; local cr=0; local c=0; for x=1,15 do if s.bv[x] then c=c+1; if x<ca then ca=x end; if x>cr then cr=x end end end
if c==0 then s.aw=nil; s.bf=false else s.aw=ca; local sp=cr-ca; s.cB=(sp==0 and 6 or (sp==1 and 12 or (sp==2 and 8 or (sp==3 and 6 or (sp==4 and 4 or 3))))) end end,
bE=function(s) for y=1,6 do if s.G[y][s.O[y]] and not s.aa[y] then local nt=s.dy[y];ap(nt,vgv(s.vg[y],s.O[y],100),s.ch);s.bu[y]=nt;s.bJ[y]=s.cp end end end,
bT=function(s) for y=1,6 do local c=s.bJ[y]; if c then if c<=1 then aB(s.bu[y],0,s.ch);s.bJ[y]=nil;s.bu[y]=nil else s.bJ[y]=c-1 end end end end,
bI=function(s,x,y,z)
if z==1 and y>=1 and y<=6 then s.Z[y]=16; for i=1,16 do s.G[y][i]=false end; s.O[y]=1; s:cx(); return true end
return false
end,
draw=function(s)
for y=1,6 do local l=s.Z[y]; local p=s.O[y]; local bA=(y==s.aX)
for x=1,16 do local A=0
if x<=l then A=s.G[y][x] and 8 or (bA and 3 or 2); if x==1 or x==l then A=b9(A,bA and 6 or 4) end; if x==p then A=13 end end
C(x,y,A)
end
end
for x=1,16 do local A
if x==1 and s.aw~=nil then A=s.bf and 15 or 4
else A=(x==s.vg[s.aX]) and 15 or (x==1 and 3 or 2) end
C(x,7,A)
end
for x=1,15 do local A=0; if x<=s.bt then if s.bv[x] then A=s.bF and 15 or 6 elseif x==s.ai and s.aw==nil then A=11 else A=4 end end; C(x,8,A) end; C(16,8,4)
end,
bi=function(s,x,y,z)
if y==8 then if x==16 then return end; if z==1 and x<=s.bt then s.bv[x]=true; s:cZ(); if s.aw==x then s.ai=x; for r=1,6 do s.O[r]=((x-1)%s.Z[r])+1 end; s.bF=true; s:bE() end else s.bv[x]=nil; s:cZ() end return end
if y==7 then
if z~=1 then return end
if x==1 and s.aw~=nil then s.bf=true; return end
s.vg[s.aX]=x; return
end
if z==1 then if s.bm[y]==nil then s.bm[y]=x; s.ce=false else local st=s.bm[y]; if st==1 and x>1 then s.Z[y]=x; s.aX=y; s.ce=true; if s.O[y]>s.Z[y] then s.O[y]=1 end; s:cx() end end
else if s.bm[y]==x then if not s.ce then s.G[y][x]=not s.G[y][x] end; s.bm[y]=nil; s.ce=false end end
end
}
u[3]={ch=3,a1={{64,69,62,67,60,65},{61,66,71,64,69,62},{71,66,63,68,63,70},{68,63,70,65,60,67}},
bw={0,2,4,5,7,9,11},bx={0,2,3,5,7,8,10},
cK={{0},{0,1,4},{0,2,4},{0,3,4},{0,4},{0,2,4,5},{0,2,4,6},{0,2,4,6,8}},
db={{0,4,7,10},{0,4,7,11},{0,3,6},{0,4,8},{0,4,6,10},{0,4,8,10},{0,1,4,7}},
cS={65535,21845,18761,4369,26214,27437,43690,17476,4681,9289,21157,257,4112,43947,28013,34952},
ac=1,by=5,ct=false,E=nil,aY=false,bV=0,bg=5,
cm={},aA={},a2={},N={},aF={},aE={},ay={},ax={},aD={},aR={},aW={},aG={},af={},
dg={},K={},dj={},ob={},sm={5,4,3,2},
J=1,M=1,ba=1,bb=1,sw=0,bX=false,aJ=0,ab=true,
bQ=nil,bO=nil,bM=nil,bP=nil,bN=nil,Q=nil,ar=nil,
R=1,a3=0,be=1,aV=0,a7=nil,a8=nil,Y=0,S=1,bq=1,
b8={[1]=12,[2]=8,[3]=6,[4]=4},
H=1,bB=0,D=nil,b3=nil,bn=0,aP=1,cY=8,pn=8,a6=0,ah=0,
L=1,ao=60,aL=false,bY=false,az=nil,
b5=false,br=false,
c7={1,3,2,4,3,5,4,6},
init=function(s)
for y=1,8 do s.a2[y]=1;s.aF[y]=1;s.ay[y]=1;s.ax[y]=1;s.aD[y]=1;s.aE[y]=1;s.aR[y]=1;s.aW[y]=false;s.aG[y]=1;s.af[y]=nil end
end,
bG=function(s,g,i) local m=s.cS[g] or s.cS[1]; return (m>>(i-1))&1==1 end,
c1=function(s)
local r,mn
if s.L>=2 then r=s.ao; mn=s.aL
elseif s.E then r=s:rv(s.E); mn=(s.E.x%2==0)
elseif s.N[s.H] then r=s.N[s.H]; mn=s.aW[s.H] end
if type(r)~="number" then r=60; mn=false end
r=54+((r-54)%12)
return r,(mn and s.bx or s.bw)
end,
c0=function(s,d)
local r,iv=s:c1()
return r+12*(d//7)+iv[(d%7)+1]
end,
rv=function(s,lr)
if not lr then return nil end
return s.a1[lr.x] and s.a1[lr.x][lr.y]
end,
cN=function(s,dx) local iv=s.aL and s.bx or s.bw;local bR=dx-s.ao;local cw=bR//12;local aj=bR%12;local b=1;local bd=99;for i=1,7 do local dd=iv[i]-aj;if dd<0 then dd=-dd end;if dd<bd then bd=dd;b=i end end;return cw*7+(b-1) end,
cT=function(s,x,y) local iv=s.aL and s.bx or s.bw;local d=(x-1)*6+(6-y);return s.ao+12*(d//7)+iv[(d%7)+1] end,
a0=function(s,r,m,mn)
local p=s.dg; for i=#p,1,-1 do p[i]=nil end
if not r or s.aY then return p end
local ko=12*s.a6
local lk=s.L>=2 and s.ao
if m>8 then local rr=r
if lk then local iv=s.aL and s.bx or s.bw;local d=s:cN(r);rr=s.ao+12*(d//7)+iv[(d%7)+1] end
for _,i in al(s.db[m-8]) do p[#p+1]=rr+i+ko end
elseif lk then local iv=s.aL and s.bx or s.bw;local d0=s:cN(r)
for _,cd in al(s.cK[m]) do local d=d0+cd;p[#p+1]=s.ao+12*(d//7)+iv[(d%7)+1]+ko end
else local iv=mn and s.bx or s.bw
for _,d in al(s.cK[m]) do p[#p+1]=r+12*(d//7)+iv[(d%7)+1]+ko end
end
if #p>s.by then for i=#p,s.by+1,-1 do p[i]=nil end end
local T=(s.bV or 0)+((u[4] and u[4].bp) or 0)
if T~=0 then
local ak=s.dj; for i=#ak,1,-1 do ak[i]=nil end
for _,n in al(p) do
local sr,dF=s:c1()
local bR=n-sr; local cw=bR//12; local pc=bR%12
local bW,bd=99,0
for di=0,6 do local dd=math.abs(dF[di+1]-pc); if dd<bW then bW=dd;bd=di end end
local dw=math.abs(12-pc); if dw<bW then bW=dw;bd=7 end
ak[#ak+1]=cw*7+bd
end
table.sort(ak)
for i=2,#ak do if ak[i]<=ak[i-1] then ak[i]=ak[i-1]+1 end end
local bK=s.ob; for i=#bK,1,-1 do bK[i]=nil end
for _,d in al(ak) do local nn=s:c0(d+T); if nn>=0 and nn<=127 then bK[#bK+1]=nn end end
p=bK
end
local iv=s.ah or 0
if iv~=0 and #p>0 then local n=#p
for _=1,(iv>0 and iv or -iv) do
if iv>0 then local mi=1;for j=2,n do if p[j]<p[mi] then mi=j end end;p[mi]=p[mi]+12
else local ma=1;for j=2,n do if p[j]>p[ma] then ma=j end end;p[ma]=p[ma]-12 end
end
end
return p
end,
cR=function(s,r) if r then for x=1,4 do for y=1,6 do if s.a1[x][y]==r then return x,y end end end end end,
c2=function(s,r) if s.aG[r]==3 and s.af[r] then return s.af[r] end;return s:a0(s.N[r],s.aF[r],s.aW[r]) end,
cH=function(s,p,d,st,c4)
if #p==0 then return nil end;local l=#p;local pi
if d==1 then pi=p[((st-1)%l)+1] elseif d==2 then pi=p[l-((st-1)%l)]
elseif d==3 then local cy=l*2;local ph=(st-1)%cy;pi=ph<l and p[ph+1] or p[cy-ph]
elseif d==4 then local sq=s.c7;pi=p[((sq[((st-1)%#sq)+1]-1)%l)+1] end
if c4 and st%2==0 and pi then pi=pi+12 end;return pi
end,
aK=function(s) for n in dA(s.cm) do aB(n,0,s.ch);s.cm[n]=nil end;if s.a7 then aB(s.a7,0,s.ch);s.a7=nil end end,
am=function(s) for n in dA(s.aA) do aB(n,0,s.ch);s.aA[n]=nil end;if s.a8 then aB(s.a8,0,s.ch);s.a8=nil end end,
cl=function(s,v) local g=2+(v-76)//8; return g<2 and 2 or(g>6 and 6 or g) end,
cP=function(s,r) s:aK();local v=vgv(s.aR[r] or s.aP,s.R,95);for _,n in al(s:c2(r)) do ap(n,v,s.ch);s.cm[n]=true end;s.az=s:cl(v) end,
bj=function(s) s:aK();if not s.ab then return end;if (s.ay[s.H] or 1)==1 and (s.ax[s.H] or 1)==1 and s.N[s.H] then s:cP(s.H) end end,
c6=function(s)
if s.Q then
local ql=s.Q;s.Q=nil;s.ar=nil;s:am();s.ac=ql.m
local qt=ql.t
if qt==1 and ql.s==1 then s.az=nil;for _,n in al(s.L==3 and s.K or s:a0(ql.rv,ql.m,ql.mn)) do ap(n,105,s.ch);s.aA[n]=true end
elseif qt==1 and ql.s>1 then s.Y=999;s.S=1
elseif qt==2 or qt==3 then s.Y=999;s.bq=1;s.S=1 end
elseif s.ar then
local qm=s.ar;s.ar=nil;s.ac=qm;s:am()
local rv=s:rv(s.E)
if s.J==1 and s.M==1 then
if rv then for _,n in al(s:a0(rv,qm,s.E and s.E.x%2==0)) do ap(n,105,s.ch);s.aA[n]=true end end
elseif s.J==1 and s.M>1 then s.Y=999;s.S=1
elseif s.J==2 or s.J==3 then s.Y=999;s.bq=1;s.S=1 end
end
end,
dG=function(s,rv)
local mn=s.E and(s.E.x%2==0)or false
if s.J==1 and s.M>1 then
s.Y=s.Y+1
if s.Y>=s.b8[s.M]+(s.S%2==0 and s.sw or 0) then
s.Y=0;s:am()
if s:bG(s.bb,s.S) then local v=vgv(s.aP,s.S,105);for _,n in al((s.L==3 and s.K or s:a0(rv,s.ac,mn))) do ap(n,v,s.ch);s.aA[n]=true end;s.az=s:cl(v) end
s.S=(s.S%16)+1
end
elseif s.J==2 or s.J==3 then
s.Y=s.Y+1
if s.Y>=s.b8[s.M]+(s.S%2==0 and s.sw or 0) then
s.Y=0
if s:bG(s.bb,s.S) then
if s.a8 then aB(s.a8,0,s.ch);s.a8=nil end
local p=s:cH((s.L==3 and s.K or s:a0(rv,s.ac,mn)),s.ba,s.bq,s.J==3)
if p then local v=vgv(s.aP,s.S,105);ap(p,v,s.ch);s.a8=p;s.az=s:cl(v) end
s.bq=s.bq+1
end
s.S=(s.S%16)+1
end
end
end,
df=function(s)
if a4%24==0 then s:c6() end
local rv=s:rv(s.E)
if rv then s:dG(rv) end
if s.ab and not s.D and not s.b5 then
local t=s.ay[s.H] or 1;local sp=s.ax[s.H] or 1;local d=s.aD[s.H] or 1
if t==1 and sp>1 then
s.a3=s.a3+1
if s.a3>=s.b8[sp]+(s.R%2==0 and s.sw or 0) then s.a3=0;s:aK();if s:bG(s.aE[s.H],s.R) then s:cP(s.H) end;s.R=(s.R%16)+1 end
elseif t==2 or t==3 then
s.aV=s.aV+1
if s.aV>=s.b8[sp]+(s.R%2==0 and s.sw or 0) then
s.aV=0
if s:bG(s.aE[s.H],s.R) then
if s.a7 then aB(s.a7,0,s.ch);s.a7=nil end
local p=s:cH(s:c2(s.H),d,s.be,t==3)
if p then local v=vgv(s.aR[s.H] or s.aP,s.R,98);ap(p,v,s.ch);s.a7=p;s.az=s:cl(v) end;s.be=s.be+1
end
s.R=(s.R%16)+1
end
end
end
end,
c9=function(s)
local qc=false
if s.bQ then s.J=s.bQ;s.bQ=nil;qc=true end
if s.bO then s.M=s.bO;s.bO=nil;qc=true end
if s.bM then s.ba=s.bM;s.bM=nil;qc=true end
if s.bP then s.by=s.bP;s.bP=nil;qc=true end
if s.bN then s.bb=s.bN;s.bN=nil;qc=true end
if qc then s.Y=999;s.S=1;s.bq=1 end
if s.br then
s.br=false;s.b5=false
s.R=1;s.be=1;s.a3=0;s.aV=0;s:bj()
end
if not s.ab then return end
s.bB=s.bB+1
if s.bB>=(s.a2[s.H] or 1) then
s.bB=0;local le=1;for r=1,8 do if s.N[r] then le=r end end
s.H=(s.H%le)+1;s.R=1;s.be=1;s.a3=0;s.aV=0;s:bj()
end
end,
bT=function(s)
s.aJ=(s.aJ+1)%48;s.bX=(s.aJ%16<8)
local ts=s.aJ/48; local dH=ts<0.5 and ts*2 or 2-ts*2; s.cY=8+aM(dH*7+0.5)
local tn=(s.aJ%10)/10; local cC=tn<0.5 and tn*2 or 2-tn*2; local en=cC*cC*(3-2*cC); s.pn=5+aM(en*10+0.5)
if s.b3 then s.bn=s.bn+1;if s.bn>14 then s.b3=nil;s.bn=0 end end
if s.az then if s.az<=1 then s:aK();s:am();s.az=nil else s.az=s.az-1 end end
end,
draw=function(s)
local tg=s.D or s.H;local dq,dr=s:cR(s.N[tg])
local at=s.D and s.ay[s.D] or (s.bQ or s.J)
local aO=s.cY
local cU,cV; if s.L==2 then cU,cV=s:cR(s.ao) end
local bA=(s.D or s.ab); local pn=s.pn
for y=1,6 do for x=1,4 do
local A
if s.L==3 then
A=(((x-1)*6+(6-y))%7==0) and (s.bX and 15 or 6) or 5
local gn=s:cT(x,y);for i=1,#s.K do if s.K[i]==gn then A=15;break end end
else
A=(x==1 or x==3) and 5 or 3
if bA and dq==x and dr==y and at~=4 then A=pn end
if cU==x and cV==y then A=s.bX and 15 or 4 end
if s.E and y==s.E.y and x==s.E.x then A=15 end
end
C(x,y,A)
end end
local sm=s.sm;local c8=s.bP or s.by
local as=s.D and s.ax[s.D] or(s.bO or s.M);local ad=s.D and s.aD[s.D] or(s.bM or s.ba)
for x=5,8 do
local v=x-4
C(x,1,at==v and aO or 0)
C(x,2,as==v and aO or 0)
C(x,3,ad==v and aO or 0)
C(x,4,(sm[x-4]==c8) and aO or 0)
end
local ag=s.D and s.aE[s.D] or(s.bN or s.bb)
for y=5,8 do for x=5,8 do local a5=((y-5)*4)+(x-4)
C(x,y, a5==ag and (s:bG(ag,s.R) and 15 or 7) or 6) end end
local b2=(s.Q and s.Q.m) or s.ar
local cf=s.ac;local cA=cf<=8 and cf or cf-7
local cO=b2 and(b2<=8 and b2 or b2-7)
local av=s.aF[tg];local c5=av and(av<=8 and av or av-7)
for y=7,8 do for x=1,4 do
local mi=((y-7)*4)+x;local A=0
if bA and c5==mi and at~=4 then A=aO end
if mi==cA then A=15 end
if cf>8 and mi==1 and cA~=1 then A=aO end
if cO and mi==cO and mi~=cA then A=aO end
C(x,y,A)
end end
if s.Q and s.Q.co then local co=s.Q.co;C(co.x,co.y,aO) end
for y=1,8 do
local ds=s.N[y]~=nil; local b1=s.a2[y] or 1
for x=9,12 do local b0=x-8; local A
if not ds then A=1 elseif b0<b1 then A=3 elseif b0==b1 then A=10 else A=2 end
if y==s.H and s.ab then if b0==b1 then A=aO elseif b0<b1 then A=5 end end
if s.b3==y and s.bn%3<2 then A=15 end
C(x,y,A)
end
end
local cM=s.D and s.aR[s.D] or s.aP
for y=1,4 do for x=13,16 do local a5=((y-1)*4)+(x-12); local A
if a5==cM then local cv=vgv(cM,s.R,100); A=4+aM((cv-76)/32*11+0.5); if A<4 then A=4 elseif A>15 then A=15 end
else A=(a5==1) and 3 or 2 end
C(x,y,A)
end end
C(13,5, s.sw==0 and 15 or 3); C(13,6, s.sw==1 and 15 or 3); C(13,7, s.sw==2 and 15 or 3)
C(14,5, s.L==1 and 15 or 3)
C(14,6, s.L==2 and 15 or (s.bY and 9 or 6))
C(14,7, s.L==3 and 15 or 3)
C(16,5, s.a6==1 and 15 or 3)
C(16,6, s.a6==0 and 12 or 5)
C(16,7, s.a6==-1 and 15 or 3)
C(15,6, 6)
C(15,5, s.ah>0 and math.min(15,6+s.ah*3) or 2)
C(15,7, s.ah<0 and math.min(15,6-s.ah*3) or 2)
C(13,8, s.ab and 6 or (s.bX and 15 or 2))
C(14,8,0)
end,
bI=function(s,x,y,z)
if z==1 and x>=9 and x<=12 and y>=1 and y<=8 then
s.N[y]=nil;s.a2[y]=1;s.aF[y]=1;s.ay[y]=1;s.ax[y]=1;s.aD[y]=1;s.aE[y]=1;s.aG[y]=1;s.af[y]=nil;return true
end
return false
end,
bi=function(s,x,y,z)
if x>=9 and x<=12 and y<=8 then
if z==1 then
if s.L==3 then
local F=s.af[y]; if not F then F={};s.af[y]=F end
for i=#F,1,-1 do F[i]=nil end
for i=1,#s.K do if i<=6 then F[i]=s.K[i] end end
s.aG[y]=3; s.N[y]=F[1]
else
local rv=s:rv(s.E)
s.N[y]=rv or s.N[y]; s.aG[y]=1; s.af[y]=nil
if s.E then s.aW[y]=(s.E.x%2==0) end
s.aF[y]=(s.Q and s.Q.m) or s.ar or s.ac
end
s.ay[y]=s.J;s.ax[y]=s.M;s.aD[y]=s.ba;s.aE[y]=s.bb;s.aR[y]=s.aP;s.a2[y]=x-8
s.b3=y;s.bn=0;s.D=y
else if s.D==y then s.D=nil;s:bj() end end;return
end
if x>=13 and x<=16 and y<=4 then if z==1 then local a5=((y-1)*4)+(x-12); if s.D then s.aR[s.D]=a5 else s.aP=a5 end end;return end
if x==13 and y>=5 and y<=7 then if z==1 then s.sw=(y==5 and 0) or (y==6 and 1) or 2 end;return end
if x==16 and y>=5 and y<=7 then if z==1 then s.a6=(y==5 and 1) or (y==6 and 0) or -1 end;return end
if x==15 and y>=5 and y<=7 then if z==1 then if y==6 then s.ah=0 elseif y==5 then s.ah=math.min(6,s.ah+1) else s.ah=b9(-6,s.ah-1) end end;return end
if x==14 and y>=5 and y<=7 then
if z==1 then s:am();for i=#s.K,1,-1 do s.K[i]=nil end;s.E=nil;s.Q=nil
if y==5 then s.L=1 elseif y==6 then s.L=2;s.bY=true else s.L=3 end
else if y==6 then s.bY=false end end
return
end
if x>=5 and x<=8 and y<=4 then
if z==1 then
local v=x-4;local tg=s.D or s.H
if y==4 then v=s.sm[v] end
if s.D then
if y==1 then s.ay[tg]=v;if v==4 then s:aK() end elseif y==2 then s.ax[tg]=v elseif y==3 then s.aD[tg]=v end
else
if y==1 then s.bQ=v elseif y==2 then s.bO=v elseif y==3 then s.bM=v elseif y==4 then s.bP=v end
end
end;return
end
if x>=5 and x<=8 and y>=5 and y<=8 then
if z==1 then local g=((y-5)*4)+(x-4);if s.D then s.aE[s.D]=g else s.bN=g end end;return
end
if x==13 and y==8 then if z==1 then s.ab=not s.ab;if s.ab then s:bj() else s:aK() end end;return end
if y>=7 and x<=4 then
local m=((y-7)*4)+x
if z==1 then
local mv=(s.ct and m>1) and (8+(m-1)) or m
if m==1 then s.ct=true end
if s.D then s.aF[s.D]=mv end
if s.J==1 and s.M==1 then
s.ac=mv;s.ar=nil;s:am()
if s.E then
local rv=s:rv(s.E)
for _,n in al(s:a0(rv,mv,s.E.x%2==0)) do ap(n,105,s.ch);s.aA[n]=true end
end
elseif s.Q then s.Q.m=mv;s.ar=nil
else s.ar=mv end
else
if m==1 then s.ct=false end
end;return
end
if x<=4 and y<=6 then
if s.L==3 then
local n=s:cT(x,y)
if s.D then
if z==1 then local st=s.D; local F=s.af[st]; if not F then F={};s.af[st]=F end
local f=false; for i=1,#F do if F[i]==n then table.remove(F,i);f=true;break end end
if not f and #F<6 then F[#F+1]=n end
if #F==0 then s.aG[st]=1;s.af[st]=nil;s.N[st]=nil else s.aG[st]=3;s.N[st]=F[1] end
end
return
end
if z==1 then
local f=false;for i=1,#s.K do if s.K[i]==n then f=true;break end end
if not f then s.K[#s.K+1]=n end
if not s.E then
s.E={x=x,y=y};s.b5=true;s.br=false
if s.J==1 and s.M==1 then for _,nn in al(s.K) do ap(nn,105,s.ch);s.aA[nn]=true end
else s.Q={rv=n,t=s.J,s=s.M,m=s.ac,mn=false,co={x=x,y=y}} end
elseif s.J==1 and s.M==1 and not f then ap(n,105,s.ch);s.aA[n]=true end
else
for i=1,#s.K do if s.K[i]==n then table.remove(s.K,i);break end end
if s.J==1 and s.M==1 then aB(n,0,s.ch);s.aA[n]=nil end
if #s.K==0 then s.E=nil;s.Q=nil;s:am();s.br=true end
end
return
end
if z==1 then
if s.bY then s.ao=s.a1[x] and s.a1[x][y];s.aL=(x%2==0);return end
local rv=s.a1[x] and s.a1[x][y]
if rv then
if s.L==1 then s.ao=rv;s.aL=(x%2==0) end
if s.D then s.N[s.D]=rv;s.aW[s.D]=(x%2==0);s.aF[s.D]=s.ac;s.ay[s.D]=s.J;s.ax[s.D]=s.M;s.aD[s.D]=s.ba end
s.E={x=x,y=y};s.b5=true;s.br=false
local pm=s.ar or s.ac;s.ar=nil
if s.J==1 and s.M==1 then
for _,n in al(s:a0(rv,s.ac,x%2==0)) do ap(n,105,s.ch);s.aA[n]=true end
else s.Q={rv=rv,t=s.J,s=s.M,m=pm,mn=(x%2==0),co={x=x,y=y}} end
end
else
if s.E and s.E.x==x and s.E.y==y then
s.E=nil;s.Q=nil
s:am()
s.br=true
end
end
end
end
}
u[4]={cL=4,cX=16,W=1,bp=0,fc=0,bl=false,tk={},
init=function(s)
for k=1,3 do s.tk[k]={G={},U=1,an=16,I=1,aQ=0,aa=false,bz=5,cg=0,vg=1,bS=8,cn=6,pc=0,bL=nil,bs=nil,b7=nil,np=1,ep=1,pg=1,fp=nil,ra=false,ti=false} end
s.bp=0; s.fc=0
end,
X=function(s) return s.tk[s.W] end,
b4=function(s,k) local t=s.tk[k]; if t.bL then aB(t.bL,0,(s.cL+k-1)); t.bL=nil end end,
cQ=function(s,k)
local t=s.tk[k]; local n
if not t.aa then
local d=t.G[(t.pg-1)*16+t.I]
if d~=nil then local m=u[3]:c0(d + t.cg + s.bp); if m and m>=0 and m<=127 then n=m end end
end
if n and t.ti and t.bL==n then return end
s:b4(k)
if n then ap(n,vgv(t.vg,t.I,100),(s.cL+k-1)); t.bL=n end
end,
de=function(s) for k=1,3 do local t=s.tk[k]; t.pc=t.pc+1; if t.pc>=t.cn then t.pc=0; t.I=t.I+1
if t.I>t.an or t.I<t.U then t.I=t.U; t.pg=(t.pg>=t.np) and 1 or (t.pg+1); if t.pg==1 then s:b4(k) end end
s:cQ(k) end end end,
bT=function(s) s.fc=s.fc+1; if s.fc>=16 then s.fc=0 end; s.bl=s.fc<8
if not aT then for k=1,3 do s.tk[k].fp=nil end end end,
cs=function(s)
local t=s:X(); local bl=s.bl
for k=1,3 do C(16,k, k==s.W and 15 or 4) end
for x=1,15 do local A=(x==8) and 4 or 2; if x==t.bS then A=bl and 15 or 8 end; C(x,1,A) end
for x=1,16 do local A=(x==1) and 3 or 2; if x==t.vg then A=bl and 15 or 8 end; C(x,7,A) end
for x=1,8 do C(x,6,(x<=t.np) and ((x==t.ep) and (bl and 15 or 9) or ((x==t.pg) and 11 or 4)) or 1) end
C(9,6, t.ti and (bl and 15 or 2) or 5)
C(15,5, bl and 9 or 4); C(15,6, bl and 9 or 4)
C(14,6, bl and 12 or 5)
end,
bI=function(s,x,y,z)
if x==16 and y<=3 then if z==1 then s:X().fp=nil; s.W=y end; return true end
if y==1 and x<=15 then if z==1 then local t=s:X(); t.bS=x; local aj=x-8; local V=aj>=0 and (1+0.5*aj) or 1/(1+0.5*(-aj)); t.cn=b9(1,aM(6/V+0.5)) end; return true end
if y==7 then if z==1 then s.tk[s.W].vg=x end; return true end
if x==15 and y==5 then if z==1 then s:X().aQ=s:X().aQ+1 end; return true end
if x==15 and y==6 then if z==1 then s:X().aQ=s:X().aQ-1 end; return true end
if x==14 and y==6 then if z==1 then local t=s:X(); t.G={}; t.U=1; t.an=16; t.I=1; t.np=1; t.ep=1; t.pg=1 end; return true end
if y==6 and x<=8 then local t=s:X()
if z==1 then
if t.fp==nil then t.fp=x; t.ra=false
elseif t.fp==1 and x>1 then t.np=x; t.ra=true; if t.ep>x then t.ep=x end; if t.pg>x then t.pg=x end end
elseif t.fp==x then
if not t.ra and x<=t.np then t.ep=x end
t.fp=nil; t.ra=false
end
return true end
if x==9 and y==6 then if z==1 then local t=s:X(); t.ti=not t.ti end; return true end
if y>=2 and y<=6 then if z==1 then do local t=s:X(); local aI=t.aQ+(7-y); local i=(t.ep-1)*16+x; if t.G[i]==aI then t.G[i]=nil else t.G[i]=aI end end end; return true end
return false
end,
draw=function(s)
local t=s:X()
local bC=(t.ep-1)*16; local ph=(t.pg==t.ep)
for x=1,s.cX do
local dt=(x>=t.U and x<=t.an)
local vb=5+(vgv(t.vg,x,100)-76)//4
local sv=t.G[bC+x]
local pl=ph and x==t.I
for y=1,7 do
local aI=t.aQ+(7-y); local A=0
if (aI%7==0) then A=2 end
if dt and A==0 then A=1 end
if sv==aI then A=vb end
if pl then local m=(sv==aI) and 15 or 5; if m>A then A=m end end
C(x,y,A)
end
local l8=2
if x==t.U or x==t.an then l8=8 elseif x>t.U and x<t.an then l8=4 end
if x==t.I then l8=b9(l8,11) end
C(x,8,l8)
end
end,
bi=function(s,x,y,z)
local t=s:X()
if y==8 then
if z==1 then
if t.bs==nil then t.bs=x
else t.b7=x; local a,b=t.bs,t.b7; if a>b then a,b=b,a end
t.U=a; t.an=b; if t.I<a or t.I>b then t.I=a end
end
else
if t.b7~=nil then t.bs=nil; t.b7=nil elseif t.bs==x then t.bs=nil end
end
return
end
if z==1 and x>=1 and x<=s.cX and y>=1 and y<=7 then do local t=s:X(); local aI=t.aQ+(7-y); local i=(t.ep-1)*16+x; if t.G[i]==aI then t.G[i]=nil else t.G[i]=aI end end end
end
}
SC={cj=false,W=nil,bD=nil,a9=nil,b6=nil,cq=false,bZ=false,cc=0,aC=127,aU=32,cD=1,bH=false,mt=0,aq={},da={},dv={},
q=nil,qs=0,aZ=0,bU=8,cG=false,
dz=function()
local B=SC.da; for i=#B,1,-1 do B[i]=nil end; local n=0; local sf=string.format
local function w(v) if v<0 then v=0 elseif v>255 then v=255 end; n=n+1; B[n]=sf("%02x",v&255) end
local p1,p2,p3,p4=u[1],u[2],u[3],u[4]
w(5)
w(p1.bk); w(p1.V); w(p1.bo)
for i=1,40 do w(aM((p1.ft[i] or 0)+0.5)) end
for y=1,6 do local m=0; for x=1,16 do if p2.G[y][x] then m=m|(1<<(x-1)) end end; w(m&255); w((m>>8)&255) end
for y=1,6 do w(p2.Z[y]) end
for y=1,6 do w(p2.vg[y]) end
local mm=0; for y=1,6 do if p2.aa[y] then mm=mm|(1<<(y-1)) end end; w(mm); w(p2.cp); w(p2.aX)
w(p3.ac);w(p3.by);w(p3.J);w(p3.M);w(p3.ba);w(p3.bb);w(p3.aP)
w(p3.a6+1);w(p3.ah+8);w(p3.L);w(p3.ao);w(p3.aL and 1 or 0);w(p3.bg);w(p3.aY and 1 or 0);w(p3.ab and 1 or 0)
w(p3.E and p3.E.x or 0); w(p3.E and p3.E.y or 0)
for i=1,8 do
w(p3.N[i] or 0);w(p3.aF[i] or 1);w(p3.aW[i] and 1 or 0);w(p3.ay[i] or 1)
w(p3.ax[i] or 1);w(p3.aD[i] or 1);w(p3.aE[i] or 1);w(p3.aR[i] or 1);w(p3.a2[i] or 1)
w(p3.aG[i] or 1)
local F=p3.af[i]; for j=1,6 do w(F and F[j] or 0) end
end
for k=1,3 do local t=p4.tk[k]
for x=1,16 do local d=t.G[x]; w(d==nil and 255 or (d+100)) end
w(t.U);w(t.an);w(t.aQ+100);w(t.aa and 1 or 0);w(t.bz);w(t.vg);w(t.bS)
end
for k=1,3 do local t=p4.tk[k]
local np=t.np or 1; if np<1 then np=1 elseif np>8 then np=8 end
w(np)
for p=2,np do local b=(p-1)*16; for x=1,16 do local d=t.G[b+x]; w(d==nil and 255 or (d+100)) end end
end
local tm=0; for k=1,3 do if p4.tk[k].ti then tm=tm|(1<<(k-1)) end end; w(tm)
w(p3.sw)
return {table.concat(B)}
end,
unpack=function(P)
local s=P and P[1]; if type(s)~="string" then return false end
if #s<570 then return false end
local ci=-1; local function r() ci=ci+2; return tonumber(s:sub(ci,ci+1),16) or 0 end
local function c(v,a,b) if v<a then return a elseif v>b then return b end return v end
local c3=r(); if c3<4 then return false end
local p1,p2,p3,p4=u[1],u[2],u[3],u[4]
p1.bk=c(r(),1,p1.cb); p1.V=c(r(),1,8); p1.bo=c(r(),1,8)
for i=1,40 do p1.ft[i]=r(); p1.fs[i]=p1.fv[i]; p1.fr[i]=0 end; p1.ez=true
for y=1,6 do local lo=r(); local hi=r(); local m=lo|(hi<<8); for x=1,16 do p2.G[y][x]=(m&(1<<(x-1)))~=0 end end
for y=1,6 do p2.Z[y]=c(r(),1,16) end
for y=1,6 do p2.vg[y]=c(r(),1,16) end
local mm=r(); for y=1,6 do p2.aa[y]=(mm&(1<<(y-1)))~=0 end; p2.cp=c(r(),1,16); p2.aX=c(r(),1,6)
for y=1,6 do if p2.O[y]>p2.Z[y] then p2.O[y]=1 end end; p2:cx()
p3.ac=c(r(),1,15);p3.by=c(r(),1,8);p3.J=c(r(),1,4);p3.M=c(r(),1,4);p3.ba=c(r(),1,4);p3.bb=c(r(),1,16);p3.aP=c(r(),1,16)
p3.a6=c(r(),0,2)-1; p3.ah=c(r(),2,14)-8; p3.L=c(r(),1,3); p3.ao=c(r(),0,127); p3.aL=(r()==1); p3.bg=c(r(),1,8); p3.aY=(r()==1); p3.ab=(r()==1)
local lx=r(); local ly=r(); if lx>0 and lx<=4 and ly>=1 and ly<=6 then p3.E={x=lx,y=ly} else p3.E=nil end
for i=1,8 do local v=r(); if v==0 then p3.N[i]=nil else p3.N[i]=v end
p3.aF[i]=c(r(),1,15); p3.aW[i]=(r()==1); p3.ay[i]=c(r(),1,4); p3.ax[i]=c(r(),1,4); p3.aD[i]=c(r(),1,4); p3.aE[i]=c(r(),1,16); p3.aR[i]=c(r(),1,16); p3.a2[i]=c(r(),1,4)
p3.aG[i]=c(r(),1,3)
local F=nil; for j=1,6 do local nn=r(); if nn>0 then if not F then F={} end; F[#F+1]=nn end end; p3.af[i]=F
end
for k=1,3 do local t=p4.tk[k]
t.G={}; t.np=1; t.ep=1; t.pg=1; t.ti=false
for x=1,16 do local d=r(); if d~=255 then t.G[x]=d-100 end end
t.U=c(r(),1,16); t.an=c(r(),1,16); t.aQ=r()-100; t.aa=(r()==1); t.bz=c(r(),1,8); t.vg=c(r(),1,16); t.bS=c(r(),1,15)
if t.an<t.U then t.an=t.U end
local aj=t.bS-8; local ml=aj>=0 and (1+0.5*aj) or 1/(1+0.5*(-aj)); t.cn=b9(1,aM(6/ml+0.5))
if t.I<t.U or t.I>t.an then t.I=t.U end
end
p3.bV=(p3.bg-5)*p1.V
for k=1,3 do p4.tk[k].cg=(p4.tk[k].bz-5)*p1.V end
p4.bp=(p1.bo-5)*p1.V
p3.sw=0
if c3>=5 then
for k=1,3 do local t=p4.tk[k]
local np=c(r(),1,8); t.np=np
for p=2,np do local b=(p-1)*16; for x=1,16 do local d=r(); if d~=255 then t.G[b+x]=d-100 end end end
end
local tm=r(); for k=1,3 do p4.tk[k].ti=(tm&(1<<(k-1)))~=0 end
p3.sw=c(r(),0,3)
end
return true
end,
dE=function()
u[3]:aK(); u[3]:am(); for k=1,3 do u[4]:b4(k) end
local p2=u[2]; for y=1,6 do if p2.bu[y] then aB(p2.bu[y],0,p2.ch); p2.bu[y]=nil; p2.bJ[y]=nil end end
end,
dI=function(au)
local B=SC.dv; for i=#B,1,-1 do B[i]=nil end
local sf=string.format; B[1]="05"
for b=0,15 do local v=0
for k=0,7 do local i=b*8+k+1; if i<=SC.aC and SC.aq[i] then v=v|(1<<k) end end
B[#B+1]=sf("%02x",v)
end
aN(pset_write,SC.cD,{table.concat(B)})
end,
cF=function(au,ae)
bh()
local ok,B=aN(pset_read,ae+1); if not ok or not B then return end
SC.cq=true
SC.dE(); aN(SC.unpack,B); SC.bD=ae; B=nil
if SC.bZ and u[3].ab then aN(u[3].bj,u[3]) end
SC.cq=false
if SC.bH then SC.mt=8 end; bh()
end,
dB=function(au,ae)
bh()
local ok,P=aN(SC.dz); if not ok then return end
if aN(pset_write,ae+1,P) then
SC.aq[ae]=true; SC.bD=ae; SC.bH=true; SC.mt=8
end
bh()
end,
dh=function(au,ae) aN(pset_delete,ae+1); SC.aq[ae]=false; if SC.bD==ae then SC.bD=nil end; SC.bH=true; SC.mt=8; bh() end,
vs=function(k) return type(k)=="number" and k>=1 and k<=SC.aC end,
cz=function(op,ae)
if SC.q or not SC.vs(ae) then return end
SC.q=op; SC.qs=ae
end,
dD=function(au)
if SC.aZ>0 then SC.aZ=SC.aZ-1; return end
if not SC.cG then
SC.cG=true
aN(pset_init,"gridcomp"); aN(SC.dC,SC)
SC.aZ=SC.bU; return true
end
if SC.b6 then local s=SC.b6; SC.b6=nil
if SC.vs(s) then SC:cF(s) end; SC.mt=8; SC.aZ=SC.bU; return true end
local o=SC.q
if o then local s=SC.qs; SC.q=nil
if SC.vs(s) then
if o==1 then SC:dB(s) elseif o==2 then SC:cF(s) else SC:dh(s) end
end
SC.aZ=SC.bU; return true
end
if SC.bH then SC.mt=SC.mt-1
if SC.mt<=0 then SC.bH=false; SC:dI(); SC.aZ=SC.bU; bh(); return true end
end
end,
dC=function(au)
local ok,m=aN(pset_read,SC.cD)
for i=1,SC.aC do SC.aq[i]=false end
if ok and type(m)=="table" then
local h=m[1]
if type(h)=="string" and #h>=34 then
for i=1,SC.aC do
local b=(i-1)//8; local k=(i-1)%8
local v=tonumber(h:sub(3+b*2,4+b*2),16) or 0
SC.aq[i]=((v>>k)&1)==1
end
elseif h==4 then
for i=1,SC.aC do SC.aq[i]=(m[i+1]==1) end
end
end
m=nil; bh()
end,
dl=function(au) local i=SC.W; if not i or not SC.aq[i] then return end; if SC.bZ then SC.a9=i else SC.cz(2,i); SC.a9=nil end end,
dm=function(au) local i=SC.W; if i then SC.cz(1,i) end end,
dk=function(au) local i=SC.W; if i and SC.aq[i] then SC.cz(3,i); SC.W=nil end end,
dn=function(au,p1)
local bl=p1.bl; local bC=SC.cc*SC.aU
for li=1,SC.aU do local i=bC+li; local x=((li-1)%8)+1; local y=((li-1)//8)+1
local A=(i<=SC.aC) and (SC.aq[i] and 6 or 2) or 0
if SC.bD==i then A=11 end
if SC.a9==i or (SC.q and SC.qs==i) then A=bl and 15 or 1 elseif SC.W==i then A=bl and 15 or 4 end
C(x,y,A)
end
for y=5,7 do for x=1,8 do C(x,y,0) end end
for p=0,((SC.aC+SC.aU-1)//SC.aU)-1 do C(p+1,6, p==SC.cc and 15 or 3) end
end,
dp=function(au,p1)
C(1,8,15); C(2,8,0)
local a=SC.W
C(3,8,(a and SC.aq[a]) and (SC.a9 and (p1.bl and 15 or 3) or 12) or 3)
C(4,8, a and 12 or 3)
C(5,8,(a and SC.aq[a]) and 12 or 3)
C(6,8,0)
C(7,8,0); C(8,8,0)
end,
bi=function(au,x,y,z)
if z~=1 then return true end
if y==8 then
if x==1 then SC.cj=false; SC.W=nil
elseif x==3 then SC:dl()
elseif x==4 then SC:dm()
elseif x==5 then SC:dk() end
return true
end
if y==6 and x>=1 and x<=((SC.aC+SC.aU-1)//SC.aU) then SC.cc=x-1; return true end
if y>=1 and y<=4 then local i=SC.cc*SC.aU+((y-1)*8+x); if i>=1 and i<=SC.aC then SC.W=(SC.W==i) and nil or i end end
return true
end
}
for i=1,#u do u[i]:init() end
m_main=metro.init(framework_tick,0.03) m_main:start()