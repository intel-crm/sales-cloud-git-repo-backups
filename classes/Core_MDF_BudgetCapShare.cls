/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapShare 
* Version     : 1.0 
* Created Date: 05-03-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P         05/03/2019                   Created Core_MDF_BudgetCapShare for sharing budget cap records
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BudgetCapShare {
    /****************************************************************************************************************************************
Method Name:                                             budgetCapShare
@return  :                                               Void
@parameters:                                             budgetList - List of budgets                                
Description:                                             This method will be invoked by a PB in order to create the Share records for budgetcap 
Added By:                                                Accenture – Harika P  -  05/03/2019
Modified By:                  Date:                      Changes: 
Accenture – Harika P        05/03/2019                   Created. 
Accenture - Varun           04/02/2020                   Updated the if condition in line 95 - Sonar Cube Scan - Empty if condition
*****************************************************************************************************************************************/
    @InvocableMethod
    public static void budgetCapShare(List<PartnerMarketingBudget> budgetList){
        try{
            Map<Id,Id> budgetWithVirtualAccount = new Map<Id,Id>();
            Map<Id,Id> virtualAccWithIntelAcc = new Map<Id,Id>();
            Map<Id,List<Core_MDF_Partner_Group_Mapping__c>> intelAccIdWithGroup = new Map<Id,List<Core_MDF_Partner_Group_Mapping__c>>();
            List<Id> budgetIdList = new List<Id>();
            //List<Id> userorGroupIdToShare = new List<Id> ();
            Map<Id,List<Id>> objectIdUserGroupIdListMapToShare = new Map<Id,List<Id>> ();
            
            // Identifying accounts from budgets
            for (PartnerMarketingBudget pmb : budgetList){
                if(pmb.Core_MDF_Budget_Partner__c != null){
                    budgetWithVirtualAccount.put(pmb.Id, pmb.Core_MDF_Budget_Partner__c);
                    budgetIdList.add(pmb.Id);
                    
                }
                
            }
            for(Account acc: [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Id IN: budgetWithVirtualAccount.values()]){
                if(acc.Core_MDF_CoMarketing_Ultimate_Account__c!= null){
                    virtualAccWithIntelAcc.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                    
                }
            }
            
            //Fetching PGM records and storing them in map with Account
            for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c, Core_MDF_Channel_Program__c
                                                       FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Type_of_Access__c='External' 
                                                       AND Core_MDF_Account__c IN :virtualAccWithIntelAcc.values()
                                                       AND Core_MDF_Inactive_Ind__c = false]){
                                                           
                                                           if(intelAccIdWithGroup.containsKey(pgm.Core_MDF_Account__c)){
                                                               intelAccIdWithGroup.get(pgm.Core_MDF_Account__c).add(pgm);
                                                           }
                                                           else{
                                                               List<Core_MDF_Partner_Group_Mapping__c> tempPGM = 
                                                                   new List<Core_MDF_Partner_Group_Mapping__c>();
                                                               tempPGM.add(pgm);
                                                               intelAccIdWithGroup.put(pgm.Core_MDF_Account__c,tempPGM);
                                                           }
                                                       }
          
            
            //Collecting existing Budget Cap Share Records
            Map<Id,List<Id>> bCapIdWithUserOrGroupId = new Map<Id,List<Id>>();
            
            for(Core_MDF_Budget_Cap__Share bShare: [SELECT Id, ParentId, UserOrGroupId FROM Core_MDF_Budget_Cap__Share
                                                    WHERE Parent.Core_MDF_Budget_Name_id__c IN: budgetIdList]){
                                                    
                                                    if(bCapIdWithUserOrGroupId.containsKey(bShare.ParentId)){
                                                        bCapIdWithUserOrGroupId.get(bShare.ParentId).add(bShare.UserOrGroupId);
                                                    }else{
                                                        List<Id> userOrGroupIdList = new List<Id>();
                                                        userOrGroupIdList.add(bShare.UserOrGroupId);
                                                        bCapIdWithUserOrGroupId.put(bShare.ParentId,userOrGroupIdList);
                                                    }
                                                        
            }
            
            
            
            
            for(Core_MDF_Budget_Cap__c budgetCap :[SELECT Id, Name, Core_MDF_Budget_Name_id__c,
                                                   Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                                   Core_MDF_Program_txt__c FROM Core_MDF_Budget_Cap__c 
                                                   WHERE Core_MDF_Budget_Name_id__c IN : budgetIdList]){
                                                       List<Id> userorGroupIdToShare = new List<Id> ();
                                                       
                                                       Id accountId =budgetCap.Core_MDF_Budget_Name_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c ;
                                                        //ATHR - Deeply Nested if 16209
                                                        if(!intelAccIdWithGroup.containsKey(accountId)){
                                                            continue;
                                                        }
                                                           for(Core_MDF_Partner_Group_Mapping__c pgm1  : intelAccIdWithGroup.get(accountId)){
                                                               //ATHR - Deeply Nested if 16209
                                                               if(budgetCap.Core_MDF_Program_txt__c == null || budgetCap.Core_MDF_Program_txt__c != pgm1.Core_MDF_Channel_Program__c || pgm1.Core_MDF_Group_Id__c == null){
                                                                    continue;
                                                                }
                                                                if(!(bCapIdWithUserOrGroupId.containsKey(budgetCap.Id) && bCapIdWithUserOrGroupId.get(budgetCap.Id) != null && bCapIdWithUserOrGroupId.get(budgetCap.Id).contains(pgm1.Core_MDF_Group_Id__c))){
                                                                    userorGroupIdToShare.add(pgm1.Core_MDF_Group_Id__c);
                                                                }
                                                                
                                                                if(!userorGroupIdToShare.isEmpty()){
                                                                    objectIdUserGroupIdListMapToShare.Put(budgetCap.Id, userorGroupIdToShare);
                                                                }                                                                                                                           
                                                            }
            }
           
            
            if(!objectIdUserGroupIdListMapToShare.isEmpty()){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Budget_Cap__c', objectIdUserGroupIdListMapToShare);
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Budget_Cap__c',objectIdUserGroupIdListMapToShare, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in CCP budgetCapShare method');
        }                
    }
}