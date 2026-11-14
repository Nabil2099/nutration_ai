// Explicit opt-in temporary live-data check. Never prints credentials or tokens.
// Run manually; excluded from the emulator test command in package.json.
import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFile} from 'node:fs/promises';
import {initializeApp,deleteApp} from 'firebase/app';
import {getAuth,createUserWithEmailAndPassword,signInWithEmailAndPassword,signOut,deleteUser,updateProfile} from 'firebase/auth';
import {getFirestore,doc,runTransaction,serverTimestamp,getDocFromServer,updateDoc,deleteDoc,terminate} from 'firebase/firestore';
if(process.env.NUTRITION_LIVE_TEST !== 'approved') throw Error('Explicit approval required');
const source=await readFile(new URL('../../lib/firebase_options.dart',import.meta.url),'utf8');
const web=source.split('static const FirebaseOptions web = FirebaseOptions(')[1].split(');')[0];
const config=Object.fromEntries([...web.matchAll(/(\w+): '([^']+)'/g)].map(m=>[m[1],m[2]]));
assert.equal(config.projectId,'nutration-ai-36e01');
const apps=[];
try {
 for(let i=0;i<2;i++) {
  const app=initializeApp(config,'nutrition-live-'+randomUUID());
  const auth=getAuth(app),db=getFirestore(app);
  const record={app,auth,db};apps.push(record);
  const email=`nutrition-test-${randomUUID()}@example.com`,password=randomUUID()+'Aa1!';
  const {user}=await createUserWithEmailAndPassword(auth,email,password);record.user=user;
  const ref=doc(db,'users',user.uid);record.ref=ref;
  await updateProfile(user,{displayName:'Temporary Nutrition Test'});
  const ensure=()=>runTransaction(db,async tx=>{
   const snapshot=await tx.get(ref);
   if(!snapshot.exists()) tx.set(ref,{uid:user.uid,name:'Temporary Nutrition Test',email,photoPath:null,dailyGoals:{calories:2000,proteinG:120,carbsG:220,fatG:65},createdAt:serverTimestamp(),updatedAt:serverTimestamp()});
  });
  await ensure(); const first=(await getDocFromServer(ref)).data();
  assert.equal(first.uid,user.uid); assert.ok(first.createdAt);
  await updateDoc(ref,{dailyGoals:{calories:2300,proteinG:130,carbsG:240,fatG:70},updatedAt:serverTimestamp()});
  await ensure();const second=(await getDocFromServer(ref)).data();
  assert.equal(second.dailyGoals.calories,2300);assert.ok(first.createdAt.isEqual(second.createdAt));
  await signOut(auth);assert.equal(auth.currentUser,null);
  const login=await signInWithEmailAndPassword(auth,email,password);record.user=login.user;
  assert.equal(login.user.uid,user.uid);
  assert.equal((await getDocFromServer(ref)).data().dailyGoals.calories,2300);
  console.log(`Account ${i+1}: signup, identity, server profile, goal preservation, logout and login passed.`);
 }
 assert.notEqual(apps[0].user.uid,apps[1].user.uid);
 console.log('Distinct UID profile paths verified. Access isolation intentionally not claimed.');
} finally {
 for(const r of apps){
  try{if(r.ref) {await deleteDoc(r.ref);assert.equal((await getDocFromServer(r.ref)).exists(),false);}if(r.user) await deleteUser(r.user); console.log('Temporary account and profile cleaned up.');}
  catch(e){console.error('CLEANUP FAILED:',e.code??e.name);process.exitCode=1;}
  await terminate(r.db);await deleteApp(r.app);
 }
}
