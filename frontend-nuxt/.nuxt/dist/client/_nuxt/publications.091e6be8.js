import{K as F,L as E,J as R,z as x,a as $,s as P,m as U,M as j,B as D,o as u,b as p,e as t,D as f,N as g,u as e,t as c,c as V,p as M,O as H,F as q,C,E as L,G as A,P as O,j as z,f as h,w as N,h as B,v as G,x as J,y as K,l as X,k as Q,q as W,H as Y}from"./entry.fb5008d9.js";import{u as Z,_ as tt}from"./Spinner.2bb35980.js";import{u as et,b as st,a as ot}from"./imported_posts.cacf9b30.js";const nt=s=>Object.fromEntries(Object.entries(s).filter(([,o])=>o!==void 0)),it=(s,o)=>(r,n)=>(E(()=>s({...nt(r),...n.attrs},n)),()=>{var _,d;return o?(d=(_=n.slots).default)==null?void 0:d.call(_):null}),lt={accesskey:String,autocapitalize:String,autofocus:{type:Boolean,default:void 0},class:[String,Object,Array],contenteditable:{type:Boolean,default:void 0},contextmenu:String,dir:String,draggable:{type:Boolean,default:void 0},enterkeyhint:String,exportparts:String,hidden:{type:Boolean,default:void 0},id:String,inputmode:String,is:String,itemid:String,itemprop:String,itemref:String,itemscope:String,itemtype:String,lang:String,nonce:String,part:String,slot:String,spellcheck:{type:Boolean,default:void 0},style:String,tabindex:String,title:String,translate:String},at=F({name:"Meta",inheritAttrs:!1,props:{...lt,charset:String,content:String,httpEquiv:String,name:String,body:Boolean,renderPriority:[String,Number]},setup:it(s=>{const o={...s};return o.httpEquiv&&(o["http-equiv"]=o.httpEquiv,delete o.httpEquiv),{meta:[o]}})}),ct=F({name:"Head",inheritAttrs:!1,setup:(s,o)=>()=>{var r,n;return(n=(r=o.slots).default)==null?void 0:n.call(r)}}),rt=R("publicationTypesStore",()=>{const s=x([]),o=x(null);async function r(n){try{o.value=!0;const{data:_,error:d}=await Z("/api/pubtypes",{params:n},"$4JCIXpvuxF");o.value=!1,s.value=_.value.publication_types}catch{console.log("Something went wrong: fetchPublicationTypes")}}return{publicationTypes:s,fetchPublicationTypes:r,pendingPublicationTypes:o}}),ut={class:"row"},dt={class:"col"},pt={class:"form-check col-auto form-switch mb-3"},_t={class:"form-check-label",for:"needs_attention"},mt={class:"col-auto"},ft={class:"mb-3"},ht={class:"form-check form-check-inline"},bt={class:"form-check-label",for:"scopus"},vt={class:"form-check form-check-inline"},gt={class:"form-check-label",for:"wos"},yt={class:"form-check form-check-inline"},St={class:"form-check-label",for:"manual"},wt=["aria-label"],kt={value:"",selected:""},xt=["value"],Pt={class:"mb-3"},$t={for:"title",class:"form-label visually-hidden"},It=["placeholder"],Tt={__name:"Filters",props:["pendingImportedPosts"],async setup(s){let o,r;const{t:n,getLocale:_}=$(),d=rt(),{fetchPublicationTypes:y}=d,{publicationTypes:b,pendingPublicationTypes:S}=P(d);[o,r]=U(()=>y({lang:_()})),await o,r();const w=et(),{$reset:I}=w,{filters:a}=P(w),m=x(a.value.title),k=st(()=>{a.value.title=m.value},500);return j(()=>{I()}),D(m,()=>{k()}),(T,i)=>{const v=tt;return u(),p("div",null,[t("form",{class:"col",onSubmit:i[6]||(i[6]=O(l=>{},["prevent"])),id:"filters"},[t("div",ut,[t("div",dt,[t("div",pt,[f(t("input",{class:"form-check-input",type:"checkbox",id:"needs_attention","onUpdate:modelValue":i[0]||(i[0]=l=>e(a).needs_attention=l)},null,512),[[g,e(a).needs_attention]]),t("label",_t,c(e(n)("views.publications.form.needs_attention")),1)])]),t("div",mt,[s.pendingImportedPosts?(u(),V(v,{key:0,class:"me-4"})):M("",!0)])]),t("div",ft,[t("div",ht,[f(t("input",{class:"form-check-input",type:"checkbox",id:"scopus","onUpdate:modelValue":i[1]||(i[1]=l=>e(a).scopus=l)},null,512),[[g,e(a).scopus]]),t("label",bt,c(e(n)("views.publications.form.scopus_title")),1)]),t("div",vt,[f(t("input",{class:"form-check-input",type:"checkbox",id:"wos","onUpdate:modelValue":i[2]||(i[2]=l=>e(a).wos=l)},null,512),[[g,e(a).wos]]),t("label",gt,c(e(n)("views.publications.form.wos_title")),1)]),t("div",yt,[f(t("input",{class:"form-check-input",type:"checkbox",id:"manual","onUpdate:modelValue":i[3]||(i[3]=l=>e(a).manual=l)},null,512),[[g,e(a).manual]]),t("label",St,c(e(n)("views.publications.form.manual_title")),1)])]),f(t("select",{class:"form-select mb-3","onUpdate:modelValue":i[4]||(i[4]=l=>e(a).pubtype=l),"aria-label":e(n)("views.publications.form.pub_type_select_label")},[t("option",kt,c(e(n)("views.publications.form.pub_type_select_label")),1),(u(!0),p(q,null,C(e(b),l=>(u(),p("option",{value:l.id,key:l.id},c(l.display_name),9,xt))),128))],8,wt),[[H,e(a).pubtype]]),t("div",Pt,[t("label",$t,c(e(n)("views.publications.form.title_label")),1),f(t("input",{type:"search","onUpdate:modelValue":i[5]||(i[5]=l=>A(m)?m.value=l:null),class:"form-control",id:"title",placeholder:e(n)("views.publications.form.title_label")},null,8,It),[[L,e(m)]])])],32)])}}};const Bt=s=>(J("data-v-a99a7e19"),s=s(),K(),s),Ft={class:"d-flex w-100 justify-content-between"},Ut={class:"title mb-1"},Vt={key:0,class:"text-muted"},Mt={class:"mb-0"},qt=Bt(()=>t("br",null,null,-1)),Ct={__name:"PostRow",props:["post"],setup(s){return $(),(o,r)=>{const n=G;return u(),p("div",null,[h(n,{to:{name:"publications-post-id",query:o.$route.query,params:{id:s.post.id}},class:"list-group-item list-group-item-action"},{default:N(()=>[t("div",Ft,[t("h5",Ut,c(s.post.title),1),s.post.gup_id?(u(),p("small",Vt,"GUP-ID: "+c(s.post.gup_id),1)):M("",!0)]),t("p",Mt,c(s.post.date),1),t("small",null,[B("Pubtype: "+c(s.post.pubtype),1),qt,B(" "+c(s.post.number_of_authors)+" författare",1)])]),_:1},8,["to"])])}}},Nt=z(Ct,[["__scopeId","data-v-a99a7e19"]]);const Et={class:"container-fluid"},Rt={class:"row"},jt={class:"col-4"},Dt={class:"row"},Ht={id:"result-list-by-id",class:"row"},Lt={key:0},At={key:1,class:"list-group list-group-flush border-bottom"},Ot={class:"col"},zt={class:"row"},Xt={__name:"publications",async setup(s){let o,r;const{t:n,getLocale:_}=$();X(),Q();const d=ot(),{fetchImportedPosts:y}=d,{importedPosts:b,pendingImportedPosts:S}=P(d);return[o,r]=U(()=>y()),await o,r(),(w,I)=>{const a=at,m=ct,k=Tt,T=Nt,i=Y;return u(),p("div",null,[h(m,null,{default:N(()=>[t("title",null,c(e(n)("seo.application_title")),1),h(a,{name:"description",content:e(n)("seo.application_title")},null,8,["content"])]),_:1}),t("div",Et,[t("div",Rt,[t("div",jt,[t("div",Dt,[h(k,{pendingImportedPosts:e(S)},null,8,["pendingImportedPosts"])]),t("div",Ht,[t("div",{class:W(["col scroll",{"opacity-50":e(S)}])},[e(b).length?(u(),p("div",At,[(u(!0),p(q,null,C(e(b),v=>(u(),V(T,{post:v,key:v.id},null,8,["post"]))),128))])):(u(),p("div",Lt,c(e(n)("views.publications.result_list.no_imported_posts_found")),1))],2)])]),t("div",Ot,[t("div",zt,[h(i)])])])])])}}};export{Xt as default};