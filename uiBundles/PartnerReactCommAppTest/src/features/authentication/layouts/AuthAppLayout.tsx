import SessionTimeoutValidator from '../sessionTimeout/SessionTimeoutValidator';
import { AuthProvider } from '../context/AuthContext';
import AppLayout from '../../../appLayout';
import { PartnerAccountProvider } from '../../partner/context/PartnerAccountContext';

export default function AuthAppLayout() {
  return (
    <AuthProvider>
      <SessionTimeoutValidator basePath="" />
      <PartnerAccountProvider>
        <AppLayout />
      </PartnerAccountProvider>
    </AuthProvider>
  );
}
