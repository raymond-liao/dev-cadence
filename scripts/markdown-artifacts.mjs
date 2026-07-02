export function cleanValue(value) {
  const trimmed = String(value ?? '').trim();
  if (trimmed === '') return '';
  if (trimmed === '[]') return [];
  if (trimmed === 'null') return null;
  if (trimmed === 'true') return true;
  if (trimmed === 'false') return false;
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"'))
    || (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

export function yamlBlocks(text) {
  const blocks = [];
  const pattern = /```ya?ml\n([\s\S]*?)```/g;
  for (const match of text.matchAll(pattern)) {
    blocks.push(match[1]);
  }
  return blocks;
}

export function firstYamlBlock(text) {
  return yamlBlocks(text)[0] || '';
}

export function parseTopLevelYaml(block) {
  const data = {};
  const lines = block.split('\n');
  let currentKey = null;

  for (const line of lines) {
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const keyValue = line.match(/^([A-Za-z0-9_-]+):(?:\s*(.*))?$/);
    if (keyValue) {
      currentKey = keyValue[1];
      const rawValue = keyValue[2] ?? '';
      data[currentKey] = rawValue.trim() === '' ? [] : cleanValue(rawValue);
      continue;
    }

    const listItem = line.match(/^\s+-\s+(.*)$/);
    if (listItem && currentKey) {
      if (!Array.isArray(data[currentKey])) {
        data[currentKey] = [];
      }
      data[currentKey].push(cleanValue(listItem[1]));
    }
  }

  return data;
}

export function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function markdownSection(text, headingPattern) {
  const pattern = new RegExp(`^#{1,6}\\s+${headingPattern}[^\\n]*\\n([\\s\\S]*?)(?=^#{1,6}\\s+|(?![\\s\\S]))`, 'im');
  const match = text.match(pattern);
  return match ? match[1] : '';
}

export function markdownLabel(text, label) {
  const escaped = escapeRegExp(label);
  const pattern = new RegExp(`^\\s*(?:[-*]\\s+)?(?:\\*\\*)?${escaped}(?:\\*\\*)?:\\s*(.*)$`, 'im');
  const match = text.match(pattern);
  return match ? cleanValue(match[1]) : '';
}

export function markdownListAfterLabel(text, label) {
  const escaped = escapeRegExp(label);
  const pattern = new RegExp(`^\\s*(?:[-*]\\s+)?(?:\\*\\*)?${escaped}(?:\\*\\*)?:\\s*(.*)$`, 'i');
  const lines = text.split('\n');
  const startIndex = lines.findIndex((line) => pattern.test(line));
  if (startIndex === -1) return [];

  const values = [];
  const firstValue = lines[startIndex].match(pattern)?.[1]?.trim();
  if (firstValue) {
    const parsed = cleanValue(firstValue);
    return Array.isArray(parsed) ? parsed : [parsed];
  }

  for (let index = startIndex + 1; index < lines.length; index += 1) {
    const trimmed = lines[index].trim();
    if (!trimmed) continue;
    if (trimmed.startsWith('#')) break;
    if (/^(?:[-*]\s+)?(?:\*\*)?[A-Za-z][A-Za-z0-9 /_-]*(?:\*\*)?:/.test(trimmed)) break;
    const listItem = trimmed.match(/^[-*]\s+(.*)$/);
    if (!listItem) break;
    values.push(cleanValue(listItem[1]));
  }

  return values;
}

export function labelToKey(label) {
  return label
    .trim()
    .replace(/\*\*/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function linesOutsideFences(text) {
  const result = [];
  let inFence = false;
  for (const line of text.split('\n')) {
    if (line.trim().startsWith('```')) {
      inFence = !inFence;
      result.push(null);
      continue;
    }
    result.push(inFence ? null : line);
  }
  return result;
}

export function parseMarkdownLabels(text) {
  const data = {};
  const lines = linesOutsideFences(text);
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (line === null) continue;
    const match = line.match(/^\s*(?:[-*]\s+)?(?:\*\*)?([A-Za-z][A-Za-z0-9 /_-]*?)(?:\*\*)?:\s*(.*)$/);
    if (!match) continue;

    const key = labelToKey(match[1]);
    if (!key || Object.hasOwn(data, key)) continue;
    const inlineValue = match[2].trim();
    if (inlineValue) {
      data[key] = cleanValue(inlineValue);
      continue;
    }

    const list = [];
    for (let next = index + 1; next < lines.length; next += 1) {
      const nextLine = lines[next];
      if (nextLine === null) continue;
      const trimmed = nextLine.trim();
      if (!trimmed) continue;
      if (trimmed.startsWith('#')) break;
      if (/^(?:[-*]\s+)?(?:\*\*)?[A-Za-z][A-Za-z0-9 /_-]*(?:\*\*)?:/.test(trimmed)) break;
      const listItem = trimmed.match(/^[-*]\s+(.*)$/);
      if (!listItem) break;
      list.push(cleanValue(listItem[1]));
    }
    data[key] = list;
  }
  return data;
}

export function readArtifactData(text) {
  return {
    ...parseTopLevelYaml(firstYamlBlock(text)),
    ...parseMarkdownLabels(text),
  };
}

export function readGateData(text, gateId) {
  const pattern = new RegExp(`^##\\s+Gate\\s+${gateId}\\b[\\s\\S]*?\`\`\`ya?ml\\n([\\s\\S]*?)\`\`\``, 'im');
  const yamlMatch = text.match(pattern);
  const yaml = parseTopLevelYaml(yamlMatch ? yamlMatch[1] : '');
  const section = markdownSection(text, `Gate\\s+${gateId}\\b`);
  if (!section) return yaml;
  return {
    ...yaml,
    gate_id: gateId,
    ...parseMarkdownLabels(section),
  };
}
