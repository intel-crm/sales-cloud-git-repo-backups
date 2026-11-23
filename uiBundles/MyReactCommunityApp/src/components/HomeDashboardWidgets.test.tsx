import { cleanup, render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { ImportantUpdates } from './ImportantUpdates';
import { RecentActivity } from './RecentActivity';
import { RecommendedTrainings } from './RecommendedTrainings';
import { InviteColleague } from './InviteColleague';
import { QuickLinks } from './QuickLinks';
import { NotificationBell } from './NotificationBell';
import { HelpButton } from './HelpButton';
import { SideNavPromo } from './SideNavPromo';

afterEach(cleanup);

describe('Partner Experience dashboard & layout components', () => {
  it('renders ImportantUpdates with feed items and view-all links', () => {
    render(
      <MemoryRouter>
        <ImportantUpdates />
      </MemoryRouter>
    );
    const region = screen.getByRole('region', { name: 'Important Updates' });
    expect(
      within(region).getByText('New Training Courses Available')
    ).toBeInTheDocument();
    expect(
      within(region).getByText('Points Accrual Benefit Active')
    ).toBeInTheDocument();
    expect(
      within(region).getByText('Manage Benefits Enhancements')
    ).toBeInTheDocument();
    expect(
      within(region).getByRole('link', { name: 'View all' })
    ).toHaveAttribute('href', '/updates');
  });

  it('renders RecentActivity with 5 activity rows', () => {
    render(
      <MemoryRouter>
        <RecentActivity />
      </MemoryRouter>
    );
    const region = screen.getByRole('region', { name: 'Recent Activity' });
    expect(within(region).getAllByRole('listitem')).toHaveLength(5);
    expect(within(region).getByText('Completed training')).toBeInTheDocument();
    expect(
      within(region).getByRole('link', { name: 'View all' })
    ).toHaveAttribute('href', '/activity');
  });

  it('renders RecommendedTrainings with duration, level, and start links', () => {
    render(
      <MemoryRouter>
        <RecommendedTrainings />
      </MemoryRouter>
    );
    const region = screen.getByRole('region', {
      name: 'Recommended Trainings',
    });
    expect(
      within(region).getByText('Intel® AI Solutions Overview')
    ).toBeInTheDocument();
    expect(within(region).getByText('30 min')).toBeInTheDocument();
    expect(
      within(region).getByRole('link', {
        name: 'Start Intel® AI Solutions Overview',
      })
    ).toHaveAttribute('href', '/training');
  });

  it('supports the InviteColleague form flow and error state', async () => {
    const user = userEvent.setup();
    const onSend = vi
      .fn()
      .mockRejectedValueOnce(new Error('Network error'))
      .mockResolvedValueOnce(undefined);

    render(<InviteColleague onSendInvitation={onSend} />);
    const region = screen.getByRole('region', { name: 'Invite a colleague' });
    await user.click(
      within(region).getByRole('button', { name: /Send invitation/i })
    );

    const input = within(region).getByRole('textbox', {
      name: 'Colleague email',
    });
    await user.type(input, 'partner@example.com');
    await user.click(within(region).getByRole('button', { name: 'Send' }));

    expect(await within(region).findByRole('alert')).toHaveTextContent(
      'Could not send. Try again.'
    );

    await user.click(within(region).getByRole('button', { name: 'Send' }));
    expect(await within(region).findByRole('status')).toHaveTextContent(
      'Invitation sent.'
    );
    expect(onSend).toHaveBeenCalledWith('partner@example.com');

    await user.click(
      within(region).getByRole('button', { name: 'Invite another' })
    );
    expect(
      within(region).getByRole('textbox', { name: 'Colleague email' })
    ).toHaveValue('');
  });

  it('renders QuickLinks with all 6 portal shortcuts', () => {
    render(
      <MemoryRouter>
        <QuickLinks />
      </MemoryRouter>
    );
    const region = screen.getByRole('region', { name: 'Quick Links' });
    expect(within(region).getAllByRole('listitem')).toHaveLength(6);
    expect(
      within(region).getByRole('link', { name: 'Manage Benefits' })
    ).toHaveAttribute('href', '/benefits');
    expect(
      within(region).getByRole('link', { name: 'Points' })
    ).toHaveAttribute('href', '/points-rewards');
  });

  it('renders NotificationBell, HelpButton, and SideNavPromo', () => {
    render(
      <MemoryRouter>
        <NotificationBell unreadCount={5} />
        <HelpButton />
        <SideNavPromo />
      </MemoryRouter>
    );
    expect(
      screen.getByRole('link', { name: 'Notifications, 5 unread' })
    ).toHaveAttribute('href', '/notifications');
    expect(screen.getByRole('link', { name: 'Help' })).toHaveAttribute(
      'href',
      '/help'
    );
    expect(
      screen.getByRole('link', { name: /Explore resources/i })
    ).toHaveAttribute('href', '/resources');
  });
});

