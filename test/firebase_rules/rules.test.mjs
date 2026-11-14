import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp } from 'firebase/firestore';

// Explicitly local emulator namespace. This is not a production Firebase project.
const projectId = 'demo-nutrition-ai';
let environment;
before(async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, 'Run via firebase emulators:exec');
  environment = await initializeTestEnvironment({
    projectId,
    firestore: { rules: await readFile(new URL('../../firebase/firestore.rules', import.meta.url), 'utf8') },
  });
});
beforeEach(async () => { await environment.clearFirestore(); });
after(async () => { await environment?.cleanup(); });
const profile = uid => ({ uid, name: 'Mona', email: `${uid}@example.com`, photoPath: null,
  dailyGoals: { calories: 2000, proteinG: 120, carbsG: 220, fatG: 65 },
  createdAt: serverTimestamp(), updatedAt: serverTimestamp() });
const db = uid => environment.authenticatedContext(uid).firestore();
const userDoc = (database, uid) => doc(database, 'users', uid);
const meal = () => ({ name: 'Lunch', mealType: 'lunch', consumedAt: Timestamp.now(), localDayKey: '2026-11-15',
 servingGrams: 100, caloriesKcal: 220, proteinG: 31, carbsG: 0, fatG: 3.6,
 createdAt: serverTimestamp(), updatedAt: serverTimestamp() });

test('owner can create/read profile; signed-out and another account are denied', async () => {
  await assertSucceeds(setDoc(userDoc(db('a'), 'a'), profile('a')));
  await assertSucceeds(getDoc(userDoc(db('a'), 'a')));
  await assertFails(getDoc(userDoc(db('b'), 'a')));
  await assertFails(getDoc(userDoc(environment.unauthenticatedContext().firestore(), 'a')));
  await assertFails(setDoc(userDoc(db('b'), 'a'), profile('a')));
});
test('goal/name updates preserve immutable identity and timestamps', async () => {
  const ref = userDoc(db('a'), 'a');
  await setDoc(ref, profile('a'));
  await assertSucceeds(updateDoc(ref, {name: 'Mona Updated', dailyGoals: {calories: 2300, proteinG: 140, carbsG: 240, fatG: 70}, updatedAt: serverTimestamp()}));
  await assertFails(updateDoc(ref, {uid: 'b', updatedAt: serverTimestamp()}));
  await assertFails(updateDoc(ref, {email: 'other@example.com', updatedAt: serverTimestamp()}));
  await assertFails(updateDoc(ref, {createdAt: Timestamp.fromMillis(1), updatedAt: serverTimestamp()}));
  await assertFails(updateDoc(ref, {unexpected: true, updatedAt: serverTimestamp()}));
});
test('invalid goals, extra profile fields and arbitrary avatar paths are denied', async () => {
  for (const data of [
    {...profile('a'), dailyGoals: {calories: -1, proteinG: 1, carbsG: 1, fatG: 1}},
    {...profile('a'), dailyGoals: {calories: 2000, proteinG: -1, carbsG: 1, fatG: 1}},
    {...profile('a'), extra: true},
    {...profile('a'), photoPath: 'users/b/avatar/profile.jpg'},
  ]) await assertFails(setDoc(userDoc(db('a'), 'a'), data));
});
test('owner meal CRUD is permitted; other account reads/writes are denied', async () => {
  const ref = doc(db('a'), 'users/a/meals/lunch');
  await assertSucceeds(setDoc(ref, meal()));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(updateDoc(ref, {caloriesKcal: 300, updatedAt: serverTimestamp()}));
  const other = doc(db('b'), 'users/a/meals/lunch');
  await assertFails(getDoc(other));
  await assertFails(updateDoc(other, {caloriesKcal: 500, updatedAt: serverTimestamp()}));
  await assertFails(deleteDoc(other));
  await assertSucceeds(deleteDoc(ref));
});
test('negative meal nutrients, invalid day keys/types and unknown fields are denied', async () => {
  const ref = doc(db('a'), 'users/a/meals/lunch');
  for (const overrides of [
    {caloriesKcal: -1}, {proteinG: -1}, {servingGrams: 0}, {localDayKey: 'today'},
    {mealType: 'exercise'}, {extra: 'not allowed'},
  ]) await assertFails(setDoc(ref, {...meal(), ...overrides}));
});
