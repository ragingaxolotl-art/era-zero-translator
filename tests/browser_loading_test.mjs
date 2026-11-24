import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const app=fs.readFileSync(new URL('../pages/app.js',import.meta.url),'utf8');
const bootCode=app.match(/^async function boot\(\) \{[\s\S]+?^\}/m)?.[0];assert(bootCode);
const analyzeCode=app.split('\n').find(line=>line.startsWith('async function analyze(){'));assert(analyzeCode);
const data={counts:{atoms:324,compounds:124,senses:607,gaps:0}};
function fixture({search='',draft='',fetch,storageFails=false}={}){
 const nodes=new Map(),rendered=[],errors=[],notices=[],analyses=[];
 const element=id=>{if(!nodes.has(id))nodes.set(id,{disabled:false,hidden:false,value:id==='sourceInput'?draft:'',textContent:'',classList:{add(){},remove(){}},replaceChildren(){this.cleared=true;}});return nodes.get(id);};
 const context=vm.createContext({state:{data:null,documents:null},$:element,document:{querySelector:element},URLSearchParams,
  localStorage:{},location:{search},correctionExample:'correction example',fetch,
  readWordChoices:()=>{if(storageFails)throw Error('Storage unavailable');return ['saved meaning'];},
  loadQueue:()=>{if(storageFails)throw Error('Storage unavailable');return {entries:[]};},emptyQueue:()=>({entries:[]}),approvedLocalSenses:()=>[],
  addSongLine:{refreshArrangement:()=>rendered.push('arrangement')},
  renderRootJump:()=>rendered.push('roots'),renderCatalog:()=>rendered.push('catalog'),renderDocuments:()=>rendered.push('documents'),renderLorePresetPicker:()=>rendered.push('presets'),renderConceptQueue:()=>rendered.push('queue'),
  showError:e=>errors.push(e),toast:m=>notices.push(m),analyze:()=>{assert.equal(vm.runInContext('engineReady',context),true);analyses.push(element('sourceInput').value);}
 });
 vm.runInContext('let engineReady=false,bootInProgress=false;\n'+bootCode,context);
 return {context,element,rendered,errors,notices,analyses,ready:()=>vm.runInContext('engineReady',context)};
}
const response=value=>({ok:true,json:async()=>value});
const pending=[];const slow=fixture({draft:'My unfinished sentence',search:'?text=Other',fetch:url=>new Promise(resolve=>pending.push({url,resolve}))});
const first=slow.context.boot();await slow.context.boot();
assert.equal(pending.length,2,'Duplicate starts must not send another pair of requests');
assert(slow.element('analyzeButton').disabled);assert.equal(slow.ready(),false);assert(slow.element('retryEngine').hidden);
pending.find(r=>r.url.includes('index')).resolve(response(structuredClone(data)));
await Promise.resolve();assert.equal(slow.ready(),false,'Both resources must finish before analysis');
pending.find(r=>r.url.includes('documents')).resolve(response([]));await first;
assert(slow.ready());assert.equal(slow.element('analyzeButton').disabled,false);
assert.equal(slow.element('sourceInput').value,'My unfinished sentence');assert.deepEqual(slow.analyses,[]);
assert.deepEqual(slow.rendered,['arrangement','roots','catalog','documents','presets','queue']);
for(const failed of ['index','documents','json']){
 let failing=true,requests=0;
 const f=fixture({draft:'Keep this sentence',fetch:async url=>{
  requests++;if(failing&&((failed==='json'&&url.includes('index'))||url.includes(failed)))return failed==='json'?{ok:true,json:async()=>{throw Error('Malformed response');}}:{ok:false};
  return response(url.includes('index')?structuredClone(data):[]);
 }});
 await f.context.boot();assert.equal(f.ready(),false);assert(f.element('analyzeButton').disabled);assert.equal(f.element('retryEngine').hidden,false);
 assert.equal(f.errors.length,1);assert.equal(f.element('sourceInput').value,'Keep this sentence');
 failing=false;await f.context.boot();assert(f.ready());assert.equal(f.element('analyzeButton').disabled,false);assert(f.element('retryEngine').hidden);
 assert.equal(f.element('sourceInput').value,'Keep this sentence');assert.equal(requests,4);
}
const shared=fixture({search:'?text=Nora%20saved%20the%20file.',storageFails:true,fetch:async url=>response(url.includes('index')?structuredClone(data):[])});
await shared.context.boot();assert(shared.ready());assert.deepEqual(shared.analyses,['Nora saved the file.']);assert.equal(shared.notices.length,1);
const guardNotices=[];const guard=vm.createContext({toast:s=>guardNotices.push(s)});
vm.runInContext('let engineReady=false;\n'+analyzeCode,guard);
await guard.analyze();assert.equal(guardNotices.length,1,'Direct analysis must stop before touching unloaded data');
const html=fs.readFileSync(new URL('../pages/index.html',import.meta.url),'utf8');
assert(/id="analyzeButton"[^>]* disabled/.test(html));assert(/id="retryEngine"[^>]* hidden/.test(html));assert(html.includes('aria-describedby="serviceStatus"'));
console.log('PASS dictionary/document loading barrier, duplicate starts, HTTP/JSON retry, draft retention, shared-link analysis after readiness, storage fallback and early analysis guard.');
