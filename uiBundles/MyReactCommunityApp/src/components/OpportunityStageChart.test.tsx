import {
  cleanup,
  fireEvent,
  render,
  screen,
  within,
} from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { OpportunityStageChart } from './OpportunityStageChart';
import { fetchOpportunityStageAmounts } from '../api/opportunityStageAmounts';
import OpportunitiesPage from '../pages/Opportunities';
import { MemoryRouter } from 'react-router';

vi.mock('../api/opportunityStageAmounts', () => ({
  fetchOpportunityStageAmounts: vi.fn(),
}));
vi.mock('./OpportunityList', () => ({
  NativeOpportunityList: () => (
    <section aria-label="Opportunity list">Pipeline records</section>
  ),
}));
const fetchTotals = vi.mocked(fetchOpportunityStageAmounts);
const partnerState = vi.hoisted(() => vi.fn());
vi.mock('../features/partner/context/PartnerAccountContext', () => ({
  usePartnerAccount: partnerState,
}));

function renderChart(showPartnerCards = false) {
  return render(
    <MemoryRouter>
      <OpportunityStageChart showPartnerCards={showPartnerCards} />
    </MemoryRouter>
  );
}

function renderPage() {
  return render(
    <MemoryRouter>
      <OpportunitiesPage />
    </MemoryRouter>
  );
}

beforeEach(() => {
  fetchTotals.mockReset();
  partnerState.mockReturnValue({
    account: {
      kind: 'ready',
      accountId: 'account-1',
      badgeTier: 'Gold',
      roles: ['Distributor'],
    },
    loading: false,
    error: null,
  });
});
afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe('opportunity stage chart', () => {
  it('uses the same formatted pipeline amount for the Home card and chart from a single request', async () => {
    fetchTotals.mockResolvedValue({
      stages: [
        {
          stage: 'Qualification',
          label: 'Qualification',
          amount: 1250300.5,
          displayAmount: 'EUR 1,250,300.50',
          opportunityCount: 42,
        },
      ],
      totalAmount: 1250300.5,
      displayTotalAmount: 'EUR 1,250,300.50',
      opportunityCount: 42,
    });
    renderChart(true);
    const overview = screen.getByRole('region', { name: 'Partner overview' });
    const card = within(overview).getByRole('region', {
      name: 'Opportunity Pipeline',
    });
    expect(
      await within(card).findByText('EUR 1,250,300.50')
    ).toBeInTheDocument();
    expect(
      screen.getByLabelText('Total pipeline value: EUR 1,250,300.50')
    ).toHaveTextContent('EUR 1,250,300.50');
    expect(within(card).queryByText('42')).not.toBeInTheDocument();
    expect(
      within(overview).queryByRole('region', { name: 'Total Opportunities' })
    ).not.toBeInTheDocument();
    expect(within(overview).getAllByRole('region')).toHaveLength(5);
    expect(
      within(card).getByRole('link', { name: 'View opportunities' })
    ).toHaveAttribute('href', '/opportunities');
    expect(fetchTotals).toHaveBeenCalledTimes(1);
    expect(within(overview).getByText('35 Points')).toBeInTheDocument();
    expect(within(overview).getByText('2 Credits')).toBeInTheDocument();
    expect(within(overview).getByText('Active')).toBeInTheDocument();
  });

  it('keeps the Home cards visible without inventing a value while pipeline data loads', () => {
    fetchTotals.mockReturnValue(new Promise(() => {}));
    renderChart(true);
    const overview = screen.getByRole('region', { name: 'Partner overview' });
    const card = within(overview).getByRole('region', {
      name: 'Opportunity Pipeline',
    });
    expect(within(card).getByText('Loading...')).toBeInTheDocument();
    expect(within(card).queryByText('0')).not.toBeInTheDocument();
    expect(within(overview).getByText('35 Points')).toBeInTheDocument();
  });

  it('shows an unavailable pipeline value rather than zero after an aggregate error', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    fetchTotals.mockRejectedValue(new Error('Amount access denied'));
    renderChart(true);
    await screen.findByRole('alert');
    const card = within(
      screen.getByRole('region', { name: 'Partner overview' })
    ).getByRole('region', { name: 'Opportunity Pipeline' });
    expect(within(card).getByText('Unavailable')).toBeInTheDocument();
    expect(
      within(card).getByText('Pipeline value could not be loaded')
    ).toBeInTheDocument();
    expect(within(card).queryByText('0')).not.toBeInTheDocument();
  });

  it('shows a real zero in the Home pipeline card for an empty aggregate response', async () => {
    fetchTotals.mockResolvedValue({
      stages: [],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 0,
    });
    renderChart(true);
    await screen.findByText('No opportunities to chart.');
    const card = within(
      screen.getByRole('region', { name: 'Partner overview' })
    ).getByRole('region', { name: 'Opportunity Pipeline' });
    expect(within(card).getByText('0')).toBeInTheDocument();
    expect(
      screen.queryByText('No opportunities found.')
    ).not.toBeInTheDocument();
  });

  it('plots stages on X and sum of Amount on Y with exact totals available', async () => {
    fetchTotals.mockResolvedValue({
      stages: [
        {
          stage: 'Qualification',
          label: 'Qualification',
          amount: 1200,
          displayAmount: '$1,200.00',
          opportunityCount: 2,
        },
        {
          stage: 'Closed Won',
          label: 'Closed Won',
          amount: 2400,
          displayAmount: '$2,400.00',
          opportunityCount: 3,
        },
      ],
      totalAmount: 3600,
      displayTotalAmount: '$3,600.00',
      opportunityCount: 5,
    });
    renderChart();
    const chart = await screen.findByRole('img', {
      name: /Opportunity amounts by stage/,
    });
    expect(fetchTotals).toHaveBeenCalledWith('account-1');
    expect(chart).toHaveAccessibleName(
      /Stages on the X-axis and sum of Amount on the Y-axis/
    );
    const qualification = chart.querySelector(
      'rect[aria-label="Qualification: $1,200.00, 2 opportunities"]'
    );
    const won = chart.querySelector(
      'rect[aria-label="Closed Won: $2,400.00, 3 opportunities"]'
    );
    expect(Number(won?.getAttribute('height'))).toBeCloseTo(
      Number(qualification?.getAttribute('height')) * 2
    );
    expect(qualification?.getAttribute('fill')).toMatch(/-blue/);
    expect(won?.getAttribute('fill')).toMatch(/-green/);
    expect(qualification).toHaveAttribute('tabindex', '0');
    expect(qualification?.querySelector('title')).toHaveTextContent(
      'Qualification: $1,200.00; 2 opportunities'
    );
    expect(
      screen.getByLabelText('Total pipeline value: $3,600.00')
    ).toBeInTheDocument();
    expect(
      screen.getByText('Total Opportunities').previousElementSibling
    ).toHaveTextContent('5');
    expect(screen.queryByText(/last quarter/)).not.toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'View all' })).toHaveAttribute(
      'href',
      '/opportunities'
    );
    expect(
      screen.getByRole('link', { name: 'View opportunities' })
    ).toHaveAttribute('href', '/opportunities');
    fireEvent.click(screen.getByText('View stage totals'));
    const table = screen.getByRole('table', {
      name: 'Exact opportunity amount totals by stage',
    });
    expect(
      within(table).getByRole('row', { name: 'Qualification $1,200.00 2' })
    ).toBeInTheDocument();
    expect(
      within(table).getByRole('row', { name: 'Closed Won $2,400.00 3' })
    ).toBeInTheDocument();
  });

  it('places negative bars below zero and keeps zero-only data finite', async () => {
    fetchTotals.mockResolvedValue({
      stages: [
        {
          stage: 'Adjustment',
          label: 'Adjustment',
          amount: -100,
          displayAmount: '-100',
          opportunityCount: 1,
        },
        {
          stage: 'Qualification',
          label: 'Qualification',
          amount: 100,
          displayAmount: '100',
          opportunityCount: 1,
        },
      ],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 2,
    });
    const { unmount } = renderChart();
    const chart = await screen.findByRole('img', {
      name: /Opportunity amounts by stage/,
    });
    const negative = chart.querySelector(
      'rect[aria-label="Adjustment: -100, 1 opportunities"]'
    );
    const positive = chart.querySelector(
      'rect[aria-label="Qualification: 100, 1 opportunities"]'
    );
    expect(negative).toHaveAttribute('y', '74');
    expect(negative).toHaveAttribute('height', '50');
    expect(positive).toHaveAttribute('y', '24');
    unmount();
    fetchTotals.mockResolvedValue({
      stages: [
        {
          stage: 'Qualification',
          label: 'Qualification',
          amount: 0,
          displayAmount: '0',
          opportunityCount: 1,
        },
      ],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 1,
    });
    renderChart();
    const zeroChart = await screen.findByRole('img', {
      name: /Opportunity amounts by stage/,
    });
    expect(zeroChart.querySelector('rect')).toHaveAttribute('height', '0');
    expect(zeroChart.outerHTML).not.toMatch(/NaN|Infinity/);
  });

  it('shows loading without inventing totals', () => {
    fetchTotals.mockReturnValue(new Promise(() => {}));
    renderChart();
    expect(screen.getByRole('status')).toHaveTextContent(
      'Loading opportunity stage totals'
    );
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
  });

  it('shows an explicit empty state', async () => {
    fetchTotals.mockResolvedValue({
      stages: [],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 0,
    });
    renderChart();
    expect(
      await screen.findByText('No opportunities to chart.')
    ).toBeInTheDocument();
    expect(screen.queryByRole('img')).not.toBeInTheDocument();
  });

  it('reports access errors and leaves the Opportunities list available', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    fetchTotals.mockRejectedValue(new Error('Access denied'));
    renderPage();
    expect(await screen.findByRole('alert')).toHaveTextContent('Access denied');
    expect(
      screen.getByRole('region', { name: 'Opportunity list' })
    ).toBeInTheDocument();
    expect(
      screen.queryByText('No opportunities to chart.')
    ).not.toBeInTheDocument();
  });

  it('places the chart above the Opportunities list', async () => {
    fetchTotals.mockResolvedValue({
      stages: [],
      totalAmount: 0,
      displayTotalAmount: '0',
      opportunityCount: 0,
    });
    renderPage();
    await screen.findByText('No opportunities to chart.');
    const chart = screen.getByRole('region', {
      name: 'Opportunity Pipeline',
    });
    const list = screen.getByRole('region', { name: 'Opportunity list' });
    expect(chart.compareDocumentPosition(list)).toBe(
      Node.DOCUMENT_POSITION_FOLLOWING
    );
  });
});
