import{u as h,_ as y,a as B}from"./gup_posts.f706b10c.js";import{_ as P}from"./Spinner.2bb35980.js";import{a as g,k,l as v,s as I,m as w,o as t,b as e,u as s,c as x,e as o,t as G,f as i,p as S}from"./entry.fb5008d9.js";const b={key:1},N={class:"row"},R={class:"col"},V={class:"pb-0 mb-4"},C={key:0,class:"col-auto"},D={class:"row"},E={class:"col"},z={__name:"[gupid]",async setup($){let a,c;g(),k();const p=v(),n=h(),{fetchGupPostById:u}=n,{gupPostById:r,pendingGupPostById:d,errorGupPostById:_}=I(n);return[a,c]=w(()=>u(p.params.gupid)),await a,c(),(A,L)=>{const l=y,m=P,f=B;return t(),e("div",null,[s(_)?(t(),x(l,{key:0,error:s(_)},null,8,["error"])):(t(),e("div",b,[o("div",N,[o("div",R,[o("h2",V,G(s(r).title),1)]),s(d)?(t(),e("div",C,[i(m,{class:"me-4"})])):S("",!0)]),o("div",D,[o("div",E,[i(f,{post:s(r)},null,8,["post"])])])]))])}}};export{z as default};