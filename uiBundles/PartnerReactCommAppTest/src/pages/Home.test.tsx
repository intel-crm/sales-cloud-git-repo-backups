import { act, cleanup, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { AuthProvider } from '../features/authentication/context/AuthContext';
import { AuthMenu } from '../features/authentication/menu/AuthMenu';
import HomePage from './Home';

const getCurrentUser = vi.hoisted(() => vi.fn());
vi.mock('@salesforce/ui-bundle/api', () => ({ getCurrentUser }));
vi.mock('../components/OpportunityStageChart', () => ({
  OpportunityStageChart: ({
    showPartnerCards,
  }: {
    showPartnerCards?: boolean;
  }) => (
    <>
      {showPartnerCards && (
        <section aria-label="Opportunity dashboard">Dashboard</section>
      )}
      <section aria-label="Opportunity Pipeline">Stage chart</section>
    </>
  ),
}));

beforeEach(() => {
  getCurrentUser.mockReset();
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

function renderHome() {
  return render(
    <MemoryRouter>
      <AuthProvider>
        <AuthMenu />
        <HomePage />
      </AuthProvider>
    </MemoryRouter>
  );
}

describe('Home welcome banner', () => {
  it('greets the same signed-in user shown in the persona menu without another user request', async () => {
    const user = userEvent.setup();
    getCurrentUser.mockResolvedValue({ id: 'user-1', name: 'Ravi Kumar' });
    renderHome();
    expect(
      await screen.findByRole('heading', {
        name: 'Welcome back, Ravi Kumar!',
        level: 1,
      })
    ).toBeInTheDocument();
    const benefits = screen.getByRole('list', { name: 'Partner benefits' });
    expect(within(benefits).getAllByRole('listitem')).toHaveLength(4);
    expect(
      screen.getByRole('region', { name: 'Opportunity dashboard' })
    ).toBeInTheDocument();
    expect(
      screen
        .getByRole('region', { name: 'Opportunity dashboard' })
        .compareDocumentPosition(
          screen.getByRole('region', { name: 'Opportunity Pipeline' })
        )
    ).toBe(Node.DOCUMENT_POSITION_FOLLOWING);
    await user.click(screen.getByRole('button', { name: 'User menu' }));
    expect(await screen.findByText('Ravi Kumar')).toBeInTheDocument();
    expect(getCurrentUser).toHaveBeenCalledTimes(1);
  });

  it('shows a neutral greeting for guests rather than inventing a user name', async () => {
    getCurrentUser.mockResolvedValue(null);
    renderHome();
    expect(
      await screen.findByRole('button', { name: 'User menu' })
    ).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(
      'Welcome to Partner Experience!'
    );
    expect(screen.queryByText(/Welcome back/)).not.toBeInTheDocument();
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
  });

  it('updates the greeting when the shared authentication request finishes', async () => {
    let resolveUser: (user: { id: string; name: string }) => void = () => {
      throw new Error('Authentication request was not started');
    };
    getCurrentUser.mockReturnValue(
      new Promise<{ id: string; name: string }>(resolve => {
        resolveUser = resolve;
      })
    );
    renderHome();
    expect(screen.getByRole('status')).toHaveTextContent(
      'Loading your profile'
    );
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(
      'Welcome to Partner Experience!'
    );
    await act(async () => resolveUser({ id: 'user-1', name: 'Ravi' }));
    expect(
      screen.getByRole('heading', { name: 'Welcome back, Ravi!' })
    ).toBeInTheDocument();
    expect(screen.queryByRole('status')).not.toBeInTheDocument();
  });

  it('surfaces authentication errors while leaving the dashboard available', async () => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    getCurrentUser.mockRejectedValue(new Error('Session unavailable'));
    renderHome();
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Authentication failed'
    );
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(
      'Welcome to Partner Experience!'
    );
    expect(
      screen.getByRole('region', { name: 'Opportunity dashboard' })
    ).toBeInTheDocument();
  });

  it('uses a neutral greeting when the supplied display name is blank', async () => {
    getCurrentUser.mockResolvedValue({ id: 'user-1', name: '   ' });
    renderHome();
    await screen.findByRole('button', { name: 'User menu' });
    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(
      'Welcome to Partner Experience!'
    );
  });
});
