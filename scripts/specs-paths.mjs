import fs from 'node:fs';
import path from 'node:path';

export const SPECS_ROOT_DIR = 'specs';
export const RECORDS_DIR = 'records';
export const REPORT_DIR = 'report';

export function defaultRecordsDir(repoDir = process.cwd()) {
  return path.resolve(repoDir, SPECS_ROOT_DIR, RECORDS_DIR);
}

export function defaultReportDir(repoDir = process.cwd()) {
  return path.resolve(repoDir, SPECS_ROOT_DIR, REPORT_DIR);
}

export function resolveDefaultSpecsDir(repoDir = process.cwd()) {
  const specsRoot = path.resolve(repoDir, SPECS_ROOT_DIR);
  const recordsDir = path.join(specsRoot, RECORDS_DIR);

  if (fs.existsSync(recordsDir) || !hasLegacyTaskDirs(specsRoot)) {
    return recordsDir;
  }

  return specsRoot;
}

export function normalizeSpecsDir(specsDir) {
  const resolved = path.resolve(specsDir);
  const recordsDir = path.join(resolved, RECORDS_DIR);
  if (fs.existsSync(recordsDir) && !hasLegacyTaskDirs(resolved)) {
    return recordsDir;
  }
  return resolved;
}

export function defaultReportDirForSpecsDir(specsDir) {
  if (path.basename(specsDir) === RECORDS_DIR) {
    return path.join(path.dirname(specsDir), REPORT_DIR);
  }
  return path.join(specsDir, REPORT_DIR);
}

function hasLegacyTaskDirs(specsRoot) {
  if (!fs.existsSync(specsRoot)) return false;
  return fs.readdirSync(specsRoot, { withFileTypes: true })
    .some((entry) => {
      if (!entry.isDirectory()) return false;
      if ([RECORDS_DIR, REPORT_DIR].includes(entry.name)) return false;
      return fs.existsSync(path.join(specsRoot, entry.name, '00-brief.md'));
    });
}
