local u=pages local C=grid_led local ak=menu_active local ar=midi_note_off local aA=current_page local aG=pcall local aZ=ipairs local a4=math.floor local a5=midi_note_on local be=collectgarbage local cX=math.max local dC=pairs
aA=1; ak=false; u={}; aO=nil; aD=nil
function draw()
grid_led_all(0)
if u[aA] and u[aA].draw then u[aA]:draw() end
if ak then
for p=1,16 do C(p,8, p==aA and 15 or (u[p] and 4 or 0)) end
local pg=u[aA]; if pg.cr then pg:cr() end
for b=1,4 do C(7+b,8, b==aD and 15 or 7) end
if aD then u[1]:fd(aD,7) end
end
C(16,8,ak and 15 or 6)
grid_refresh()
end
event_grid=function(x,y,z)
if x==16 and y==8 then
if z==1 then ak=not ak; if ak then aO=0 else aO=nil end
elseif aO then if aO>=6 then ak=false end; aO=nil end
if not ak then aD=nil end
return
end
if ak then
local pg=u[aA]
if aD and x>=9 and y<=7 then
if z==1 then u[1]:cR(aD,x,y,7) end; return
end
if pg.bF and pg:bF(x,y,z) then return end
if y==8 and z==1 and x>=8 and x<=11 then aD=(aD==x-7) and nil or (x-7); return end
if y==8 and z==1 and u[x] then aA=x; ak=false; aD=nil end return
end
if u[aA] then u[aA]:bf(x,y,z) end
end
local aL=0; local a9=0; local aM=0
function event_midi(d1,d2,d3)
if d1==248 then
if SC.cp then return end
aL=aL+1; aM=aM+1; SC.bW=true
if u[3] then u[3]:dg() end
if u[4] then u[4]:df() end
if aM>=96 then aM=0; if u[3] then u[3]:db() end
if SC.a6 then SC.b5=SC.a6; SC.a6=nil end end
local s=u[2]
if s then
if s.bb and aM==0 then
s.bu={}; s.ao=nil; s.bb=false; s.ac=1
for r=1,6 do s.N[r]=1 end; s:bB(); aL=0; a9=0; return
end
if s.ao then
a9=a9+1; if a9>=s.cA then
a9=0; s.bC=not s.bC; s.ac=s.ao
for r=1,6 do s.N[r]=((s.ao-1)%s.V[r])+1 end; s:bB()
end
if aL>=6 then aL=0 end
elseif aL>=6 then aL=0; a9=0; s.ac=s.ac+1; if s.ac>s.bs then s.ac=1 end; for y=1,6 do s.N[y]=s.N[y]+1; if s.N[y]>s.V[y] then s.N[y]=1 end end; s:bB() end
end
elseif d1==250 or d1==251 then
aL=1; a9=0; aM=0
if u[2] then u[2].ac=1; for y=1,6 do u[2].N[y]=1 end; u[2]:bB() end
if u[3] then u[3].by=0; u[3].bk=1; u[3].ba=1
if u[3].X then u[3].H=1; u[3]:bg() end
end
if u[4] then local rp=u[4]; for k=1,3 do local t=rp.tk[k]; t.pc=0; t.I=t.R; t.pg=1; rp:cQ(k) end end
elseif d1==252 then
SC.bW=false
if u[3] then u[3]:aE(); u[3]:ai() end
if u[4] then for k=1,3 do u[4]:b2(k) end end
for n=0,127 do for c=1,7 do ar(n,0,c) end end
end
end
local ck=0
function framework_tick()
if aO then aO=aO+1 end
for i=1,#u do if u[i].bQ then u[i]:bQ() end end
if SC:dF() then return end
ck=1-ck; if ck==0 then draw() end
end
function vgv(g,i,bz)
if g<=1 then return bz end
local n=g-1; local p=(i-1)%16; local sh
if n<=4 then local k=(n==1 and 4)or(n==2 and 2)or(n==3 and 8)or 3; sh=(p%k==0) and 1 or 0.15
elseif n<=8 then local m=n-4; local k=(m<=2 and 4)or(m==3 and 2)or 8; local o=(m==1 and 2)or(m==4 and 4)or 1; sh=((p-o)%k==0) and 1 or 0.2
elseif n<=12 then local f=n-8; sh=(math.sin(p/16*f*6.2832)+1)*0.5
else local f=n-12; local a=(p%4==0) and 1 or 0; local b=(math.sin((p+1)/16*f*6.2832)+1)*0.35; sh=(a>b) and a or b end
return a4(76+32*sh+0.5)
end
u[1]={cJ=1,cI=20,FT=0.5,FD=0.03,bh=1,b8=5,
fv={},ft={},fs={},fr={},fl={},aC=0,bl=false,ae=1,bm=5,ez=false,
init=function(s)
for i=1,s.b8*8 do s.fv[i]=0;s.ft[i]=0;s.fs[i]=0;s.fr[i]=s.FT;s.fl[i]=-1 end
for f=1,8 do local i=f; s.fv[i]=102;s.ft[i]=102;s.fs[i]=102;s.fl[i]=102; midi_cc(s.cI+i-1,102,s.cJ) end
end,
bQ=function(s)
s.aC=(s.aC+1)%16; s.bl=(s.aC<8)
if not s.ez then return end
local cE=false
for i=1,s.b8*8 do
if s.fr[i]<s.FT then cE=true
s.fr[i]=s.fr[i]+s.FD
local t=s.fr[i]/s.FT; if t>1 then t=1 end
local e=t*(2-t)
local v=s.fs[i]+(s.ft[i]-s.fs[i])*e; s.fv[i]=v
local iv=a4(v+0.5)
if iv~=s.fl[i] then s.fl[i]=iv; midi_cc(s.cI+i-1,iv,s.cJ) end
end
end
s.ez=cE
end,
cr=function(s) for b=1,5 do C(16,b, b==s.bh and 15 or 4) end end,
fd=function(s,b,h) for f=1,8 do local i=((b-1)*8+f); local l=a4(s.fv[i]/127*(h-1)+0.5)
for y=1,h do C(8+f,y,((h-y)<=l) and 7 or 2) end end end,
cR=function(s,b,x,y,h) local i=((b-1)*8+(x-8))
s.fs[i]=s.fv[i]; s.ft[i]=a4((h-y)/(h-1)*127+0.5); s.fr[i]=0; s.ez=true end,
bF=function(s,x,y,z) if z==1 and x==16 and y<=7 then if y>=1 and y<=s.b8 then s.bh=y end;ak=false;return true end return false end,
draw=function(s)
if SC.cj then SC:dp(s); SC:dq(s) else
local cY=u[2] and u[2].W
for x=1,8 do local A=1
if x<=6 then local m=cY and cY[x]; A=m and(s.bl and 15 or 3)or 6 end
C(x,1,A)
end
for y=2,5 do
local r=y-1; local I,ct
if r==1 then I=(u[3] and u[3].bc) or 5; ct=u[3] and u[3].aS
else local t=u[4] and u[4].tk[r-1]; I=(t and t.bw) or 5; ct=t and t.W end
for x=1,8 do local A
if x==1 then A=ct and(s.bl and 15 or 8)or 3
else A=(x==5) and 4 or 2; if x==I then A=15 end end
C(x,y,A)
end
end
for x=1,8 do C(x,6,(x==s.ae) and 15 or 2) end
for x=1,8 do C(x,7,(x==s.bm) and 15 or((x==5) and 4 or 2)) end
for x=1,8 do C(x,8, x==1 and 8 or 1) end
end
s:fd(s.bh,8)
end,
bf=function(s,x,y,z)
if x>=9 and x<=16 then
if z==1 then s:cR(s.bh,x,y,8) end; return
end
if SC.cj then SC:bf(x,y,z); return end
if y>=2 and y<=5 then
if z~=1 then return end
local r=y-1
if x==1 then
if r==1 then local p=u[3]; if p then p.aS=not p.aS; if p.aS then p:aE();p:ai() end end
else local t=u[4] and u[4].tk[r-1]; if t then t.W=not t.W end end
return
end
if x>=2 and x<=8 then local b9=(x-5)*s.ae
if r==1 then local p=u[3]; if p then p.bc=x; p.bS=b9 end
else local t=u[4] and u[4].tk[r-1]; if t then t.bw=x; t.cg=b9 end end
end
return
end
if z~=1 then return end
if y==8 then if x==1 then SC.cj=true end return end
if y==1 then if x<=6 and u[2] then u[2].W[x]=not u[2].W[x] end return end
if y==6 then s.ae=x
for r=1,4 do
if r==1 then local p=u[3]; if p then p.bS=(p.bc-5)*s.ae end
else local t=u[4] and u[4].tk[r-1]; if t then t.cg=(t.bw-5)*s.ae end end
end
if u[4] then u[4].bn=(s.bm-5)*s.ae end
return
end
if y==7 then s.bm=x; if u[4] then u[4].bn=(x-5)*s.ae end return end
end
}
u[2]={G={},N={},V={},vg={},ac=1,bs=16,bu={},ao=nil,cA=6,bC=false,bb=false,dz={60,61,62,63,64,65},ch=2,bi={},cb=false,W={},aR=1,bt={},bG={},cn=1,
init=function(s) for y=1,6 do s.G[y]={}; for x=1,16 do s.G[y][x]=false end; s.N[y]=1; s.V[y]=16; s.bi[y]=nil; s.vg[y]=1 end; s.aR=1; s.ac=1; s.bs=16; s.bu={}; s.ao=nil; s.cA=6; s.bC=false; s.bb=false end,
cw=function(s) local m=1; for y=1,6 do if s.V[y]>m then m=s.V[y] end end; s.bs=m; if s.ac>s.bs then s.ac=1 end end,
c1=function(s) local b7=99; local cq=0; local c=0; for x=1,15 do if s.bu[x] then c=c+1; if x<b7 then b7=x end; if x>cq then cq=x end end end
if c==0 then s.ao=nil; s.bb=false else s.ao=b7; local sp=cq-b7; s.cA=(sp==0 and 6 or (sp==1 and 12 or (sp==2 and 8 or (sp==3 and 6 or (sp==4 and 4 or 3))))) end end,
bB=function(s) for y=1,6 do if s.G[y][s.N[y]] and not s.W[y] then local nt=s.dz[y];a5(nt,vgv(s.vg[y],s.N[y],100),s.ch);s.bt[y]=nt;s.bG[y]=s.cn end end end,
bQ=function(s) for y=1,6 do local c=s.bG[y]; if c then if c<=1 then ar(s.bt[y],0,s.ch);s.bG[y]=nil;s.bt[y]=nil else s.bG[y]=c-1 end end end end,
bF=function(s,x,y,z)
if z==1 and y>=1 and y<=6 then s.V[y]=16; for i=1,16 do s.G[y][i]=false end; s.N[y]=1; s:cw(); return true end
return false
end,
draw=function(s)
for y=1,6 do local l=s.V[y]; local p=s.N[y]; local bx=(y==s.aR)
for x=1,16 do local A=0
if x<=l then A=s.G[y][x] and 8 or (bx and 3 or 2); if x==1 or x==l then A=cX(A,bx and 6 or 4) end; if x==p then A=13 end end
C(x,y,A)
end
end
for x=1,16 do local A
if x==1 and s.ao~=nil then A=s.bb and 15 or 4
else A=(x==s.vg[s.aR]) and 15 or (x==1 and 3 or 2) end
C(x,7,A)
end
for x=1,15 do local A=0; if x<=s.bs then if s.bu[x] then A=s.bC and 15 or 6 elseif x==s.ac and s.ao==nil then A=11 else A=4 end end; C(x,8,A) end; C(16,8,4)
end,
bf=function(s,x,y,z)
if y==8 then if x==16 then return end; if z==1 and x<=s.bs then s.bu[x]=true; s:c1(); if s.ao==x then s.ac=x; for r=1,6 do s.N[r]=((x-1)%s.V[r])+1 end; s.bC=true; s:bB() end else s.bu[x]=nil; s:c1() end return end
if y==7 then
if z~=1 then return end
if x==1 and s.ao~=nil then s.bb=true; return end
s.vg[s.aR]=x; return
end
if z==1 then if s.bi[y]==nil then s.bi[y]=x; s.cb=false else local st=s.bi[y]; if st==1 and x>1 then s.V[y]=x; s.aR=y; s.cb=true; if s.N[y]>s.V[y] then s.N[y]=1 end; s:cw() end end
else if s.bi[y]==x then if not s.cb then s.G[y][x]=not s.G[y][x] end; s.bi[y]=nil; s.cb=false end end
end
}
u[3]={ch=3,
aV={{64,69,62,67,60,65},{61,66,71,64,69,62},{71,66,61,68,63,70},{68,63,70,65,60,67}},
cc={0,2,4,5,7,9,11},ce={0,2,3,5,7,8,10},
cK={{0},{0,1,4},{0,2,4},{0,3,4},{0,4},{0,2,4,5},{0,2,4,6},{0,2,4,6,8}},
de={{0,4,7,10},{0,4,7,11},{0,3,6},{0,4,8},{0,4,6,10},{0,4,8,10},{0,1,4,7}},
cT={65535,21845,18761,4369,26214,27437,43690,17476,4681,9289,21157,257,4112,43947,28013,34952},
Y=1,bv=5,cs=false,E=nil,aS=false,bS=0,bc=5,
cl={},bp={},aW={},M={},ay={},ax={},aq={},ap={},aw={},aK={},aQ={},az={},aa={},
dh={},K={},dk={},ob={},sm={5,4,3,2},
J=1,Q=1,a7=1,a8=1,sw=0,bU=false,aC=0,X=true,
bN=nil,bL=nil,bJ=nil,bM=nil,bK=nil,O=nil,am=nil,
bk=1,ba=1,a1=nil,a2=nil,cU=1,bo=1,
dv={[1]=12,[2]=8,[3]=6,[4]=4},dA={[1]=8,[2]=12,[3]=16,[4]=12},
H=1,by=0,D=nil,b0=nil,bj=0,aI=1,c0=8,pn=8,a0=0,ab=0,
L=1,aF=60,a3=false,bV=false,aX=nil,aN=nil,
b3=false,bq=false,
c9={1,3,2,4,3,5,4,6},
init=function(s)
for y=1,8 do s.aW[y]=1;s.ay[y]=1;s.aq[y]=1;s.ap[y]=1;s.aw[y]=1;s.ax[y]=1;s.aK[y]=1;s.aQ[y]=false;s.az[y]=1;s.aa[y]=nil end
end,
bD=function(s,g,i) local m=s.cT[g] or s.cT[1]; return (m>>(i-1))&1==1 end,
b1=function(s,sp)
local d=s.dv[sp]; local p=aM-1; local t=p//d
if p~=t*d+((t%2==1) and s.sw or 0) then return nil end
return (t%s.dA[sp])+1
end,
c3=function(s)
local r,mn
if s.L>=2 then r=s.aF; mn=s.a3
elseif s.E then r=s:rv(s.E); mn=(s.E.x%2==0)
elseif s.M[s.H] then r=s.M[s.H]; mn=s.aQ[s.H] end
if type(r)~="number" then r=60; mn=false end
r=54+((r-54)%12)
return r,(mn and s.ce or s.cc)
end,
c2=function(s,d)
local r,iv=s:c3()
return r+12*(d//7)+iv[(d%7)+1]
end,
rv=function(s,lr)
if not lr then return nil end
return s.aV[lr.x] and s.aV[lr.x][lr.y]
end,
cN=function(s,dy) local iv=s.a3 and s.ce or s.cc;local bO=dy-s.aF;local cu=bO//12;local b9=bO%12;local b=1;local bd=99;for i=1,7 do local dd=iv[i]-b9;if dd<0 then dd=-dd end;if dd<bd then bd=dd;b=i end end;return cu*7+(b-1) end,
b4=function(s,d) local iv=s.a3 and s.ce or s.cc;return s.aF+12*(d//7)+iv[(d%7)+1] end,
aU=function(s,r,m,mn)
local p=s.dh; for i=#p,1,-1 do p[i]=nil end
if not r or s.aS then return p end
local ko=12*s.a0
local lk=s.L>=2 and s.aF
if m>8 then local rr=r
if lk then rr=s:b4(s:cN(r)) end
for _,i in aZ(s.de[m-8]) do p[#p+1]=rr+i+ko end
elseif lk then local d0=s:cN(r)
for _,cd in aZ(s.cK[m]) do p[#p+1]=s:b4(d0+cd)+ko end
else local iv=mn and s.ce or s.cc
for _,d in aZ(s.cK[m]) do p[#p+1]=r+12*(d//7)+iv[(d%7)+1]+ko end
end
if #p>s.bv then for i=#p,s.bv+1,-1 do p[i]=nil end end
local T=(s.bS or 0)+((u[4] and u[4].bn) or 0)
if T~=0 then
local af=s.dk; for i=#af,1,-1 do af[i]=nil end
for _,n in aZ(p) do
local sr,dH=s:c3()
local bO=n-sr; local cu=bO//12; local pc=bO%12
local bT,bd=99,0
for di=0,6 do local dd=math.abs(dH[di+1]-pc); if dd<bT then bT=dd;bd=di end end
local dw=math.abs(12-pc); if dw<bT then bT=dw;bd=7 end
af[#af+1]=cu*7+bd
end
table.sort(af)
for i=2,#af do if af[i]<=af[i-1] then af[i]=af[i-1]+1 end end
local bH=s.ob; for i=#bH,1,-1 do bH[i]=nil end
for _,d in aZ(af) do local nn=s:c2(d+T); if nn>=0 and nn<=127 then bH[#bH+1]=nn end end
p=bH
end
local iv=s.ab or 0
if iv~=0 and #p>0 then local n=#p
for _=1,(iv>0 and iv or -iv) do
if iv>0 then local mi=1;for j=2,n do if p[j]<p[mi] then mi=j end end;p[mi]=p[mi]+12
else local ma=1;for j=2,n do if p[j]>p[ma] then ma=j end end;p[ma]=p[ma]-12 end
end
end
return p
end,
cS=function(s,r) if r then for x=1,4 do for y=1,6 do if s.aV[x][y]==r then return x,y end end end end end,
c4=function(s,r) if s.az[r]==3 and s.aa[r] then return s.aa[r] end;return s:aU(s.M[r],s.ay[r],s.aQ[r]) end,
cH=function(s,p,d,st,c6)
if #p==0 then return nil end;local l=#p;local pi
if d==1 then pi=p[((st-1)%l)+1] elseif d==2 then pi=p[l-((st-1)%l)]
elseif d==3 then local cy=l*2;local ph=(st-1)%cy;pi=ph<l and p[ph+1] or p[cy-ph]
elseif d==4 then local sq=s.c9;pi=p[((sq[((st-1)%#sq)+1]-1)%l)+1] end
if c6 and st%2==0 and pi then pi=pi+12 end;return pi
end,
aE=function(s) for n in dC(s.cl) do ar(n,0,s.ch);s.cl[n]=nil end;if s.a1 then ar(s.a1,0,s.ch);s.a1=nil end end,
ai=function(s) for n in dC(s.bp) do ar(n,0,s.ch);s.bp[n]=nil end;if s.a2 then ar(s.a2,0,s.ch);s.a2=nil end end,
fl=function(s,p) for _,n in aZ(p) do a5(n,105,s.ch);s.bp[n]=true end end,
GT={4,2},ah=1,
cP=function(s,r) s:aE();local v=vgv(s.aK[r] or s.aI,s.bk,95);for _,n in aZ(s:c4(r)) do a5(n,v,s.ch);s.cl[n]=true end;s.aX=s.GT[s.ah] end,
bg=function(s) s:aE();if not s.X then return end;if (s.aq[s.H] or 1)==1 and (s.ap[s.H] or 1)==1 and s.M[s.H] then s:cP(s.H) end end,
c8=function(s)
if s.O then
local ql=s.O;s.O=nil;s.am=nil;s:ai();s.Y=ql.m
local qt=ql.t
if qt==1 and ql.s==1 then s.aN=nil;s:fl(s.L==3 and s.K or s:aU(ql.rv,ql.m,ql.mn))
elseif qt==2 or qt==3 then s.bo=1 end
elseif s.am then
local qm=s.am;s.am=nil;s.Y=qm;s:ai()
local rv=s:rv(s.E)
if s.J==1 and s.Q==1 then
if rv then s:fl(s:aU(rv,qm,s.E and s.E.x%2==0)) end
elseif s.J==2 or s.J==3 then s.bo=1 end
end
end,
dI=function(s,rv)
local mn=s.E and(s.E.x%2==0)or false
if s.J==1 and s.Q>1 then
local g=s:b1(s.Q)
if g then
s.cU=g;s:ai()
if s:bD(s.a8,g) then local v=vgv(s.aI,g,105);for _,n in aZ((s.L==3 and s.K or s:aU(rv,s.Y,mn))) do a5(n,v,s.ch);s.bp[n]=true end;s.aN=s.GT[s.ah] end
end
elseif s.J==2 or s.J==3 then
local g=s:b1(s.Q)
if g then
s.cU=g
if s:bD(s.a8,g) then
if s.a2 then ar(s.a2,0,s.ch);s.a2=nil end
local p=s:cH((s.L==3 and s.K or s:aU(rv,s.Y,mn)),s.a7,s.bo,s.J==3)
if p then local v=vgv(s.aI,g,105);a5(p,v,s.ch);s.a2=p;s.aN=s.GT[s.ah] end
s.bo=s.bo+1
end
end
end
end,
dg=function(s)
if aM%24==0 then s:c8() end
local rv=s:rv(s.E)
if rv then s:dI(rv) end
if s.X and not s.D and not s.b3 then
local t=s.aq[s.H] or 1;local sp=s.ap[s.H] or 1;local d=s.aw[s.H] or 1
if t==1 and sp>1 then
local g=s:b1(sp)
if g then s.bk=g;s:aE();if s:bD(s.ax[s.H],g) then s:cP(s.H) end end
elseif t==2 or t==3 then
local g=s:b1(sp)
if g then
s.bk=g
if s:bD(s.ax[s.H],g) then
if s.a1 then ar(s.a1,0,s.ch);s.a1=nil end
local p=s:cH(s:c4(s.H),d,s.ba,t==3)
if p then local v=vgv(s.aK[s.H] or s.aI,g,98);a5(p,v,s.ch);s.a1=p;s.aX=s.GT[s.ah] end;s.ba=s.ba+1
end
end
end
end
end,
db=function(s)
local qc=false
if s.bN then s.J=s.bN;s.bN=nil;qc=true end
if s.bL then s.Q=s.bL;s.bL=nil;qc=true end
if s.bJ then s.a7=s.bJ;s.bJ=nil;qc=true end
if s.bM then s.bv=s.bM;s.bM=nil;qc=true end
if s.bK then s.a8=s.bK;s.bK=nil;qc=true end
if qc then s.bo=1 end
if s.bq then
s.bq=false;s.b3=false
s.ba=1;s:bg()
end
if not s.X then return end
s.by=s.by+1
if s.by>=(s.aW[s.H] or 1) then
s.by=0;local le=1;for r=1,8 do if s.M[r] then le=r end end
s.H=(s.H%le)+1;s.ba=1;s:bg()
end
end,
bQ=function(s)
s.aC=(s.aC+1)%48;s.bU=(s.aC%16<8)
local ts=s.aC/48; local dJ=ts<0.5 and ts*2 or 2-ts*2; s.c0=8+a4(dJ*7+0.5)
local tn=(s.aC%10)/10; local cB=tn<0.5 and tn*2 or 2-tn*2; local en=cB*cB*(3-2*cB); s.pn=5+a4(en*10+0.5)
if s.b0 then s.bj=s.bj+1;if s.bj>14 then s.b0=nil;s.bj=0 end end
if s.aX then if s.aX<=1 then s:aE();s.aX=nil else s.aX=s.aX-1 end end
if s.aN then if s.aN<=1 then s:ai();s.aN=nil else s.aN=s.aN-1 end end
end,
draw=function(s)
local tg=s.D or s.H;local dr,ds=s:cS(s.M[tg])
local at=s.D and s.aq[s.D] or (s.bN or s.J)
local aH=s.c0
local cV,cW; if s.L==2 then cV,cW=s:cS(s.aF) end
local bx=(s.D or s.X); local pn=s.pn
for y=1,6 do for x=1,4 do
local A
if s.L==3 then
A=(((x-1)*6+(6-y))%7==0) and (s.bU and 15 or 6) or 5
local gn=s:b4((x-1)*6+(6-y));for i=1,#s.K do if s.K[i]==gn then A=15;break end end
else
A=(x==1 or x==3) and 5 or 3
if bx and dr==x and ds==y and at~=4 then A=pn end
if cV==x and cW==y then A=s.bU and 15 or 4 end
if s.E and y==s.E.y and x==s.E.x then A=15 end
end
C(x,y,A)
end end
local sm=s.sm;local da=s.bM or s.bv
local as=s.D and s.ap[s.D] or(s.bL or s.Q);local ad=s.D and s.aw[s.D] or(s.bJ or s.a7)
for x=5,8 do
local v=x-4
C(x,1,at==v and aH or 0)
C(x,2,as==v and aH or 0)
C(x,3,ad==v and aH or 0)
C(x,4,(sm[x-4]==da) and aH or 0)
end
local ag=s.D and s.ax[s.D] or(s.bK or s.a8)
for y=5,8 do for x=5,8 do local aY=((y-5)*4)+(x-4)
C(x,y, aY==ag and (s:bD(ag,s.bk) and 15 or 7) or 6) end end
local bZ=(s.O and s.O.m) or s.am
local cf=s.Y;local cz=cf<=8 and cf or cf-7
local cO=bZ and(bZ<=8 and bZ or bZ-7)
local av=s.ay[tg];local c7=av and(av<=8 and av or av-7)
for y=7,8 do for x=1,4 do
local mi=((y-7)*4)+x;local A=0
if bx and c7==mi and at~=4 then A=aH end
if mi==cz then A=15 end
if cf>8 and mi==1 and cz~=1 then A=aH end
if cO and mi==cO and mi~=cz then A=aH end
C(x,y,A)
end end
if s.O and s.O.co then local co=s.O.co;C(co.x,co.y,aH) end
for y=1,8 do
local dt=s.M[y]~=nil; local bY=s.aW[y] or 1
for x=9,12 do local bX=x-8; local A
if not dt then A=1 elseif bX<bY then A=3 elseif bX==bY then A=10 else A=2 end
if y==s.H and s.X then if bX==bY then A=aH elseif bX<bY then A=5 end end
if s.b0==y and s.bj%3<2 then A=15 end
C(x,y,A)
end
end
local cM=s.D and s.aK[s.D] or s.aI
for y=1,4 do for x=13,16 do local aY=((y-1)*4)+(x-12); local A
if aY==cM then local cv=vgv(cM,s.bk,100); A=4+a4((cv-76)/32*11+0.5); if A<4 then A=4 elseif A>15 then A=15 end
else A=(aY==1) and 3 or 2 end
C(x,y,A)
end end
C(13,5, s.sw==0 and 15 or 3); C(13,6, s.sw==1 and 15 or 3); C(13,7, s.sw==2 and 15 or 3)
C(14,5, s.L==1 and 15 or 3)
C(14,6, s.L==2 and 15 or (s.bV and 9 or 6))
C(14,7, s.L==3 and 15 or 3)
C(16,5, s.a0==1 and 15 or 3)
C(16,6, s.a0==0 and 12 or 5)
C(16,7, s.a0==-1 and 15 or 3)
C(15,6, 6)
C(15,5, s.ab>0 and math.min(15,6+s.ab*3) or 2)
C(15,7, s.ab<0 and math.min(15,6-s.ab*3) or 2)
C(13,8, s.X and 6 or (s.bU and 15 or 2))
C(14,8, s.ah==1 and 6 or (s.ah==2 and 3 or 15))
end,
bF=function(s,x,y,z)
if z==1 and x>=9 and x<=12 and y>=1 and y<=8 then
s.M[y]=nil;s.aW[y]=1;s.ay[y]=1;s.aq[y]=1;s.ap[y]=1;s.aw[y]=1;s.ax[y]=1;s.az[y]=1;s.aa[y]=nil;return true
end
return false
end,
bf=function(s,x,y,z)
if x>=9 and x<=12 and y<=8 then
if z==1 then
if not s.E then s.D=y; return end
if s.L==3 then
local F=s.aa[y]; if not F then F={};s.aa[y]=F end
for i=#F,1,-1 do F[i]=nil end
for i=1,#s.K do if i<=6 then F[i]=s.K[i] end end
s.az[y]=3; s.M[y]=F[1]
else
local rv=s:rv(s.E)
s.M[y]=rv or s.M[y]; s.az[y]=1; s.aa[y]=nil
if s.E then s.aQ[y]=(s.E.x%2==0) end
s.ay[y]=(s.O and s.O.m) or s.am or s.Y
end
s.aq[y]=s.J;s.ap[y]=s.Q;s.aw[y]=s.a7;s.ax[y]=s.a8;s.aK[y]=s.aI;s.aW[y]=x-8
s.b0=y;s.bj=0;s.D=y
else if s.D==y then s.D=nil;s:bg() end end;return
end
if x>=13 and x<=16 and y<=4 then if z==1 then local aY=((y-1)*4)+(x-12); if s.D then s.aK[s.D]=aY else s.aI=aY end end;return end
if x==13 and y>=5 and y<=7 then if z==1 then s.sw=(y==5 and 0) or (y==6 and 1) or 2 end;return end
if x==16 and y>=5 and y<=7 then if z==1 then s.a0=(y==5 and 1) or (y==6 and 0) or -1 end;return end
if x==15 and y>=5 and y<=7 then if z==1 then if y==6 then s.ab=0 elseif y==5 then s.ab=math.min(6,s.ab+1) else s.ab=cX(-6,s.ab-1) end end;return end
if x==14 and y>=5 and y<=7 then
if z==1 then s:ai();for i=#s.K,1,-1 do s.K[i]=nil end;s.E=nil;s.O=nil
if y==5 then s.L=1 elseif y==6 then s.L=2;s.bV=true else s.L=3 end
else if y==6 then s.bV=false end end
return
end
if x>=5 and x<=8 and y<=4 then
if z==1 then
local v=x-4;local tg=s.D or s.H
if y==4 then v=s.sm[v] end
if s.D then
if y==1 then s.aq[tg]=v;if v==4 then s:aE() end elseif y==2 then s.ap[tg]=v elseif y==3 then s.aw[tg]=v end
else
if y==1 then s.bN=v elseif y==2 then s.bL=v elseif y==3 then s.bJ=v elseif y==4 then s.bM=v end
end
end;return
end
if x>=5 and x<=8 and y>=5 and y<=8 then
if z==1 then local g=((y-5)*4)+(x-4);if s.D then s.ax[s.D]=g else s.bK=g end end;return
end
if x==13 and y==8 then if z==1 then s.X=not s.X;if s.X then s:bg() else s:aE() end end;return end
if x==14 and y==8 then if z==1 then s.ah=(s.ah%3)+1 end;return end
if y>=7 and x<=4 then
local m=((y-7)*4)+x
if z==1 then
local mv=(s.cs and m>1) and (8+(m-1)) or m
if m==1 then s.cs=true end
if s.D then s.ay[s.D]=mv end
if s.J==1 and s.Q==1 then
s.Y=mv;s.am=nil;s:ai()
if s.E then
local rv=s:rv(s.E)
s:fl(s:aU(rv,mv,s.E.x%2==0))
end
elseif s.O then s.O.m=mv;s.am=nil
else s.am=mv end
else
if m==1 then s.cs=false end
end;return
end
if x<=4 and y<=6 then
if s.L==3 then
local n=s:b4((x-1)*6+(6-y))
if s.D then
if z==1 then local st=s.D; local F=s.aa[st]; if not F then F={};s.aa[st]=F end
local f=false; for i=1,#F do if F[i]==n then table.remove(F,i);f=true;break end end
if not f and #F<6 then F[#F+1]=n end
if #F==0 then s.az[st]=1;s.aa[st]=nil;s.M[st]=nil else s.az[st]=3;s.M[st]=F[1] end
end
return
end
if z==1 then
local f=false;for i=1,#s.K do if s.K[i]==n then f=true;break end end
if not f then s.K[#s.K+1]=n end
if not s.E then
s.E={x=x,y=y};s.b3=true;s.bq=false
if s.J==1 and s.Q==1 then s:fl(s.K)
else s.O={rv=n,t=s.J,s=s.Q,m=s.Y,mn=false,co={x=x,y=y}} end
elseif s.J==1 and s.Q==1 and not f then a5(n,105,s.ch);s.bp[n]=true end
else
for i=1,#s.K do if s.K[i]==n then table.remove(s.K,i);break end end
if s.J==1 and s.Q==1 then ar(n,0,s.ch);s.bp[n]=nil end
if #s.K==0 then s.E=nil;s.O=nil;s:ai();s.bq=true end
end
return
end
if z==1 then
if s.bV then s.aF=s.aV[x] and s.aV[x][y];s.a3=(x%2==0);return end
local rv=s.aV[x] and s.aV[x][y]
if rv then
if s.L==1 then s.aF=rv;s.a3=(x%2==0) end
if s.D then s.M[s.D]=rv;s.aQ[s.D]=(x%2==0);s.ay[s.D]=s.Y;s.aq[s.D]=s.J;s.ap[s.D]=s.Q;s.aw[s.D]=s.a7 end
s.E={x=x,y=y};s.b3=true;s.bq=false
local pm=s.am or s.Y;s.am=nil
if s.J==1 and s.Q==1 then
s:fl(s:aU(rv,s.Y,x%2==0))
else s.O={rv=rv,t=s.J,s=s.Q,m=pm,mn=(x%2==0),co={x=x,y=y}} end
end
else
if s.E and s.E.x==x and s.E.y==y then
s.E=nil;s.O=nil
s:ai()
s.bq=true
end
end
end
end
}
u[4]={cL=4,cZ=16,S=1,bn=0,fc=0,bl=false,tk={},
cD={96,48,32,24,16,12,8,6,4,3,2,1},
init=function(s)
for k=1,3 do s.tk[k]={G={},R=1,aj=16,I=1,aJ=0,W=false,bw=5,cg=0,vg=1,bP=8,cm=6,pc=0,bI=nil,br=nil,b6=nil,np=1,ep=1,pg=1,fp=nil,ra=false,ti=false} end
s.bn=0; s.fc=0
end,
U=function(s) return s.tk[s.S] end,
b2=function(s,k) local t=s.tk[k]; if t.bI then ar(t.bI,0,(s.cL+k-1)); t.bI=nil end end,
cQ=function(s,k)
local t=s.tk[k]; local n
if not t.W then
local d=t.G[(t.pg-1)*16+t.I]
if d~=nil then local m=u[3]:c2(d + t.cg + s.bn); if m and m>=0 and m<=127 then n=m end end
end
if n and t.ti and t.bI==n then return end
s:b2(k)
if n then a5(n,vgv(t.vg,t.I,100),(s.cL+k-1)); t.bI=n end
end,
df=function(s) for k=1,3 do local t=s.tk[k]; t.pc=t.pc+1; if t.pc>=t.cm then t.pc=0; t.I=t.I+1
if t.I>t.aj or t.I<t.R then t.I=t.R; t.pg=(t.pg>=t.np) and 1 or (t.pg+1); if t.pg==1 then s:b2(k) end end
s:cQ(k) end end end,
bQ=function(s) s.fc=s.fc+1; if s.fc>=16 then s.fc=0 end; s.bl=s.fc<8
if not ak then for k=1,3 do s.tk[k].fp=nil end end end,
cr=function(s)
local t=s:U(); local bl=s.bl
for k=1,3 do C(16,k, k==s.S and 15 or 4) end
for x=1,15 do local A=(x>12 and 0) or ((x==8) and 4 or 2); if x==t.bP then A=bl and 15 or 8 end; C(x,1,A) end
for x=1,16 do local A=(x==1) and 3 or 2; if x==t.vg then A=bl and 15 or 8 end; C(x,7,A) end
for x=1,8 do C(x,6,(x<=t.np) and ((x==t.ep) and (bl and 15 or 9) or ((x==t.pg) and 11 or 4)) or 1) end
C(9,6, t.ti and (bl and 15 or 2) or 5)
C(15,5, bl and 9 or 4); C(15,6, bl and 9 or 4)
C(14,6, bl and 12 or 5)
end,
bF=function(s,x,y,z)
if x==16 and y<=3 then if z==1 then s:U().fp=nil; s.S=y end; return true end
if y==1 and x<=12 then if z==1 then local t=s:U(); t.bP=x; t.cm=s.cD[x] end; return true end
if y==7 then if z==1 then s.tk[s.S].vg=x end; return true end
if x==15 and y==5 then if z==1 then s:U().aJ=s:U().aJ+1 end; return true end
if x==15 and y==6 then if z==1 then s:U().aJ=s:U().aJ-1 end; return true end
if x==14 and y==6 then if z==1 then local t=s:U(); t.G={}; t.R=1; t.aj=16; t.I=1; t.np=1; t.ep=1; t.pg=1 end; return true end
if y==6 and x<=8 then local t=s:U()
if z==1 then
if t.fp==nil then t.fp=x; t.ra=false
elseif t.fp==1 and x>1 then t.np=x; t.ra=true; if t.ep>x then t.ep=x end; if t.pg>x then t.pg=x end end
elseif t.fp==x then
if not t.ra and x<=t.np then t.ep=x end
t.fp=nil; t.ra=false
end
return true end
if x==9 and y==6 then if z==1 then local t=s:U(); t.ti=not t.ti end; return true end
if y>=2 and y<=6 then if z==1 then do local t=s:U(); local aB=t.aJ+(7-y); local i=(t.ep-1)*16+x; if t.G[i]==aB then t.G[i]=nil else t.G[i]=aB end end end; return true end
return false
end,
draw=function(s)
local t=s:U()
local bz=(t.ep-1)*16; local ph=(t.pg==t.ep)
for x=1,s.cZ do
local du=(x>=t.R and x<=t.aj)
local vb=5+(vgv(t.vg,x,100)-76)//4
local sv=t.G[bz+x]
local pl=ph and x==t.I
for y=1,7 do
local aB=t.aJ+(7-y); local A=0
if (aB%7==0) then A=2 end
if du and A==0 then A=1 end
if sv==aB then A=vb end
if pl then local m=(sv==aB) and 15 or 5; if m>A then A=m end end
C(x,y,A)
end
local l8=2
if x==t.R or x==t.aj then l8=8 elseif x>t.R and x<t.aj then l8=4 end
if x==t.I then l8=cX(l8,11) end
C(x,8,l8)
end
end,
bf=function(s,x,y,z)
local t=s:U()
if y==8 then
if z==1 then
if t.br==nil then t.br=x
else t.b6=x; local a,b=t.br,t.b6; if a>b then a,b=b,a end
t.R=a; t.aj=b; if t.I<a or t.I>b then t.I=a end
end
else
if t.b6~=nil then t.br=nil; t.b6=nil elseif t.br==x then t.br=nil end
end
return
end
if z==1 and x>=1 and x<=s.cZ and y>=1 and y<=7 then do local t=s:U(); local aB=t.aJ+(7-y); local i=(t.ep-1)*16+x; if t.G[i]==aB then t.G[i]=nil else t.G[i]=aB end end end
end
}
SC={cj=false,S=nil,bA=nil,a6=nil,b5=nil,cp=false,bW=false,ca=0,au=127,aP=32,cC=1,bE=false,mt=0,al={},dc={},dx={},
q=nil,qs=0,aT=0,bR=8,cG=false,
dB=function()
local B=SC.dc; for i=#B,1,-1 do B[i]=nil end; local n=0; local sf=string.format
local function w(v) if v<0 then v=0 elseif v>255 then v=255 end; n=n+1; B[n]=sf("%02x",v&255) end
local p1,p2,p3,p4=u[1],u[2],u[3],u[4]
w(5)
w(p1.bh); w(p1.ae); w(p1.bm)
for i=1,40 do w(a4((p1.ft[i] or 0)+0.5)) end
for y=1,6 do local m=0; for x=1,16 do if p2.G[y][x] then m=m|(1<<(x-1)) end end; w(m&255); w((m>>8)&255) end
for y=1,6 do w(p2.V[y]) end
for y=1,6 do w(p2.vg[y]) end
local mm=0; for y=1,6 do if p2.W[y] then mm=mm|(1<<(y-1)) end end; w(mm); w(p2.cn); w(p2.aR)
w(p3.Y);w(p3.bv);w(p3.J);w(p3.Q);w(p3.a7);w(p3.a8);w(p3.aI)
w(p3.a0+1);w(p3.ab+8);w(p3.L);w(p3.aF);w(p3.a3 and 1 or 0);w(p3.bc);w(p3.aS and 1 or 0);w(p3.X and 1 or 0)
w(p3.E and p3.E.x or 0); w(p3.E and p3.E.y or 0)
for i=1,8 do
w(p3.M[i] or 0);w(p3.ay[i] or 1);w(p3.aQ[i] and 1 or 0);w(p3.aq[i] or 1)
w(p3.ap[i] or 1);w(p3.aw[i] or 1);w(p3.ax[i] or 1);w(p3.aK[i] or 1);w(p3.aW[i] or 1)
w(p3.az[i] or 1)
local F=p3.aa[i]; for j=1,6 do w(F and F[j] or 0) end
end
for k=1,3 do local t=p4.tk[k]
for x=1,16 do local d=t.G[x]; w(d==nil and 255 or (d+100)) end
w(t.R);w(t.aj);w(t.aJ+100);w(t.W and 1 or 0);w(t.bw);w(t.vg);w(t.bP)
end
for k=1,3 do local t=p4.tk[k]
local np=t.np or 1; if np<1 then np=1 elseif np>8 then np=8 end
w(np)
for p=2,np do local b=(p-1)*16; for x=1,16 do local d=t.G[b+x]; w(d==nil and 255 or (d+100)) end end
end
local tm=0; for k=1,3 do if p4.tk[k].ti then tm=tm|(1<<(k-1)) end end; w(tm)
w(p3.sw)
w(p3.ah)
return {table.concat(B)}
end,
unpack=function(P)
local s=P and P[1]; if type(s)~="string" then return false end
if #s<570 then return false end
local ci=-1; local function r() ci=ci+2; return tonumber(s:sub(ci,ci+1),16) or 0 end
local function c(v,a,b) if v<a then return a elseif v>b then return b end return v end
local c5=r(); if c5<4 then return false end
local p1,p2,p3,p4=u[1],u[2],u[3],u[4]
p1.bh=c(r(),1,p1.b8); p1.ae=c(r(),1,8); p1.bm=c(r(),1,8)
for i=1,40 do p1.ft[i]=r(); p1.fs[i]=p1.fv[i]; p1.fr[i]=0 end; p1.ez=true
for y=1,6 do local lo=r(); local hi=r(); local m=lo|(hi<<8); for x=1,16 do p2.G[y][x]=(m&(1<<(x-1)))~=0 end end
for y=1,6 do p2.V[y]=c(r(),1,16) end
for y=1,6 do p2.vg[y]=c(r(),1,16) end
local mm=r(); for y=1,6 do p2.W[y]=(mm&(1<<(y-1)))~=0 end; p2.cn=c(r(),1,16); p2.aR=c(r(),1,6)
for y=1,6 do if p2.N[y]>p2.V[y] then p2.N[y]=1 end end; p2:cw()
p3.Y=c(r(),1,15);p3.bv=c(r(),1,8);p3.J=c(r(),1,4);p3.Q=c(r(),1,4);p3.a7=c(r(),1,4);p3.a8=c(r(),1,16);p3.aI=c(r(),1,16)
p3.a0=c(r(),0,2)-1; p3.ab=c(r(),2,14)-8; p3.L=c(r(),1,3); p3.aF=c(r(),0,127); p3.a3=(r()==1); p3.bc=c(r(),1,8); p3.aS=(r()==1); p3.X=(r()==1)
local lx=r(); local ly=r(); if lx>0 and lx<=4 and ly>=1 and ly<=6 then p3.E={x=lx,y=ly} else p3.E=nil end
for i=1,8 do local v=r(); if v==0 then p3.M[i]=nil else p3.M[i]=v end
p3.ay[i]=c(r(),1,15); p3.aQ[i]=(r()==1); p3.aq[i]=c(r(),1,4); p3.ap[i]=c(r(),1,4); p3.aw[i]=c(r(),1,4); p3.ax[i]=c(r(),1,16); p3.aK[i]=c(r(),1,16); p3.aW[i]=c(r(),1,4)
p3.az[i]=c(r(),1,3)
local F=nil; for j=1,6 do local nn=r(); if nn>0 then if not F then F={} end; F[#F+1]=nn end end; p3.aa[i]=F
end
for k=1,3 do local t=p4.tk[k]
t.G={}; t.np=1; t.ep=1; t.pg=1; t.ti=false
for x=1,16 do local d=r(); if d~=255 then t.G[x]=d-100 end end
t.R=c(r(),1,16); t.aj=c(r(),1,16); t.aJ=r()-100; t.W=(r()==1); t.bw=c(r(),1,8); t.vg=c(r(),1,16); t.bP=c(r(),1,12)
if t.aj<t.R then t.aj=t.R end
t.cm=p4.cD[t.bP] or 6
if t.I<t.R or t.I>t.aj then t.I=t.R end
end
p3.bS=(p3.bc-5)*p1.ae
for k=1,3 do p4.tk[k].cg=(p4.tk[k].bw-5)*p1.ae end
p4.bn=(p1.bm-5)*p1.ae
p3.sw=0
p3.ah=1
if c5>=5 then
for k=1,3 do local t=p4.tk[k]
local np=c(r(),1,8); t.np=np
for p=2,np do local b=(p-1)*16; for x=1,16 do local d=r(); if d~=255 then t.G[b+x]=d-100 end end end
end
local tm=r(); for k=1,3 do p4.tk[k].ti=(tm&(1<<(k-1)))~=0 end
p3.sw=c(r(),0,3)
p3.ah=c(r(),1,3)
end
return true
end,
dG=function()
u[3]:aE(); u[3]:ai(); for k=1,3 do u[4]:b2(k) end
local p2=u[2]; for y=1,6 do if p2.bt[y] then ar(p2.bt[y],0,p2.ch); p2.bt[y]=nil; p2.bG[y]=nil end end
end,
dK=function(an)
local B=SC.dx; for i=#B,1,-1 do B[i]=nil end
local sf=string.format; B[1]="05"
for b=0,15 do local v=0
for k=0,7 do local i=b*8+k+1; if i<=SC.au and SC.al[i] then v=v|(1<<k) end end
B[#B+1]=sf("%02x",v)
end
aG(pset_write,SC.cC,{table.concat(B)})
end,
cF=function(an,Z)
be()
local ok,B=aG(pset_read,Z+1); if not ok or not B then return end
SC.cp=true
SC.dG(); aG(SC.unpack,B); SC.bA=Z; B=nil
if SC.bW and u[3].X then aG(u[3].bg,u[3]) end
SC.cp=false
if SC.bE then SC.mt=8 end; be()
end,
dD=function(an,Z)
be()
local ok,P=aG(SC.dB); if not ok then return end
if aG(pset_write,Z+1,P) then
SC.al[Z]=true; SC.bA=Z; SC.bE=true; SC.mt=8
end
be()
end,
dj=function(an,Z) aG(pset_delete,Z+1); SC.al[Z]=false; if SC.bA==Z then SC.bA=nil end; SC.bE=true; SC.mt=8; be() end,
vs=function(k) return type(k)=="number" and k>=1 and k<=SC.au end,
cx=function(op,Z)
if SC.q or not SC.vs(Z) then return end
SC.q=op; SC.qs=Z
end,
dF=function(an)
if SC.aT>0 then SC.aT=SC.aT-1; return end
if not SC.cG then
SC.cG=true
aG(pset_init,"gridcomp"); aG(SC.dE,SC)
SC.aT=SC.bR; return true
end
if SC.b5 then local s=SC.b5; SC.b5=nil
if SC.vs(s) then SC:cF(s) end; SC.mt=8; SC.aT=SC.bR; return true end
local o=SC.q
if o then local s=SC.qs; SC.q=nil
if SC.vs(s) then
if o==1 then SC:dD(s) elseif o==2 then SC:cF(s) else SC:dj(s) end
end
SC.aT=SC.bR; return true
end
if SC.bE then SC.mt=SC.mt-1
if SC.mt<=0 then SC.bE=false; SC:dK(); SC.aT=SC.bR; be(); return true end
end
end,
dE=function(an)
local ok,m=aG(pset_read,SC.cC)
for i=1,SC.au do SC.al[i]=false end
if ok and type(m)=="table" then
local h=m[1]
if type(h)=="string" and #h>=34 then
for i=1,SC.au do
local b=(i-1)//8; local k=(i-1)%8
local v=tonumber(h:sub(3+b*2,4+b*2),16) or 0
SC.al[i]=((v>>k)&1)==1
end
elseif h==4 then
for i=1,SC.au do SC.al[i]=(m[i+1]==1) end
end
end
m=nil; be()
end,
dm=function(an) local i=SC.S; if not i or not SC.al[i] then return end; if SC.bW then SC.a6=i else SC.cx(2,i); SC.a6=nil end end,
dn=function(an) local i=SC.S; if i then SC.cx(1,i) end end,
dl=function(an) local i=SC.S; if i and SC.al[i] then SC.cx(3,i); SC.S=nil end end,
dp=function(an,p1)
local bl=p1.bl; local bz=SC.ca*SC.aP
for li=1,SC.aP do local i=bz+li; local x=((li-1)%8)+1; local y=((li-1)//8)+1
local A=(i<=SC.au) and (SC.al[i] and 6 or 2) or 0
if SC.bA==i then A=11 end
if SC.a6==i or (SC.q and SC.qs==i) then A=bl and 15 or 1 elseif SC.S==i then A=bl and 15 or 4 end
C(x,y,A)
end
for y=5,7 do for x=1,8 do C(x,y,0) end end
for p=0,((SC.au+SC.aP-1)//SC.aP)-1 do C(p+1,6, p==SC.ca and 15 or 3) end
end,
dq=function(an,p1)
C(1,8,15); C(2,8,0)
local a=SC.S
C(3,8,(a and SC.al[a]) and (SC.a6 and (p1.bl and 15 or 3) or 12) or 3)
C(4,8, a and 12 or 3)
C(5,8,(a and SC.al[a]) and 12 or 3)
C(6,8,0)
C(7,8,0); C(8,8,0)
end,
bf=function(an,x,y,z)
if z~=1 then return true end
if y==8 then
if x==1 then SC.cj=false; SC.S=nil
elseif x==3 then SC:dm()
elseif x==4 then SC:dn()
elseif x==5 then SC:dl() end
return true
end
if y==6 and x>=1 and x<=((SC.au+SC.aP-1)//SC.aP) then SC.ca=x-1; return true end
if y>=1 and y<=4 then local i=SC.ca*SC.aP+((y-1)*8+x); if i>=1 and i<=SC.au then SC.S=(SC.S==i) and nil or i end end
return true
end
}
for i=1,#u do u[i]:init() end
m_main=metro.init(framework_tick,0.03) m_main:start()