import fs from 'node:fs';
import path from 'node:path';

export const SUPPORTED_ARTIFACT_LANGUAGES = new Set(['en', 'zh']);
export const DEFAULT_ARTIFACT_LANGUAGE = 'en';

export function findNearestConfig(startPath) {
  let current = fs.existsSync(startPath) && fs.statSync(startPath).isDirectory()
    ? startPath
    : path.dirname(startPath);

  while (true) {
    const candidate = path.join(current, '.dev-cadence.yaml');
    if (fs.existsSync(candidate)) {
      return candidate;
    }
    const parent = path.dirname(current);
    if (parent === current) {
      return null;
    }
    current = parent;
  }
}

export function parseArtifactLanguage(configPath) {
  if (!configPath || !fs.existsSync(configPath)) return DEFAULT_ARTIFACT_LANGUAGE;
  const text = fs.readFileSync(configPath, 'utf8');
  const lines = text.split(/\r?\n/);
  let inDevCadence = false;
  let devCadenceIndent = -1;

  for (const line of lines) {
    if (!line.trim() || line.trim().startsWith('#')) continue;
    const indent = line.match(/^\s*/)[0].length;
    const keyMatch = line.match(/^(\s*)dev_cadence:\s*(?:#.*)?$/);
    if (keyMatch) {
      inDevCadence = true;
      devCadenceIndent = indent;
      continue;
    }

    if (inDevCadence && indent <= devCadenceIndent) {
      inDevCadence = false;
      devCadenceIndent = -1;
    }

    if (inDevCadence) {
      const languageMatch = line.match(/^\s*artifact_language:\s*([A-Za-z_-]+)\s*(?:#.*)?$/);
      if (languageMatch) {
        return SUPPORTED_ARTIFACT_LANGUAGES.has(languageMatch[1])
          ? languageMatch[1]
          : DEFAULT_ARTIFACT_LANGUAGE;
      }
    }
  }

  return DEFAULT_ARTIFACT_LANGUAGE;
}

export function resolveArtifactLanguage(startPath) {
  const configPath = findNearestConfig(startPath);
  return {
    language: parseArtifactLanguage(configPath),
    configPath,
  };
}
