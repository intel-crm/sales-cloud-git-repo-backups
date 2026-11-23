import { executeGraphQL } from './graphqlClient';
import type { FeedItem } from '../components/FeedList';

type UiField<T = unknown> = {
  value?: T | null;
  displayValue?: string | null;
} | null;

function strVal(field?: UiField): string | null {
  if (!field) return null;
  if (typeof field.displayValue === 'string' && field.displayValue.trim()) {
    return field.displayValue.trim();
  }
  if (field.value !== null && field.value !== undefined) {
    const text = String(field.value).trim();
    return text || null;
  }
  return null;
}

function numVal(field?: UiField): number | null {
  if (!field) return null;
  if (typeof field.value === 'number' && Number.isFinite(field.value)) {
    return field.value;
  }
  if (typeof field.value === 'string' && field.value.trim()) {
    const parsed = Number(field.value);
    if (Number.isFinite(parsed)) return parsed;
  }
  return null;
}

export function isAuthFailureMessage(message?: string | null): boolean {
  if (!message) return false;
  const lower = message.toLowerCase();
  return (
    lower.includes('authentication failed') ||
    lower.includes('unauthorized') ||
    lower.includes('401') ||
    lower.includes('invalid session') ||
    lower.includes('guest')
  );
}

/* ============================================================================
 * 1. POINTS & REWARDS (PRM_Points_Data__c)
 * ========================================================================== */

export interface PartnerPointsRecord {
  id: string;
  name: string;
  accountId: string | null;
  accountName: string | null;
  balance: number;
  available: number;
  earned: number;
  redeemed: number;
  expired: number;
  dueToExpire: number;
  startDate: string | null;
  endDate: string | null;
  lastUpdated: string | null;
}

export interface PartnerPointsSummary {
  totalBalance: number;
  totalAvailable: number;
  totalEarned: number;
  totalRedeemed: number;
  totalDueToExpire: number;
  records: PartnerPointsRecord[];
  scope: 'account' | 'org-accessible' | 'sample';
}

const POINTS_BY_ACCOUNT_QUERY = `
  query GetPartnerPointsByAccount($accountId: ID!, $first: Int = 25) {
    uiapi {
      query {
        PRM_Points_Data__c(
          first: $first
          where: { PRM_Account_Id__c: { eq: $accountId } }
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Account_Id__c @optional { value }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Points_Balance__c @optional { value displayValue }
              PRM_Total_Points_Available_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Earned_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Redeemed_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Expired_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Due_to_Expire_Nbr__c @optional { value displayValue }
              PRM_Start_Date_Dt__c @optional { value displayValue }
              PRM_End_Date_Dt__c @optional { value displayValue }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

const POINTS_ALL_QUERY = `
  query GetPartnerPointsAccessible($first: Int = 25) {
    uiapi {
      query {
        PRM_Points_Data__c(
          first: $first
          where: { PRM_Points_Balance__c: { gt: 0 } }
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Account_Id__c @optional { value }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Points_Balance__c @optional { value displayValue }
              PRM_Total_Points_Available_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Earned_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Redeemed_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Expired_Nbr__c @optional { value displayValue }
              PRM_Total_Points_Due_to_Expire_Nbr__c @optional { value displayValue }
              PRM_Start_Date_Dt__c @optional { value displayValue }
              PRM_End_Date_Dt__c @optional { value displayValue }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface PointsQueryResponse {
  uiapi?: {
    query?: {
      PRM_Points_Data__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            PRM_Account_Id__c?: UiField<string>;
            PRM_Account_Id__r?: { Name?: UiField<string> } | null;
            PRM_Points_Balance__c?: UiField<number>;
            PRM_Total_Points_Available_Nbr__c?: UiField<number>;
            PRM_Total_Points_Earned_Nbr__c?: UiField<number>;
            PRM_Total_Points_Redeemed_Nbr__c?: UiField<number>;
            PRM_Total_Points_Expired_Nbr__c?: UiField<number>;
            PRM_Total_Points_Due_to_Expire_Nbr__c?: UiField<number>;
            PRM_Start_Date_Dt__c?: UiField<string>;
            PRM_End_Date_Dt__c?: UiField<string>;
            LastModifiedDate?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

export const DUMMY_POINTS_SUMMARY: PartnerPointsSummary = {
  totalBalance: 1250,
  totalAvailable: 1250,
  totalEarned: 1650,
  totalRedeemed: 400,
  totalDueToExpire: 150,
  scope: 'sample',
  records: [
    {
      id: 'a768A0000004qnwQAA',
      name: 'PTS-2026-Q3-001',
      accountId: '0018A00000UdIm5QAF',
      accountName: 'Test_DISTI_Account',
      balance: 1200,
      available: 1200,
      earned: 1500,
      redeemed: 300,
      expired: 0,
      dueToExpire: 100,
      startDate: '2026-07-01',
      endDate: '2026-12-31',
      lastUpdated: '2026-10-10',
    },
    {
      id: 'a768A0000004qjQQAQ',
      name: 'PTS-2026-Q2-014',
      accountId: '0018A00000UdIm5QAF',
      accountName: 'Test_DISTI_Account',
      balance: 40,
      available: 40,
      earned: 140,
      redeemed: 100,
      expired: 0,
      dueToExpire: 40,
      startDate: '2026-04-01',
      endDate: '2026-11-30',
      lastUpdated: '2026-09-22',
    },
    {
      id: 'a768A0000004qjaQAA',
      name: 'PTS-2026-Q1-009',
      accountId: '0018A00000UdIm5QAF',
      accountName: 'Test_DISTI_Account',
      balance: 10,
      available: 10,
      earned: 10,
      redeemed: 0,
      expired: 0,
      dueToExpire: 10,
      startDate: '2026-01-01',
      endDate: '2026-11-15',
      lastUpdated: '2026-08-14',
    },
  ],
};

function mapPointsEdges(
  data: PointsQueryResponse
): PartnerPointsRecord[] {
  const edges = data.uiapi?.query?.PRM_Points_Data__c?.edges ?? [];
  const records: PartnerPointsRecord[] = [];
  for (const edge of edges) {
    const node = edge?.node;
    if (!node?.Id) continue;
    const balance = numVal(node.PRM_Points_Balance__c) ?? 0;
    const available =
      numVal(node.PRM_Total_Points_Available_Nbr__c) ?? balance;
    const earned = numVal(node.PRM_Total_Points_Earned_Nbr__c) ?? balance;
    const redeemed = numVal(node.PRM_Total_Points_Redeemed_Nbr__c) ?? 0;
    const expired = numVal(node.PRM_Total_Points_Expired_Nbr__c) ?? 0;
    const dueToExpire =
      numVal(node.PRM_Total_Points_Due_to_Expire_Nbr__c) ?? 0;

    records.push({
      id: node.Id,
      name: strVal(node.Name) ?? node.Id,
      accountId: strVal(node.PRM_Account_Id__c),
      accountName: strVal(node.PRM_Account_Id__r?.Name),
      balance,
      available,
      earned,
      redeemed,
      expired,
      dueToExpire,
      startDate: strVal(node.PRM_Start_Date_Dt__c),
      endDate: strVal(node.PRM_End_Date_Dt__c),
      lastUpdated:
        (typeof node.LastModifiedDate?.value === 'string'
          ? node.LastModifiedDate.value
          : strVal(node.LastModifiedDate)) ?? null,
    });
  }
  return records;
}

function summarizePoints(
  records: PartnerPointsRecord[],
  scope: PartnerPointsSummary['scope']
): PartnerPointsSummary {
  return {
    totalBalance: records.reduce((sum, r) => sum + r.balance, 0),
    totalAvailable: records.reduce((sum, r) => sum + r.available, 0),
    totalEarned: records.reduce((sum, r) => sum + r.earned, 0),
    totalRedeemed: records.reduce((sum, r) => sum + r.redeemed, 0),
    totalDueToExpire: records.reduce((sum, r) => sum + r.dueToExpire, 0),
    records,
    scope,
  };
}

export async function fetchPartnerPointsData(
  accountId?: string | null
): Promise<PartnerPointsSummary> {
  if (accountId) {
    const accountRes = await executeGraphQL<
      PointsQueryResponse,
      { accountId: string; first: number }
    >(POINTS_BY_ACCOUNT_QUERY, { accountId, first: 25 });
    const accountRecords = mapPointsEdges(accountRes);
    if (accountRecords.length > 0) {
      return summarizePoints(accountRecords, 'account');
    }
  }

  const allRes = await executeGraphQL<PointsQueryResponse, { first: number }>(
    POINTS_ALL_QUERY,
    { first: 20 }
  );
  const orgRecords = mapPointsEdges(allRes);
  if (orgRecords.length > 0) {
    return summarizePoints(orgRecords, 'org-accessible');
  }

  return DUMMY_POINTS_SUMMARY;
}

/* ============================================================================
 * 2. BENEFITS & SPECIALTIES (PRM_AccountBenefitAssociation__c & PRM_PartnerBenefit__c)
 * ========================================================================== */

export interface PartnerBenefitItem {
  id: string;
  name: string;
  status: string;
  code: string | null;
  type: string | null;
  description: string | null;
  accountName: string | null;
  statusChangedDate: string | null;
  source: string | null;
}

export interface PartnerBenefitsSummary {
  activeCount: number;
  inactiveCount: number;
  totalCount: number;
  enrolledBenefits: PartnerBenefitItem[];
  catalogBenefits: PartnerBenefitItem[];
  scope: 'account' | 'org-accessible' | 'sample';
}

const ACCOUNT_BENEFITS_BY_ACCOUNT_QUERY = `
  query GetAccountBenefits($accountId: ID!, $first: Int = 30) {
    uiapi {
      query {
        PRM_AccountBenefitAssociation__c(
          first: $first
          where: { PRM_Account_Id__c: { eq: $accountId } }
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Benefit_Name__c @optional { value displayValue }
              PRM_Status_Nm__c @optional { value displayValue }
              PRM_Status_Change_Dt__c @optional { value displayValue }
              PRM_Source__c @optional { value displayValue }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Partner_Benefit_Id__r @optional {
                Name @optional { value displayValue }
                PRM_Benefit_Cd__c @optional { value displayValue }
                PRM_Benefit_Dsc__c @optional { value displayValue }
                PRM_Benefit_Type_Nm__c @optional { value displayValue }
              }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

const ACCOUNT_BENEFITS_ALL_QUERY = `
  query GetAccessibleBenefits($first: Int = 30) {
    uiapi {
      query {
        PRM_AccountBenefitAssociation__c(
          first: $first
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Benefit_Name__c @optional { value displayValue }
              PRM_Status_Nm__c @optional { value displayValue }
              PRM_Status_Change_Dt__c @optional { value displayValue }
              PRM_Source__c @optional { value displayValue }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Partner_Benefit_Id__r @optional {
                Name @optional { value displayValue }
                PRM_Benefit_Cd__c @optional { value displayValue }
                PRM_Benefit_Dsc__c @optional { value displayValue }
                PRM_Benefit_Type_Nm__c @optional { value displayValue }
              }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
        PRM_PartnerBenefit__c(
          first: 20
          where: { PRM_InActive_Ind__c: { eq: false } }
          orderBy: { Name: { order: ASC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Benefit_Cd__c @optional { value displayValue }
              PRM_Benefit_Dsc__c @optional { value displayValue }
              PRM_Benefit_Type_Nm__c @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface BenefitsQueryResponse {
  uiapi?: {
    query?: {
      PRM_AccountBenefitAssociation__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            PRM_Benefit_Name__c?: UiField<string>;
            PRM_Status_Nm__c?: UiField<string>;
            PRM_Status_Change_Dt__c?: UiField<string>;
            PRM_Source__c?: UiField<string>;
            PRM_Account_Id__r?: { Name?: UiField<string> } | null;
            PRM_Partner_Benefit_Id__r?: {
              Name?: UiField<string>;
              PRM_Benefit_Cd__c?: UiField<string>;
              PRM_Benefit_Dsc__c?: UiField<string>;
              PRM_Benefit_Type_Nm__c?: UiField<string>;
            } | null;
            LastModifiedDate?: UiField<string>;
          };
        } | null> | null;
      } | null;
      PRM_PartnerBenefit__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            PRM_Benefit_Cd__c?: UiField<string>;
            PRM_Benefit_Dsc__c?: UiField<string>;
            PRM_Benefit_Type_Nm__c?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

export const DUMMY_BENEFITS_SUMMARY: PartnerBenefitsSummary = {
  activeCount: 4,
  inactiveCount: 1,
  totalCount: 5,
  scope: 'sample',
  enrolledBenefits: [
    {
      id: 'a5i8A0000008zEyQAI',
      name: 'Partner University',
      status: 'Active',
      code: 'BNF-PU',
      type: 'Training & Enablement',
      description:
        'Full access to Intel® Partner University competencies, pathways, and certifications.',
      accountName: 'Test_DISTI_Account',
      statusChangedDate: '2026-09-15',
      source: 'Tier Entitlement',
    },
    {
      id: 'a5i8A0000008zExQAI',
      name: 'Points Accruals View',
      status: 'Active',
      code: 'BNF-PAV',
      type: 'Financial & Rebates',
      description:
        'Track quarterly point accruals and promotional reward earnings on qualifying Intel purchases.',
      accountName: 'Test_DISTI_Account',
      statusChangedDate: '2026-09-10',
      source: 'Tier Entitlement',
    },
    {
      id: 'a5i8A0000008zEwQAI',
      name: 'Points Redemption',
      status: 'Active',
      code: 'BNF-PRD',
      type: 'Financial & Rebates',
      description:
        'Redeem earned partner points for credit memos, demo kits, and co-marketing vouchers.',
      accountName: 'Test_DISTI_Account',
      statusChangedDate: '2026-08-22',
      source: 'Tier Entitlement',
    },
    {
      id: 'a5i8A000000661ZQAQ',
      name: 'Advanced Warranty Replacement (AWR)',
      status: 'Active',
      code: 'BNF-AWR',
      type: 'Support & Warranty',
      description:
        'Expedited replacement shipments for eligible Intel boxed processors and server components.',
      accountName: 'Test_DISTI_Account',
      statusChangedDate: '2026-07-18',
      source: 'Tier Entitlement',
    },
    {
      id: 'a5i8A000000661eQAA',
      name: 'Solutions Marketplace Basic Profile',
      status: 'Inactive',
      code: 'BNF-SMP',
      type: 'Marketing & Showcase',
      description:
        'Publish company profile and validated offerings on the Intel® Partner Showcase.',
      accountName: 'Test_DISTI_Account',
      statusChangedDate: '2026-06-01',
      source: 'Program Enrollment',
    },
  ],
  catalogBenefits: [],
};

function mapBenefitAssociationEdges(
  data: BenefitsQueryResponse
): PartnerBenefitItem[] {
  const edges = data.uiapi?.query?.PRM_AccountBenefitAssociation__c?.edges ?? [];
  const items: PartnerBenefitItem[] = [];
  for (const edge of edges) {
    const node = edge?.node;
    if (!node?.Id) continue;
    const rel = node.PRM_Partner_Benefit_Id__r;
    const benefitName =
      strVal(node.PRM_Benefit_Name__c) ??
      strVal(rel?.Name) ??
      strVal(node.Name) ??
      'Partner Benefit';
    const status = strVal(node.PRM_Status_Nm__c) ?? 'Active';
    items.push({
      id: node.Id,
      name: benefitName,
      status,
      code: strVal(rel?.PRM_Benefit_Cd__c),
      type: strVal(rel?.PRM_Benefit_Type_Nm__c),
      description: strVal(rel?.PRM_Benefit_Dsc__c),
      accountName: strVal(node.PRM_Account_Id__r?.Name),
      statusChangedDate:
        strVal(node.PRM_Status_Change_Dt__c) ??
        (typeof node.LastModifiedDate?.value === 'string'
          ? node.LastModifiedDate.value
          : strVal(node.LastModifiedDate)),
      source: strVal(node.PRM_Source__c),
    });
  }
  return items;
}

function mapCatalogBenefitEdges(
  data: BenefitsQueryResponse
): PartnerBenefitItem[] {
  const edges = data.uiapi?.query?.PRM_PartnerBenefit__c?.edges ?? [];
  const items: PartnerBenefitItem[] = [];
  for (const edge of edges) {
    const node = edge?.node;
    if (!node?.Id) continue;
    items.push({
      id: node.Id,
      name: strVal(node.Name) ?? 'Program Benefit',
      status: 'Catalog',
      code: strVal(node.PRM_Benefit_Cd__c),
      type: strVal(node.PRM_Benefit_Type_Nm__c),
      description: strVal(node.PRM_Benefit_Dsc__c),
      accountName: null,
      statusChangedDate: null,
      source: null,
    });
  }
  return items;
}

export async function fetchPartnerBenefitsData(
  accountId?: string | null
): Promise<PartnerBenefitsSummary> {
  const allRes = await executeGraphQL<
    BenefitsQueryResponse,
    { first: number }
  >(ACCOUNT_BENEFITS_ALL_QUERY, { first: 30 });
  const catalogBenefits = mapCatalogBenefitEdges(allRes);

  if (accountId) {
    const accRes = await executeGraphQL<
      BenefitsQueryResponse,
      { accountId: string; first: number }
    >(ACCOUNT_BENEFITS_BY_ACCOUNT_QUERY, { accountId, first: 30 });
    const enrolled = mapBenefitAssociationEdges(accRes);
    if (enrolled.length > 0) {
      const activeCount = enrolled.filter(
        b => b.status.toLowerCase() === 'active'
      ).length;
      return {
        activeCount,
        inactiveCount: enrolled.length - activeCount,
        totalCount: enrolled.length,
        enrolledBenefits: enrolled,
        catalogBenefits,
        scope: 'account',
      };
    }
  }

  const orgEnrolled = mapBenefitAssociationEdges(allRes);
  if (orgEnrolled.length > 0) {
    const activeCount = orgEnrolled.filter(
      b => b.status.toLowerCase() === 'active'
    ).length;
    return {
      activeCount,
      inactiveCount: orgEnrolled.length - activeCount,
      totalCount: orgEnrolled.length,
      enrolledBenefits: orgEnrolled,
      catalogBenefits,
      scope: 'org-accessible',
    };
  }

  return DUMMY_BENEFITS_SUMMARY;
}

/* ============================================================================
 * 3. WARRANTY DATA (PRM_Warranty_Data__c)
 * ========================================================================== */

export interface PartnerWarrantyRecord {
  id: string;
  name: string;
  accountName: string | null;
  awrRemaining: number;
  awrUsed: number;
  swrRemaining: number;
  swrUsed: number;
  asOfDate: string | null;
}

export interface PartnerWarrantySummary {
  statusLabel: string;
  awrRemaining: number;
  awrUsed: number;
  swrRemaining: number;
  swrUsed: number;
  records: PartnerWarrantyRecord[];
  scope: 'account' | 'org-accessible' | 'sample';
}

const WARRANTY_BY_ACCOUNT_QUERY = `
  query GetWarrantyByAccount($accountId: ID!, $first: Int = 20) {
    uiapi {
      query {
        PRM_Warranty_Data__c(
          first: $first
          where: { PRM_Account_Id__c: { eq: $accountId } }
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Number_Of_AWR_Remaining_Nbr__c @optional { value displayValue }
              PRM_Number_Of_AWR_Used_Nbr__c @optional { value displayValue }
              PRM_Number_Of_SWR_Remaining_Nbr__c @optional { value displayValue }
              PRM_Number_Of_SWR_Used_Nbr__c @optional { value displayValue }
              PRM_As_of_Date_Dt__c @optional { value displayValue }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

const WARRANTY_ALL_QUERY = `
  query GetAccessibleWarranty($first: Int = 20) {
    uiapi {
      query {
        PRM_Warranty_Data__c(
          first: $first
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Account_Id__r @optional { Name @optional { value displayValue } }
              PRM_Number_Of_AWR_Remaining_Nbr__c @optional { value displayValue }
              PRM_Number_Of_AWR_Used_Nbr__c @optional { value displayValue }
              PRM_Number_Of_SWR_Remaining_Nbr__c @optional { value displayValue }
              PRM_Number_Of_SWR_Used_Nbr__c @optional { value displayValue }
              PRM_As_of_Date_Dt__c @optional { value displayValue }
              LastModifiedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface WarrantyQueryResponse {
  uiapi?: {
    query?: {
      PRM_Warranty_Data__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            PRM_Account_Id__r?: { Name?: UiField<string> } | null;
            PRM_Number_Of_AWR_Remaining_Nbr__c?: UiField<number>;
            PRM_Number_Of_AWR_Used_Nbr__c?: UiField<number>;
            PRM_Number_Of_SWR_Remaining_Nbr__c?: UiField<number>;
            PRM_Number_Of_SWR_Used_Nbr__c?: UiField<number>;
            PRM_As_of_Date_Dt__c?: UiField<string>;
            LastModifiedDate?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

export const DUMMY_WARRANTY_SUMMARY: PartnerWarrantySummary = {
  statusLabel: 'Active',
  awrRemaining: 150,
  awrUsed: 200,
  swrRemaining: 100,
  swrUsed: 200,
  scope: 'sample',
  records: [
    {
      id: 'a7C8A000000CpIGUA0',
      name: 'WRT-AWR-2026-01',
      accountName: 'Test_DISTI_Account',
      awrRemaining: 100,
      awrUsed: 200,
      swrRemaining: 100,
      swrUsed: 200,
      asOfDate: '2026-09-07',
    },
    {
      id: 'a7C8A000000CpV1UAK',
      name: 'WRT-SWR-2026-02',
      accountName: 'Test_DISTI_Account',
      awrRemaining: 50,
      awrUsed: 0,
      swrRemaining: 0,
      swrUsed: 0,
      asOfDate: '2026-10-01',
    },
  ],
};

function mapWarrantyEdges(data: WarrantyQueryResponse): PartnerWarrantyRecord[] {
  const edges = data.uiapi?.query?.PRM_Warranty_Data__c?.edges ?? [];
  const records: PartnerWarrantyRecord[] = [];
  for (const edge of edges) {
    const node = edge?.node;
    if (!node?.Id) continue;
    records.push({
      id: node.Id,
      name: strVal(node.Name) ?? node.Id,
      accountName: strVal(node.PRM_Account_Id__r?.Name),
      awrRemaining: Math.round(
        numVal(node.PRM_Number_Of_AWR_Remaining_Nbr__c) ?? 0
      ),
      awrUsed: Math.round(numVal(node.PRM_Number_Of_AWR_Used_Nbr__c) ?? 0),
      swrRemaining: Math.round(
        numVal(node.PRM_Number_Of_SWR_Remaining_Nbr__c) ?? 0
      ),
      swrUsed: Math.round(numVal(node.PRM_Number_Of_SWR_Used_Nbr__c) ?? 0),
      asOfDate:
        strVal(node.PRM_As_of_Date_Dt__c) ??
        (typeof node.LastModifiedDate?.value === 'string'
          ? node.LastModifiedDate.value.slice(0, 10)
          : strVal(node.LastModifiedDate)),
    });
  }
  return records;
}

function summarizeWarranty(
  records: PartnerWarrantyRecord[],
  scope: PartnerWarrantySummary['scope']
): PartnerWarrantySummary {
  const awrRemaining = records.reduce((s, r) => s + r.awrRemaining, 0);
  const awrUsed = records.reduce((s, r) => s + r.awrUsed, 0);
  const swrRemaining = records.reduce((s, r) => s + r.swrRemaining, 0);
  const swrUsed = records.reduce((s, r) => s + r.swrUsed, 0);
  return {
    statusLabel: awrRemaining + swrRemaining > 0 ? 'Active' : 'Enrolled',
    awrRemaining,
    awrUsed,
    swrRemaining,
    swrUsed,
    records,
    scope,
  };
}

export async function fetchPartnerWarrantyData(
  accountId?: string | null
): Promise<PartnerWarrantySummary> {
  if (accountId) {
    const accRes = await executeGraphQL<
      WarrantyQueryResponse,
      { accountId: string; first: number }
    >(WARRANTY_BY_ACCOUNT_QUERY, { accountId, first: 20 });
    const accRecords = mapWarrantyEdges(accRes);
    if (accRecords.length > 0) {
      return summarizeWarranty(accRecords, 'account');
    }
  }

  const allRes = await executeGraphQL<WarrantyQueryResponse, { first: number }>(
    WARRANTY_ALL_QUERY,
    { first: 20 }
  );
  const orgRecords = mapWarrantyEdges(allRes);
  if (orgRecords.length > 0) {
    return summarizeWarranty(orgRecords, 'org-accessible');
  }

  return DUMMY_WARRANTY_SUMMARY;
}

/* ============================================================================
 * 4. IMPORTANT UPDATES / PARTNER MESSAGES (PRM_Message__c)
 * ========================================================================== */

const PARTNER_MESSAGES_QUERY = `
  query GetPartnerMessages($first: Int = 15) {
    uiapi {
      query {
        PRM_Message__c(
          first: $first
          where: { PRM_InActive_Ind__c: { eq: false } }
          orderBy: { CreatedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              PRM_Title_Txt__c @optional { value displayValue }
              PRM_Description_Txt__c @optional { value displayValue }
              PRM_UI_Display_Area_Nm__c @optional { value displayValue }
              PRM_Start_Date_Dt__c @optional { value displayValue }
              PRM_End_Date_Dt__c @optional { value displayValue }
              PRM_Message_Cd__c @optional { value displayValue }
              CreatedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface PartnerMessagesResponse {
  uiapi?: {
    query?: {
      PRM_Message__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            PRM_Title_Txt__c?: UiField<string>;
            PRM_Description_Txt__c?: UiField<string>;
            PRM_UI_Display_Area_Nm__c?: UiField<string>;
            PRM_Start_Date_Dt__c?: UiField<string>;
            PRM_End_Date_Dt__c?: UiField<string>;
            PRM_Message_Cd__c?: UiField<string>;
            CreatedDate?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

function stripHtmlTags(raw: string): string {
  return raw
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

const UPDATE_TONES: Array<{
  icon: FeedItem['icon'];
  tone: FeedItem['tone'];
}> = [
  { icon: 'campaign', tone: 'purple' },
  { icon: 'gift', tone: 'blue' },
  { icon: 'document', tone: 'blue' },
  { icon: 'coin', tone: 'amber' },
  { icon: 'briefcase', tone: 'green' },
];

export async function fetchPartnerMessages(limit = 12): Promise<FeedItem[]> {
  const res = await executeGraphQL<PartnerMessagesResponse, { first: number }>(
    PARTNER_MESSAGES_QUERY,
    { first: limit }
  );
  const edges = res.uiapi?.query?.PRM_Message__c?.edges ?? [];
  const items: FeedItem[] = [];

  edges.forEach((edge, idx) => {
    const node = edge?.node;
    if (!node?.Id) return;
    const rawTitle = stripHtmlTags(strVal(node.PRM_Title_Txt__c) ?? '');
    const area = strVal(node.PRM_UI_Display_Area_Nm__c);
    const rawDesc = stripHtmlTags(strVal(node.PRM_Description_Txt__c) ?? '');
    const code = strVal(node.PRM_Message_Cd__c);

    // Build a clean human-readable title even when PRM_Title_Txt__c is short (e.g. "New")
    const title =
      rawTitle && rawTitle.toLowerCase() !== 'new'
        ? rawTitle
        : area
          ? `${rawTitle || 'Update'}: ${area}`
          : rawTitle || strVal(node.Name) || 'Partner Program Update';

    const description =
      rawDesc ||
      (area
        ? `Available in ${area}${code ? ` (${code})` : ''}.`
        : 'Active announcement in Intel® Partner Experience.');

    const rawDate =
      (typeof node.PRM_Start_Date_Dt__c?.value === 'string'
        ? node.PRM_Start_Date_Dt__c.value
        : null) ??
      (typeof node.CreatedDate?.value === 'string'
        ? node.CreatedDate.value.slice(0, 10)
        : strVal(node.PRM_Start_Date_Dt__c) ?? '2026-10-01');

    const visual = UPDATE_TONES[idx % UPDATE_TONES.length];
    items.push({
      id: node.Id,
      title,
      description,
      date: rawDate,
      icon: visual.icon,
      tone: visual.tone,
    });
  });

  return items;
}

/* ============================================================================
 * 5. CONTACTS & ACCOUNT DIRECTORY (Contact)
 * ========================================================================== */

export interface PartnerContactRecord {
  id: string;
  name: string;
  title: string | null;
  email: string | null;
  phone: string | null;
  accountName: string | null;
  createdDate: string | null;
}

const CONTACTS_BY_ACCOUNT_QUERY = `
  query GetContactsByAccount($accountId: ID!, $first: Int = 20) {
    uiapi {
      query {
        Contact(
          first: $first
          where: { AccountId: { eq: $accountId } }
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              Title @optional { value displayValue }
              Email @optional { value displayValue }
              Phone @optional { value displayValue }
              Account @optional { Name @optional { value displayValue } }
              CreatedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

const CONTACTS_ALL_QUERY = `
  query GetAccessibleContacts($first: Int = 20) {
    uiapi {
      query {
        Contact(
          first: $first
          orderBy: { LastModifiedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              Title @optional { value displayValue }
              Email @optional { value displayValue }
              Phone @optional { value displayValue }
              Account @optional { Name @optional { value displayValue } }
              CreatedDate @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface ContactsQueryResponse {
  uiapi?: {
    query?: {
      Contact?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            Title?: UiField<string>;
            Email?: UiField<string>;
            Phone?: UiField<string>;
            Account?: { Name?: UiField<string> } | null;
            CreatedDate?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

export const DUMMY_CONTACTS: PartnerContactRecord[] = [
  {
    id: '0038A00000demoC1',
    name: 'Vishal Thomas',
    title: 'Partner Alliance Administrator',
    email: 'vishal.thomas@partner-example.com',
    phone: '+1 (408) 555-0142',
    accountName: 'Test_DISTI_Account',
    createdDate: '2026-03-14',
  },
  {
    id: '0038A00000demoC2',
    name: 'Elena Rostova',
    title: 'VP of Channel Sales',
    email: 'elena.rostova@partner-example.com',
    phone: '+1 (408) 555-0188',
    accountName: 'Test_DISTI_Account',
    createdDate: '2026-04-09',
  },
  {
    id: '0038A00000demoC3',
    name: 'Marcus Vance',
    title: 'Lead AI Solutions Architect',
    email: 'marcus.vance@partner-example.com',
    phone: '+1 (408) 555-0195',
    accountName: 'Test_DISTI_Account',
    createdDate: '2026-05-21',
  },
  {
    id: '0038A00000demoC4',
    name: 'Priya Nair',
    title: 'MDF & Co-Marketing Manager',
    email: 'priya.nair@partner-example.com',
    phone: '+1 (408) 555-0164',
    accountName: 'Test_DISTI_Account',
    createdDate: '2026-06-30',
  },
];

function mapContactEdges(data: ContactsQueryResponse): PartnerContactRecord[] {
  const edges = data.uiapi?.query?.Contact?.edges ?? [];
  const items: PartnerContactRecord[] = [];
  for (const edge of edges) {
    const node = edge?.node;
    if (!node?.Id) continue;
    items.push({
      id: node.Id,
      name: strVal(node.Name) ?? 'Partner Contact',
      title: strVal(node.Title),
      email: strVal(node.Email),
      phone: strVal(node.Phone),
      accountName: strVal(node.Account?.Name),
      createdDate:
        typeof node.CreatedDate?.value === 'string'
          ? node.CreatedDate.value.slice(0, 10)
          : strVal(node.CreatedDate),
    });
  }
  return items;
}

export async function fetchPartnerContacts(
  accountId?: string | null
): Promise<{ contacts: PartnerContactRecord[]; scope: 'account' | 'org-accessible' | 'sample' }> {
  if (accountId) {
    const accRes = await executeGraphQL<
      ContactsQueryResponse,
      { accountId: string; first: number }
    >(CONTACTS_BY_ACCOUNT_QUERY, { accountId, first: 20 });
    const accContacts = mapContactEdges(accRes);
    if (accContacts.length > 0) {
      return { contacts: accContacts, scope: 'account' };
    }
  }

  const allRes = await executeGraphQL<ContactsQueryResponse, { first: number }>(
    CONTACTS_ALL_QUERY,
    { first: 20 }
  );
  const orgContacts = mapContactEdges(allRes);
  if (orgContacts.length > 0) {
    return { contacts: orgContacts, scope: 'org-accessible' };
  }

  return { contacts: DUMMY_CONTACTS, scope: 'sample' };
}

/* ============================================================================
 * 6. TRAINING CREDITS (Core_Training__c)
 * ========================================================================== */

export interface PartnerTrainingSummary {
  totalCredits: number;
  completedCourses: Array<{
    id: string;
    title: string;
    learnerName: string | null;
    credits: number;
    completedDate: string | null;
  }>;
  scope: 'account' | 'org-accessible' | 'sample';
}

const TRAINING_QUERY = `
  query GetPartnerTrainings($first: Int = 20) {
    uiapi {
      query {
        Core_Training__c(
          first: $first
          orderBy: { CreatedDate: { order: DESC } }
        ) {
          edges {
            node {
              Id
              Name @optional { value displayValue }
              Core_Training_Title__c @optional { value displayValue }
              Core_Training_Credits__c @optional { value displayValue }
              Core_Training_Complete_Date__c @optional { value displayValue }
              Core_First_Name__c @optional { value displayValue }
              Core_Last_Name__c @optional { value displayValue }
            }
          }
        }
      }
    }
  }
`;

interface TrainingQueryResponse {
  uiapi?: {
    query?: {
      Core_Training__c?: {
        edges?: Array<{
          node?: {
            Id?: string;
            Name?: UiField<string>;
            Core_Training_Title__c?: UiField<string>;
            Core_Training_Credits__c?: UiField<number>;
            Core_Training_Complete_Date__c?: UiField<string>;
            Core_First_Name__c?: UiField<string>;
            Core_Last_Name__c?: UiField<string>;
          };
        } | null> | null;
      } | null;
    } | null;
  } | null;
}

export const DUMMY_TRAINING_SUMMARY: PartnerTrainingSummary = {
  totalCredits: 2,
  scope: 'sample',
  completedCourses: [
    {
      id: 'trn-1',
      title: 'Intel® Core™ Ultra Commercial Platform Competency',
      learnerName: 'Partner Team',
      credits: 1,
      completedDate: '2026-10-12',
    },
    {
      id: 'trn-2',
      title: 'Intel® Xeon® 6 Data Center & AI Solutions',
      learnerName: 'Partner Team',
      credits: 1,
      completedDate: '2026-09-28',
    },
  ],
};

export async function fetchPartnerTrainingSummary(): Promise<PartnerTrainingSummary> {
  const res = await executeGraphQL<TrainingQueryResponse, { first: number }>(
    TRAINING_QUERY,
    { first: 20 }
  );
  const edges = res.uiapi?.query?.Core_Training__c?.edges ?? [];
  if (edges.length === 0) {
    return DUMMY_TRAINING_SUMMARY;
  }
  const completedCourses = edges
    .filter(e => e?.node?.Id)
    .map(edge => {
      const node = edge!.node!;
      const first = strVal(node.Core_First_Name__c);
      const last = strVal(node.Core_Last_Name__c);
      return {
        id: node.Id!,
        title:
          strVal(node.Core_Training_Title__c) ??
          strVal(node.Name) ??
          'Partner University Course',
        learnerName: [first, last].filter(Boolean).join(' ') || null,
        credits: numVal(node.Core_Training_Credits__c) ?? 1,
        completedDate: strVal(node.Core_Training_Complete_Date__c),
      };
    });

  return {
    totalCredits: completedCourses.reduce((s, c) => s + c.credits, 0),
    completedCourses,
    scope: 'org-accessible',
  };
}
