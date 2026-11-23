@isTest
public class Core_MDF_ObjectQuery_Mock_Utility {
    
    public static List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> getMockQueriesFor3Objects() {
        
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> mockList =
            new List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery>();
        // Common sample mock values for all 3 objects
        List<String> fields = new List<String>{ 
            'Id', 
            'Name', 
            'Core_MDF_Approval_Stage_nm__c',
            'Core_MDF_Program__c',
            'Core_MDF_Opal_Budget_Type_Txt__c'
        };
        
        Map<String, String> stageToRole = new Map<String, String>{
            'Stage1' => 'RoleA'
        };
        
        Map<String, String> pnumStageToRole = new Map<String, String>{
            'PStage1' => 'PRole'
        };
        
        Map<String, Map<String, List<String>>> programRoles =
            new Map<String, Map<String, List<String>>>{
                'ProgramA' => new Map<String, List<String>>{
                    'Stage1' => new List<String>{ 'RoleX' }
                }
            };
        
        Map<String, Map<String, String>> geoRoles =
            new Map<String, Map<String, String>>{
                'ProgramA' => new Map<String, String>{
                    'India' => 'GeoRole1'
                }
            };
        
        Map<String, Map<String, String>> budgetQueue =
            new Map<String, Map<String, String>>{
                'ProgramA' => new Map<String, String>{
                    'BudgetX' => 'QueueX'
                }
            };
        
        Map<String, Map<String, String>> publicGrp =
            new Map<String, Map<String, String>>{
                'ProgramA' => new Map<String, String>{
                    'BudgetY' => 'GrpY'
                }
            };

        // ------------------
        // Object 1 — PartnerMarketingBudget
        // ------------------
        mockList.add(new Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery(
            'Campaign',
            'Core_MDF_Reimbursement_Amt__c = 1000',
            fields,
            stageToRole,
            pnumStageToRole,
            programRoles,
            geoRoles,
            budgetQueue,
            publicGrp
        ));

        // ------------------
        // Object 2 — PartnerFundRequest
        // ------------------
      /*  mockList.add(new Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery(
            'Campaign',
            'Core_MDF_Approval_Stage__c != null',
            fields,
            stageToRole,
            pnumStageToRole,
            programRoles,
            geoRoles,
            budgetQueue,
            publicGrp
        ));*/

        // ------------------
        // Object 3 — Campaign
        // ------------------
       /* mockList.add(new Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery(
            'Campaign',
            'IsActive = true',
            fields,
            stageToRole,
            pnumStageToRole,
            programRoles,
            geoRoles,
            budgetQueue,
            publicGrp
        ));*/

        return mockList;
    }
}