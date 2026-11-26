#!/usr/bin/env node
/**
 * Runs on the rented machine. Exit code 0 when every npm package the copied
 * project asks for is already in the image at the same version, so the install
 * can be skipped. Exit code 1 when something is missing or differs (or the
 * project has no lock file), so the caller runs npm install.
 *
 *   node /opt/render-image/same-packages.mjs /work/package-lock.json
 */
import fs from "node:fs";

const read = (f) => JSON.parse(fs.readFileSync(f, "utf8")).packages ?? {};
let want, have;
try { want = read(process.argv[2]); have = read("/opt/render-image/package-lock.json"); }
catch (e) { console.log(`cannot compare packages: ${e.message}`); process.exit(1); }

const differ = Object.keys(want).filter((k) => k && (!have[k] || have[k].version !== want[k].version));
if (differ.length) { console.log(`${differ.length} packages differ from the image, for example ${differ.slice(0, 3).join(", ")}`); process.exit(1); }
console.log("all packages are already in the image");
