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
}

const PartnerAccountContext = createContext<PartnerAccountState | undefined>(
  undefined
);

export function PartnerAccountProvider({ children }: { children: ReactNode }) {
  const auth = useAuth();
  const userId = auth.user?.id;
  const result = useAsyncData<PartnerAccount>(async () => {
    if (auth.error) throw new Error(auth.error);
    if (auth.loading || !auth.isAuthenticated || !userId)
      return { kind: 'not-applicable' };
    return fetchPartnerAccount(userId);
  }, [userId, auth.loading, auth.isAuthenticated, auth.error]);
  const loading = auth.loading || result.loading;
  const error = auth.error || result.error;
  return (
    <PartnerAccountContext.Provider
      value={{
        account: !loading && !error ? result.data : null,
        loading,
        error,
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
