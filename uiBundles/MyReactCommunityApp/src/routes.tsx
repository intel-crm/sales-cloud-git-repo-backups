import type { RouteObject } from 'react-router';
import Home from './pages/Home';
import Opportunities from './pages/Opportunities';
import PointsRewards, { ComingSoonPage } from './pages/PointsRewards';
import ManageBenefits from './pages/ManageBenefits';
import WarrantyPage from './pages/WarrantyPage';
import AccountManagementPage from './pages/AccountManagementPage';
import ImportantUpdatesPage from './pages/ImportantUpdatesPage';
import NotFound from './pages/NotFound';
import Login from "./features/authentication/pages/Login";
import Register from "./features/authentication/pages/Register";
import ForgotPassword from "./features/authentication/pages/ForgotPassword";
import ResetPassword from "./features/authentication/pages/ResetPassword";
import Profile from "./features/authentication/pages/Profile";
import ChangePassword from "./features/authentication/pages/ChangePassword";
import PrivateRoute from "./features/authentication/layouts/privateRouteLayout";
import { ROUTES } from "./features/authentication/authenticationConfig";
import { Search as GlobalSearch, config } from "./features/search";
import TestChatPage from "./pages/TestChatPage";
import AuthAppLayout from "./features/authentication/layouts/AuthAppLayout";
import AccountObjectDetail from "./pages/AccountObjectDetailPage";

export const routes: RouteObject[] = [
  {
    path: "/",
    element: <AuthAppLayout />,
    children: [
      {
        index: true,
        element: <Home />,
        handle: { showInNavigation: true, label: "Home" }
      },
      {
        path: "benefits",
        element: <ManageBenefits />,
        handle: { showInNavigation: true, label: "Manage Benefits" }
      },
      {
        path: "points-rewards",
        element: <PointsRewards />,
        handle: { showInNavigation: true, label: "Points & Rewards" }
      },
      {
        path: "warranty",
        element: <WarrantyPage />,
        handle: { showInNavigation: true, label: "Warranty" }
      },
      {
        path: "training",
        element: <ComingSoonPage title="Sales & Training" />,
        handle: { showInNavigation: true, label: "Sales & Training" }
      },
      {
        path: "opportunities",
        element: <Opportunities />,
        handle: { showInNavigation: true, label: "Opportunities" }
      },
      {
        path: "resources",
        element: <ComingSoonPage title="Resources & Tools" />,
        handle: { showInNavigation: true, label: "Resources & Tools" }
      },
      {
        path: "account",
        element: <AccountManagementPage />,
        handle: { showInNavigation: true, label: "Account Management" }
      },
      {
        path: "reports",
        element: <ComingSoonPage title="Reports & Analytics" />,
        handle: { showInNavigation: true, label: "Reports & Analytics" }
      },
      {
        path: "updates",
        element: <ImportantUpdatesPage />,
        handle: { showInNavigation: false, label: "Important Updates" }
      },
      {
        path: "activity",
        element: <ComingSoonPage title="Recent Activity" />,
        handle: { showInNavigation: false, label: "Recent Activity" }
      },
      {
        path: "notifications",
        element: <ComingSoonPage title="Notifications" />,
        handle: { showInNavigation: false, label: "Notifications" }
      },
      {
        path: "help",
        element: <ComingSoonPage title="Help" />,
        handle: { showInNavigation: false, label: "Help" }
      },
      {
        path: ROUTES.LOGIN.PATH,
        element: <Login />,
        handle: { showInNavigation: false, label: "Login", title: ROUTES.LOGIN.TITLE }
      },
      {
        path: ROUTES.REGISTER.PATH,
        element: <Register />,
        handle: { showInNavigation: false, title: ROUTES.REGISTER.TITLE }
      },
      {
        path: ROUTES.FORGOT_PASSWORD.PATH,
        element: <ForgotPassword />,
        handle: { showInNavigation: false, title: ROUTES.FORGOT_PASSWORD.TITLE }
      },
      {
        path: ROUTES.RESET_PASSWORD.PATH,
        element: <ResetPassword />,
        handle: { showInNavigation: false, title: ROUTES.RESET_PASSWORD.TITLE }
      },
      {
        element: <PrivateRoute />,
        children: [
          {
            path: ROUTES.PROFILE.PATH,
            element: <Profile />,
            handle: { showInNavigation: false, label: "Profile", title: ROUTES.PROFILE.TITLE }
          },
          {
            path: ROUTES.CHANGE_PASSWORD.PATH,
            element: <ChangePassword />,
            handle: { showInNavigation: false, title: ROUTES.CHANGE_PASSWORD.TITLE }
          }
        ]
      },
      {
        path: "search",
        element: (
					<GlobalSearch
						as="main"
						config={config}
						title="Search Results"
						showSearchBar={false}
						resultLayout="table"
					/>
				),
        handle: { showInNavigation: true, label: "Search Results" }
      },
      {
        path: "test-chat",
        element: <TestChatPage />,
        handle: { showInNavigation: true, label: "Test Chat" }
      },
      {
        path: "accounts/:recordId",
        element: <AccountObjectDetail />
      },
      {
        path: '*',
        element: <NotFound />
      }
    ]
  }
];
