#!/usr/bin/env node
// Release gate for the user-authored vocabulary path. No acoustic decoding gate.
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..'),pages=path.join(root,'pages'),seen=new Set();
async function visit(file){
 if(seen.has(file))return;seen.add(file);
 if(!file.startsWith(pages+path.sep))throw new Error(`Browser dependency escapes pages: ${file}`);
 const source=await fs.readFile(file,'utf8');
 const pattern=/(?:\bfrom\s*|\bimport\s*\(\s*|\bimport\s*)['"](\.\.?\/[^'"]+)['"]/g;
 for(const match of source.matchAll(pattern)){const relative=match[1].split(/[?#]/)[0];if(/\.(mjs|js)$/.test(relative))await visit(path.resolve(path.dirname(file),relative));}
}
const html=await fs.readFile(path.join(pages,'compound-builder.html'),'utf8'),home=await fs.readFile(path.join(pages,'index.html'),'utf8');
if(!home.includes('href="./compound-builder.html"'))throw new Error('Builder is not linked from translator.');
for(const match of html.matchAll(/(?:src|href)="(\.\/[^"?#]+)(?:[?#][^"]*)?"/g)){
 const file=path.resolve(pages,match[1]);await fs.access(file);if(/\.(mjs|js)$/.test(file))await visit(file);
}
await visit(path.join(pages,'app.js'));
const tests=(await fs.readdir(path.join(root,'tests'))).filter(name=>/^local_.*_test\.mjs$/.test(name)).sort();if(tests.length<15)throw new Error('Local compound test inventory unexpectedly incomplete.');
const results=[];
for(const test of tests){const run=spawnSync(process.execPath,[path.join(root,'tests',test)],{cwd:root,encoding:'utf8',timeout:60000,maxBuffer:4000000});results.push({test,passed:run.status===0,exit_code:run.status,output:(run.stdout||'')+(run.stderr||''),...(run.error?{error:run.error.message}:{})});console.log(`${run.status===0?'PASS':'FAIL'} ${test}`);}
const report={scope:'Local compound release gate: static module availability and targeted Node tests, not live-browser or unrestricted-English proof',checked_modules:seen.size,results,passed:results.every(r=>r.passed)};
await fs.writeFile(path.join(root,'reports/local_compound_release.json'),JSON.stringify(report,null,2)+'\n');
console.log(`${results.filter(r=>r.passed).length}/${results.length} checks passed; ${seen.size} browser modules available.`);if(!report.passed)process.exit(1);
