import { gql } from '@salesforce/platform-sdk/data';

export const GET_OPPORTUNITIES_QUERY = gql`
  query GetOpportunities($first: Int = 5, $stage: String) {
    uiapi {
      query {
        Opportunity(
          first: $first, 
          where: { StageName: { eq: $stage } }
        ) {
          edges {
            node {
              Id
              Name {
                value
              }
              StageName {
                value
              }
              Amount {
                value
              }
            }
          }
        }
      }
    }
  }
`;