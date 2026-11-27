import { ArrowDown, ArrowUp, ArrowUpDown } from 'lucide-react';
import { Link } from 'react-router';
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../../../components/ui/table';
import type { DisplayField, SObjectSourceConfig } from '../../types';
import type { SortState } from '../../utils/sortUtils';
import { getNodeKey, readPath, resolveRoute } from '../../utils/resultUtils';

function columnPaths(fields: DisplayField[], prefix = ''): string[] {
  return fields.flatMap(field => {
    const path = `${prefix}${typeof field === 'string' ? field : field.name}`;
    return typeof field !== 'string' && 'subfields' in field
      ? columnPaths(field.subfields, `${path}.`)
      : [path];
  });
}

function columnLabel(path: string, source: SObjectSourceConfig): string {
  if (path === 'Name')
    return `${source.labelSingular ?? source.objectName} Name`;
  const configured =
    source.filterBy?.find(field => field.field === path) ??
    source.sortBy?.find(field => field.field === path);
  return (
    configured?.label ??
    path
      .replace(/__c\b/g, '')
      .replace(/[._]/g, ' ')
      .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
  );
}

interface SObjectResultsTableProps {
  source: SObjectSourceConfig;
  nodes: unknown[];
  sort: SortState | null;
  onSortChange: (sort: SortState | null) => void;
}

export function SObjectResultsTable({
  source,
  nodes,
  sort,
  onSortChange,
}: SObjectResultsTableProps) {
  const columns = columnPaths(source.displayFields);
  return (
    <Table
      aria-label={`${source.label} search results`}
      className="min-w-[640px]"
    >
      <TableCaption className="sr-only">
        {source.label} search results
      </TableCaption>
      <TableHeader className="bg-slate-100">
        <TableRow>
          {columns.map(path => {
            const label = columnLabel(path, source);
            const sortable = source.sortBy?.some(field => field.field === path);
            const active = sort?.field === path;
            const direction =
              active && sort.direction === 'ASC' ? 'DESC' : 'ASC';
            return (
              <TableHead
                key={path}
                scope="col"
                aria-sort={
                  sortable
                    ? active
                      ? sort.direction === 'ASC'
                        ? 'ascending'
                        : 'descending'
                      : 'none'
                    : undefined
                }
                className="border-r px-4 py-3 font-semibold last:border-r-0"
              >
                {sortable ? (
                  <button
                    type="button"
                    onClick={() => onSortChange({ field: path, direction })}
                    aria-label={`Sort ${label} ${direction === 'ASC' ? 'ascending' : 'descending'}`}
                    className="flex w-full items-center justify-between gap-4 rounded-sm text-left focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-sky-700"
                  >
                    {label}
                    {active ? (
                      sort.direction === 'ASC' ? (
                        <ArrowUp
                          aria-hidden="true"
                          className="size-4 shrink-0"
                        />
                      ) : (
                        <ArrowDown
                          aria-hidden="true"
                          className="size-4 shrink-0"
                        />
                      )
                    ) : (
                      <ArrowUpDown
                        aria-hidden="true"
                        className="size-4 shrink-0 text-slate-500"
                      />
                    )}
                  </button>
                ) : (
                  label
                )}
              </TableHead>
            );
          })}
        </TableRow>
      </TableHeader>
      <TableBody>
        {nodes.map((node, index) => {
          const href = source.routePattern
            ? resolveRoute(source.routePattern, node, source.idField ?? 'Id')
            : null;
          return (
            <TableRow key={getNodeKey(node, source.idField, index)}>
              {columns.map((path, columnIndex) => {
                const value = readPath(node, path) ?? '—';
                return (
                  <TableCell
                    key={path}
                    className="max-w-sm whitespace-normal break-words px-4 py-4 align-top"
                  >
                    {columnIndex === 0 && href ? (
                      <Link
                        to={href}
                        className="rounded-sm font-medium text-sky-700 hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-sky-700"
                      >
                        {value}
                      </Link>
                    ) : (
                      value
                    )}
                  </TableCell>
                );
              })}
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}
