/**
 * Default per-node row used when no `renderResult` is supplied for a source.
 *
 * Layout:
 *   - Title: first entry in `displayFields` (preferring displayValue).
 *   - Subtitle: remaining display fields joined with " · ".
 *   - When `routePattern` is configured on the source, the row is wrapped in
 *     a react-router `<Link>` whose `to` is built by substituting `:fieldName`
 *     tokens with the corresponding field values (special token `:id`
 *     resolves to the configured `idField`, default "Id").
 *
 * Applications can still pass `renderResult[sourceKey]` to override.
 */

import type { ReactNode } from 'react';
import { Link } from 'react-router';
import { readDisplayField, resolveRoute } from '../../utils/resultUtils';
import type { SObjectSourceConfig } from '../../types';

interface DefaultResultRowProps {
  node: unknown;
  source: SObjectSourceConfig;
}

export function DefaultResultRow({ node, source }: DefaultResultRowProps) {
  const idField = source.idField ?? 'Id';
  const fields = source.displayFields;
  const titleField = fields[0];
  const title = titleField ? readDisplayField(node, titleField) : null;

  const subtitleParts = fields
    .slice(1)
    .map(f => readDisplayField(node, f))
    .filter((s): s is string => s != null && s !== '');

  const content: ReactNode = (
    <>
      <span className="font-medium">{title ?? '—'}</span>
      {subtitleParts.length > 0 && (
        <p className="text-sm text-neutral-600 dark:text-neutral-300">
          {subtitleParts.join(' · ')}
        </p>
      )}
    </>
  );

  if (source.routePattern) {
    const href = resolveRoute(source.routePattern, node, idField);
    if (href) {
      return (
        <Link
          to={href}
          className="block hover:bg-accent rounded-md px-3 -mx-3 py-1 transition-colors"
          aria-label={`View: ${title ?? 'result'}`}
        >
          {content}
        </Link>
      );
    }
  }

  return <div className="px-3 -mx-3 py-1">{content}</div>;
}
