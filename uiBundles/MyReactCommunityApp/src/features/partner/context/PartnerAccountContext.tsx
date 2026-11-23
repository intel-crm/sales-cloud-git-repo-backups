import { createContext, useContext, type ReactNode } from 'react';
import {
  fetchPartnerAccount,
  type PartnerAccount,
} from '../../../api/account/partnerAccount';
import { useAsyncData } from '../../../hooks/useAsyncData';
import { useAuth } from '../../authentication/context/AuthContext';

interface PartnerAccountState {
  account: PartnerAccount | null;
  loading: boolean;
  error: string | null;
  isAuthFallback?: boolean;
}

const DUMMY_PARTNER_ACCOUNT: PartnerAccount = {
  kind: 'ready',
  accountId: '0018A00000UdIm5QAF',
  badgeTier: 'Titanium',
  roles: ['Distributor'],
  opportunityScope: 'all-accessible',
};

const PartnerAccountContext = createContext<PartnerAccountState | undefined>(
  undefined
);

export function PartnerAccountProvider({ children }: { children: ReactNode }) {
  const auth = useAuth();
  const userId = auth.user?.id;
  const isAuthFailed = Boolean(
    !auth.loading && auth.error?.includes('Authentication failed')
  );
  const result = useAsyncData<PartnerAccount>(async () => {
    if (isAuthFailed) return DUMMY_PARTNER_ACCOUNT;
    if (auth.error) throw new Error(auth.error);
    if (auth.loading || !auth.isAuthenticated || !userId)
      return { kind: 'not-applicable' };
    return fetchPartnerAccount(userId);
  }, [userId, auth.loading, auth.isAuthenticated, auth.error, isAuthFailed]);
  const loading = auth.loading || (!isAuthFailed && result.loading);
  const error = isAuthFailed ? null : auth.error || result.error;
  return (
    <PartnerAccountContext.Provider
      value={{
        account: isAuthFailed
          ? DUMMY_PARTNER_ACCOUNT
          : !loading && !error
            ? result.data
            : null,
        loading,
        error,
        isAuthFallback: isAuthFailed,
      }}
    >
      {children}
    </PartnerAccountContext.Provider>
  );
}

export function usePartnerAccount(): PartnerAccountState {
  const state = useContext(PartnerAccountContext);
  if (!state)
    throw new Error(
      'usePartnerAccount must be used within a PartnerAccountProvider'
    );
  return state;
}

export function useOptionalPartnerAccount(): PartnerAccountState | undefined {
  return useContext(PartnerAccountContext);
}
