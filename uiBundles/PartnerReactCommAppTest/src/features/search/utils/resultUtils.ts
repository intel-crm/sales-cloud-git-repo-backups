import { fieldValue } from './fieldUtils';
import type { DisplayField } from '../types';

const ROUTE_TOKEN = /:([A-Za-z_][A-Za-z0-9_]*)/g;

function fieldName(field: DisplayField): string {
  return typeof field === 'string' ? field : field.name;
}

export function readPath(node: unknown, path: string): string | null {
  let cursor: unknown = node;
  for (const part of path.split('.')) {
    if (!cursor || typeof cursor !== 'object') return null;
    cursor = (cursor as Record<string, unknown>)[part];
  }
  if (cursor == null) return null;
  if (typeof cursor === 'object') {
    return fieldValue(
      cursor as { value?: unknown; displayValue?: string | null }
    );
  }
  return String(cursor);
}

export function readDisplayField(
  node: unknown,
  field: DisplayField
): string | null {
  if (typeof field === 'string') return readPath(node, field);
  if ('raw' in field) return readPath(node, field.name);
  const sub = field.subfields[0];
  if (!sub) return null;
  return readPath(node, `${field.name}.${fieldName(sub)}`);
}

export function resolveRoute(
  pattern: string,
  node: unknown,
  idField: string
): string | null {
  let failed = false;
  const out = pattern.replace(ROUTE_TOKEN, (_, token: string) => {
    const value = readPath(node, token === 'id' ? idField : token);
    if (value == null) {
      failed = true;
      return '';
    }
    return encodeURIComponent(value);
  });
  return failed ? null : out;
}

export function getNodeKey(
  node: unknown,
  idField: string | undefined,
  fallback: number
): string | number {
  if (node && typeof node === 'object') {
    const id = (node as Record<string, unknown>)[idField ?? 'Id'];
    if (typeof id === 'string' || typeof id === 'number') return id;
  }
  return fallback;
}
