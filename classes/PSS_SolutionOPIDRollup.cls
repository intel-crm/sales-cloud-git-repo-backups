/**************************************************************************************
Apex Class Name : PSS_SolutionOPIDRollup
Version     : 1.0 
Created Date: 26th July, 2021
Description : Rollup Solution to OPID when OPID/Solution is created/updated/deleted  
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Onyx Team(Infosys)                  26/07/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public With Sharing class PSS_SolutionOPIDRollup {
    //Method to populate the OPID and location account on Solution when an OPID is created/updated
    // public static void populateOPIDOnSolution(List<Core_Account_Group_Member__c> newList,Map<Id,Core_Account_Group_Member__c> oldMap,string indetifyTrigger){
    //     try{
    //         // This will be executed when OPID is created for location account.
    //         if (indetifyTrigger == 'insert'){
    //             Map<Id,Id> locationAccId = new Map<Id,Id>();
    //             Map<Id, List<ArdiraSurvey__Survey_Result__c>> accIdAndSurveyResults = new Map<Id, List<ArdiraSurvey__Survey_Result__c>>();
    //             List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //             if(!newList.isEmpty()){
    //                 for(Core_Account_Group_Member__c cagm: newList){
    //                     if(!cagm.Core_Inactive_Ind__c){
    //                         locationAccId.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                     }
    //                 }
    //             }
    //             if(locationAccId !=null){
    //                 List<ArdiraSurvey__Survey_Result__c> partnerSolutionsList = [Select Id,PSS_Partner_Account_Id__c,
    //                                                                              PSS_OPID_Account_Id__c,PSS_Company_Id__c  
    //                                                                              from ArdiraSurvey__Survey_Result__c  
    //                                                                              where PSS_Partner_Account_Id__c  
    //                                                                              IN :locationAccId.keyset()];
                    
    //                 for(ArdiraSurvey__Survey_Result__c result : partnerSolutionsList){
    //                     if(locationAccId.keyset().contains(result.PSS_Partner_Account_Id__c)){
    //                         result.PSS_OPID_Account_Id__c = locationAccId.get(result.PSS_Partner_Account_Id__c);
    //                         surveyResultList.add(result);
    //                     }
    //                 }
    //             }
    //             if(surveyResultList.size()>0){
    //                 update surveyResultList;
    //             }
    //         }
    //         // This will be executed when OPID is updated for location account.
    //         else if (indetifyTrigger == 'update'){
    //             Map<Id,Id> inactiveLocationAccId = new Map<Id,Id>();
    //             Map<Id,Id> locAccId = new Map<Id,Id>();
    //             Map<Id,Id> oldLocAccId = new Map<Id,Id>();
    //             Id opidToNull = null;
    //             List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //             for(Core_Account_Group_Member__c cagm: newList){
    //                 //When OPID is updated for Location Account
    //                 //if new intel account Id is not equal to old intel Id and the OPID is active
    //                 if(cagm.Core_Intel_Account_Id__c != oldMap.get(cagm.id).Core_Intel_Account_Id__c && cagm.Core_Inactive_Ind__c == false){
    //                     locAccId.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                     oldLocAccId.put(oldMap.get(cagm.id).Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                 }
    //                 //When OPID is inactivated
    //                 else if(cagm.Core_Inactive_Ind__c == false && oldMap.get(cagm.id).Core_Inactive_Ind__c == true){
    //                     locAccId.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                 }
    //                 //When OPID is re-activated
    //                 else if(cagm.Core_Inactive_Ind__c == true && oldMap.get(cagm.id).Core_Inactive_Ind__c == false){
    //                     inactiveLocationAccId.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                 }
    //             }
                
    //             if((oldLocAccId !=null && !oldLocAccId.isEmpty())||
    //                (locAccId !=null && !locAccId.isEmpty())||
    //                (inactiveLocationAccId != null && !inactiveLocationAccId.isEmpty())){
    //                    List<ArdiraSurvey__Survey_Result__c> solutionsList = [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c  
    //                                                                          from ArdiraSurvey__Survey_Result__c  
    //                                                                          where PSS_Partner_Account_Id__c  
    //                                                                          IN :oldLocAccId.keyset() OR PSS_Partner_Account_Id__c  
    //                                                                          IN :locAccId.keyset() OR PSS_Partner_Account_Id__c  
    //                                                                          IN :inactiveLocationAccId.keyset()];
    //                    if((oldLocAccId !=null && !oldLocAccId.isEmpty())||
    //                       (locAccId !=null && !locAccId.isEmpty())||
    //                       (inactiveLocationAccId != null && !inactiveLocationAccId.isEmpty())){
    //                           for(ArdiraSurvey__Survey_Result__c result : solutionsList){
    //                               if(oldLocAccId.keyset().contains(result.PSS_Partner_Account_Id__c) 
    //                                  || inactiveLocationAccId.keyset().contains(result.PSS_Partner_Account_Id__c)){
    //                                      result.PSS_OPID_Account_Id__c = opidToNull;
    //                                      surveyResultList.add(result);
    //                                  }
    //                               else if(locAccId.keyset().contains(result.PSS_Partner_Account_Id__c)){
    //                                   result.PSS_OPID_Account_Id__c = locAccId.get(result.PSS_Partner_Account_Id__c);
    //                                   surveyResultList.add(result);
    //                               } 
    //                           }
    //                       } 
    //                }
    //             if(surveyResultList.size()>0 && !surveyResultList.isEmpty()){
    //                 update surveyResultList;
    //             }
    //         }
    //     }
    //     catch(Exception e){
    //         throw(e);
    //     }   
    // }
    
    // //Method to populate MPI on Solution when MPI is created.
    // public static void populateMPIOnSolution(List<PMP_Company__c> newList){
        
    //     Set<Id> companyIds = new Set<Id>();
        
    //     if(!newList.isEmpty()){
    //         for(PMP_Company__c company: newList){
    //             companyIds.add(company.Id);
    //         }
    //         if(!companyIds.isEmpty()){
    //             if(system.isBatch() || system.isFuture()){
    //                 populateMPIOnSlutionSynchronously(companyIds);
    //             }
    //             else{
    //                 populateMPIOnSlutionAsynchronously(companyIds); 
    //             }
    //         }
    //     }
    // }
    
    // public static void populateMPIOnSlutionSynchronously(Set<Id> cmpIds){
        
    //     List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveyResultListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<PMP_Company__c> companyListWithAcc = new List<PMP_Company__c>();
    //     Map<Id,Id> companyOPIDId = new Map<Id,Id>();
    //     Map<Id,Id> companyLocId = new Map<Id,Id>();
    //     Set<Id> companyOnSolution = new Set<Id>();
    //     Set<Id> accountId = new Set<Id>();
    //     Set<Id> pagAccountIds = new Set<Id>();
    //     Set<Id> intelAccountIds = new Set<Id>();
    //     Set<Id> companyList = new Set<Id>();
    //     List<PMP_OPID_MPI_Rel__c> opidMpiList = new List<PMP_OPID_MPI_Rel__c>();
        
    //     //START : added by Krishna as part of OPID new changes.
    //     If(!cmpIds.isEmpty() && Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
    //         opidMpiList =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
    //                       PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
    //                       PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false and
    //                       /*PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and*/ PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and PMP_Marketing_Profile_Id__c in :cmpIds];
    //     }
    //     if(!opidMpiList.isEmpty()){
    //         for(PMP_OPID_MPI_Rel__c opIDMpi : opidMpiList){
    //             if(opIDMpi.PMP_One_Partner_ID__c != null && opIDMpi.PMP_One_Partner_ID__r.RecordType.Name == PSS_StaticConstants.PARTNER_ACCOUNT_GROUP){
    //                 companyOPIDId.put(opIDMpi.PMP_One_Partner_ID__c,opIDMpi.PMP_Marketing_Profile_Id__c);
    //             }
    //             else if(opIDMpi.PMP_One_Partner_ID__c != null && opIDMpi.PMP_One_Partner_ID__r.RecordType.Name == PSS_StaticConstants.INTEL_ACCOUNT){
    //                 companyLocId.put(opIDMpi.PMP_One_Partner_ID__c,opIDMpi.PMP_Marketing_Profile_Id__c);
    //             }
                
    //         }
            
    //     }
    //     //End :added by Krishna as part of OPID new changes.
    //     if(!companyLocId.keyset().isEmpty() || !companyOPIDId.keyset().isEmpty()){ 
    //         surveyResultList = [Select Id,Name,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,PSS_Company_Id__c 
    //                             from ArdiraSurvey__Survey_Result__c where PSS_OPID_Account_Id__c IN: companyOPIDId.keyset()
    //                             OR PSS_Partner_Account_Id__c In: companyLocId.keyset()];
    //     }
    //     if(!surveyResultList.isEmpty()){
            
    //         for(ArdiraSurvey__Survey_Result__c result:surveyResultList){
    //             if(result.PSS_OPID_Account_Id__c != null && companyOPIDId.get(result.PSS_OPID_Account_Id__c)!=null){
    //                 result.PSS_Company_Id__c = companyOPIDId.get(result.PSS_OPID_Account_Id__c);
    //             }
    //             else if(result.PSS_Partner_Account_Id__c != null && companyLocId.get(result.PSS_Partner_Account_Id__c)!=null){
    //                 result.PSS_Company_Id__c = companyLocId.get(result.PSS_Partner_Account_Id__c);
    //             }
    //             surveyResultListToUpdate.add(result);
    //         }
    //     }
    //     if(!surveyResultListToUpdate.isEmpty()){
    //         update surveyResultListToUpdate;
    //     }
        
    // }
    // @future
    // public static void populateMPIOnSlutionAsynchronously(Set<Id> cmpIds){
    //     populateMPIOnSlutionSynchronously(cmpIds);
    // }
    // public static void updateMPIOnSlution(List<PMP_Company__c> newList,Map<Id,PMP_Company__c> oldMap){
        
    //     //On status change from Draft to Published OR On Inactive indicator from true to false -Start
    //     Set<Id> companyIdsOnUpdate = new Set<Id>();
    //     for(PMP_Company__c company: newList){
    //         if((/*((company.PMP_Company_Lifecycle_Status_Nm__c != oldMap.get(company.Id).PMP_Company_Lifecycle_Status_Nm__c) && company.PMP_Company_Lifecycle_Status_Nm__c == 'Published')||*/
    //             ((company.PMP_Benefit_Update_Ind__c != oldMap.get(company.Id).PMP_Benefit_Update_Ind__c) && company.PMP_Benefit_Update_Ind__c == false)) || Test.isRunningTest()){
    //                 companyIdsOnUpdate.add(company.Id);
    //             }
    //     }
    //     if(!companyIdsOnUpdate.isEmpty()){
    //         if(system.isBatch() || system.isFuture()){
    //             updateMPIOnSlutionSynchronously(companyIdsOnUpdate);
    //         }
    //         else{
    //             updateMPIOnSlutionAsynchronously(companyIdsOnUpdate); 
    //         }
    //     }
    //     Set<Id> companyIdsOnRevoked = new Set<Id>();
    //     for(PMP_Company__c company: newList){
    //         if(((company.PMP_Benefit_Update_Ind__c != oldMap.get(company.Id).PMP_Benefit_Update_Ind__c) && company.PMP_Benefit_Update_Ind__c == true) || Test.isRunningTest()){
    //             companyIdsOnRevoked.add(company.Id);
    //         }
    //     }
    //     if(!companyIdsOnRevoked.isEmpty()){
    //         if(system.isBatch() || system.isFuture()){
    //             updateMPIOnSlutionSynchronously(companyIdsOnRevoked);
    //         }
    //         else{
    //             updateMPIOnSlutionAsynchronously(companyIdsOnRevoked); 
    //         }
    //     }
        
    // }
    // @future
    // public static void updateMPIOnSlutionAsynchronously(Set<Id> compId){
    //     updateMPIOnSlutionSynchronously(compId);
    // }
    
    // public static void updateMPIOnSlutionSynchronously(Set<Id> compId){
        
    //     List<PMP_Company__c> companyListWithAcc = new List<PMP_Company__c>();
    //     List<PMP_Company__c> companyListWithRevoked = new List<PMP_Company__c>();
    //     Map<Id,Id> mapOfCompanyAccOPID = new Map<Id,Id>();
    //     Map<Id,Id> mapOfCompanyAccLoc = new Map<Id,Id>();
    //     Map<Id,Id> companyOPIDId = new Map<Id,Id>();
    //     Map<Id,Id> companyLocId = new Map<Id,Id>();
    //     Set<Id> revokedOpIds = new Set<Id>();
    //     List<PMP_OPID_MPI_Rel__c> opidMpiList = new List<PMP_OPID_MPI_Rel__c>();
    //     List<PMP_OPID_MPI_Rel__c> locatMpiList = new List<PMP_OPID_MPI_Rel__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveyListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //     if(!compId.isEmpty()){
    //         companyListWithAcc = [Select Id,PMP_Account_Id__c,PMP_Account_Id__r.RecordType.name,PMP_Is_Published_Ind__c, PMP_Benefit_Update_Ind__c, PMP_Company_Lifecycle_Status_Nm__c 
    //                               from PMP_Company__c where PMP_Is_Published_Ind__c = true AND PMP_Benefit_Update_Ind__c = false 
    //                               AND /*PMP_Company_Lifecycle_Status_Nm__c = 'Published' AND */ Id IN : compId];
    //     }
    //     if(!companyListWithAcc.isEmpty()){
    //         populateMPIOnSolution(companyListWithAcc);
    //     }
    //     //On status change from Draft to Published OR On Inactive indicator from true to false - End
    //     //On Inactive indicator from false to true - Start
    //     if(!compId.isEmpty()){
    //         companyListWithRevoked = [Select Id,PMP_Account_Id__c,PMP_Account_Id__r.RecordType.name,PMP_Is_Published_Ind__c, PMP_Benefit_Update_Ind__c, PMP_Company_Lifecycle_Status_Nm__c 
    //                                   from PMP_Company__c where PMP_Is_Published_Ind__c = true AND PMP_Benefit_Update_Ind__c = true 
    //                                   AND /*PMP_Company_Lifecycle_Status_Nm__c = 'Published' AND */Id IN : compId];
    //     }
    //     //added by krishna for new OPID changes.
    //     set<string> cmpRevokedIds= new set<string>();
    //     if(!companyListWithRevoked.isEmpty()){
    //         for(PMP_Company__c company:companyListWithRevoked){
    //             cmpRevokedIds.add(company.id);
    //         }
    //     }
    //     If(!cmpRevokedIds.isEmpty() && Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){
    //         opidMpiList =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
    //                       PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
    //                       PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = true and
    //                       /*PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and */PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and PMP_Marketing_Profile_Id__c in :cmpRevokedIds];
    //     }
    //     if(!opidMpiList.isEmpty()){
    //         for(PMP_OPID_MPI_Rel__c opIDMpi : opidMpiList){
    //             if(opIDMpi.PMP_One_Partner_ID__c != null && opIDMpi.PMP_One_Partner_ID__r.RecordType.Name == PSS_StaticConstants.PARTNER_ACCOUNT_GROUP ){
    //                 companyOPIDId.put(opIDMpi.PMP_One_Partner_ID__c,opIDMpi.PMP_Marketing_Profile_Id__c);
    //             }
    //             else if(opIDMpi.PMP_One_Partner_ID__c != null && opIDMpi.PMP_One_Partner_ID__r.RecordType.Name == PSS_StaticConstants.INTEL_ACCOUNT ){
    //                 companyLocId.put(opIDMpi.PMP_One_Partner_ID__c,opIDMpi.PMP_Marketing_Profile_Id__c);
    //             }
                
    //         }
            
    //     }
    //     list<Core_Account_Group_Member__c> agmList = new list<Core_Account_Group_Member__c>();
    //     Set<Id> agmLocationAccIds = new Set<Id>();
    //     if(!companyOPIDId.isempty()){
    //         agmList =[select id,Name,Core_Intel_Account_Id__c,Core_Partner_Account_Id__c from Core_Account_Group_Member__c where Core_Inactive_Ind__c = False AND Core_Partner_Account_Id__c in:companyOPIDId.keyset()];
    //     }
    //     if(!agmList.isempty()){
            
    //         for(Core_Account_Group_Member__c agm : agmList){
    //             agmLocationAccIds.add(agm.Core_Intel_Account_Id__c);
    //         }
    //     }
        
    //     Map<Id,id> LocationActiveCompMap = new Map<id,id>();
    //     list<PMP_Company__c> companyListLocatWithActive = new list<PMP_Company__c>();
    //     if(!agmLocationAccIds.isempty()){
    //         locatMpiList =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
    //                        PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
    //                        PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false and
    //                        /*PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and*/ PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and 
    //                        PMP_One_Partner_ID__r.RecordType.Name=: PSS_StaticConstants.INTEL_ACCOUNT and PMP_One_Partner_ID__c in :agmLocationAccIds];
            
    //     }   
 
    //     if(!locatMpiList.isEmpty()){
    //         for(PMP_OPID_MPI_Rel__c cmpOpid : locatMpiList){
                
    //             LocationActiveCompMap.put(cmpOpid.PMP_One_Partner_ID__c,cmpOpid.PMP_Marketing_Profile_Id__c);
    //         }
    //     }
        
    //     If(!companyOPIDId.isEmpty() || !companyLocId.isEmpty()){
    //         surveyResultList = [Select Id,Name,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,PSS_Company_Id__c 
    //                             from ArdiraSurvey__Survey_Result__c where PSS_OPID_Account_Id__c IN: companyOPIDId.keyset()
    //                             OR PSS_Partner_Account_Id__c In: companyLocId.keyset()];
    //     }
    //     if(!surveyResultList.isEmpty()){
    //         for(ArdiraSurvey__Survey_Result__c survey : surveyResultList){
    //             if(survey.PSS_OPID_Account_Id__c != null && companyOPIDId.containskey(survey.PSS_OPID_Account_Id__c)){
    //                 if(survey.PSS_Partner_Account_Id__c != null && (!(companyLocId.Containskey(survey.PSS_Partner_Account_Id__c)) && (LocationActiveCompMap.Containskey(survey.PSS_Partner_Account_Id__c)))){
    //                     survey.PSS_Company_Id__c = LocationActiveCompMap.get(survey.PSS_Partner_Account_Id__c);
    //                 }
    //                 else {
    //                     survey.PSS_Company_Id__c = null;
    //                 }
    //             }
    //             else if(survey.PSS_OPID_Account_Id__c == null && (survey.PSS_Partner_Account_Id__c != null && companyLocId.keyset().contains(survey.PSS_Partner_Account_Id__c))) {
    //                 survey.PSS_Company_Id__c = null;
    //             }
    //             else {
    //                 survey.PSS_Company_Id__c = null;
    //             }
    //             surveyListToUpdate.add(survey);
    //         }
    //     }
    //     if(!surveyListToUpdate.isEmpty()){
    //         update surveyListToUpdate;
    //     }
    // }
    
    // //Method to delete OPID field on Solution when OPID is deleted
    // public static void removeOPIDFromSolutionOnDeletion(List<Core_Account_Group_Member__c> lstOfOPIDGrpMbr){
    //     Map<Id,Id> locationAccId = new Map<Id,Id>();
    //     Id opidId = null;
    //     List<ArdiraSurvey__Survey_Result__c> surveyResultList = new List<ArdiraSurvey__Survey_Result__c>();
    //     for(Core_Account_Group_Member__c cagm: lstOfOPIDGrpMbr){
    //         locationAccId.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //     }
    //     if(locationAccId !=null){
    //         List<ArdiraSurvey__Survey_Result__c> surveyList = [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c  
    //                                                            from ArdiraSurvey__Survey_Result__c  
    //                                                            where PSS_Partner_Account_Id__c  
    //                                                            IN :locationAccId.keyset()];
    //         for(ArdiraSurvey__Survey_Result__c result : surveyList){
    //             if(locationAccId.keyset().contains(result.PSS_Partner_Account_Id__c)){
    //                 result.PSS_OPID_Account_Id__c = opidId;
    //                 surveyResultList.add(result);
    //             }  
    //         }
    //     }
    //     if(surveyResultList.size()>0 && !surveyResultList.isEmpty()){
    //         update surveyResultList;
    //     }
    // }
    
    // //Method to update Account details on Solution when Solution is created
    // public static void updateAccountDetails(List<ArdiraSurvey__Survey_Result__c> surveyResult){
        
    //     Set<Id> contactId = new Set<Id>();
    //     Set<Id> companyId = new Set<Id>();
    //     Map<Id,Id> contactLocAccountMap = new Map<Id,Id>();
    //     Map<Id,Id> contactPAGAccountMap = new Map<Id,Id>();
    //     Map<Id,Id> companyLocAccountMap = new Map<Id,Id>();
    //     Map<Id,Id> locWithOPID = new Map<Id,Id>();
    //     Map<Id,Id> opidWithLocation = new Map<Id,Id>();
    //     Set<Id> accountIds = new Set<Id>();
    //     Set<Id> surveyIds = new Set<Id>();
    //     Set<string> locOpidAccIds = new Set<string>();
    //     List<ArdiraSurvey__Survey_Result__c> surveysWithContact = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveysWithOutContact = new List<ArdiraSurvey__Survey_Result__c>();
    //     if(surveyResult != null && surveyResult.size() > 0) {
    //         Map<Id, List<ArdiraSurvey__Survey_Result__c>> accIdAndSurveyResults = new Map<Id, List<ArdiraSurvey__Survey_Result__c>>();
    //         for(ArdiraSurvey__Survey_Result__c survey : surveyResult){
    //             surveyIds.add(survey.Id);
    //             if(survey.ArdiraSurvey__Assigned_To_Contact__c != null){
    //                 contactId.add(survey.ArdiraSurvey__Assigned_To_Contact__c);
    //                 surveysWithContact.add(survey);
    //             }
                
    //             else {
    //                 companyId.add(survey.PSS_Company_Id__c);
    //                 surveysWithOutContact.add(survey);
    //             }
    //         }
    //         if(!contactId.isEmpty()){
    //             for(Contact con : [Select Id,AccountId,Account.recordtype.DeveloperName from Contact where Id IN : contactId]){
    //                 if(con.AccountId != null){
    //                     if(con.Account.recordtype.DeveloperName == PSS_StaticConstants.PAG_ACCOUNT_DEVELOPERNAME){
    //                         contactPAGAccountMap.put(con.Id,con.AccountId);
    //                         accountIds.add(con.AccountId);
    //                         locOpidAccIds.add(con.AccountId);
    //                     }
    //                     else if(con.Account.recordtype.DeveloperName == PSS_StaticConstants.INTEL_ACCOUNT_DEVELOPERNAME){
    //                         contactLocAccountMap.put(con.Id,con.AccountId);
    //                         accountIds.add(con.AccountId);
    //                         locOpidAccIds.add(con.AccountId);
    //                     }
    //                 }
    //             }
                
    //         }
            
    //         Map<string,string> compAccIds = new Map<string,string>();
    //         if(!accountIds.isEmpty()){
    //             for(Core_Account_Group_Member__c cagm :[Select Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
    //                                                     from Core_Account_Group_Member__c 
    //                                                     where Core_Inactive_Ind__c = False AND (Core_Partner_Account_Id__c IN : accountIds 
    //                                                     OR Core_Intel_Account_Id__c IN : accountIds)]){
    //                                                         locWithOPID.put(cagm.Core_Intel_Account_Id__c,cagm.Core_Partner_Account_Id__c);
    //                                                         opidWithLocation.put(cagm.Core_Partner_Account_Id__c,cagm.Core_Intel_Account_Id__c);
    //                                                         locOpidAccIds.add(cagm.Core_Intel_Account_Id__c);
    //                                                         locOpidAccIds.add(cagm.Core_Partner_Account_Id__c);
    //                                                     }
                
    //         }
    //         //added by krishna ch for company name display
    //         if(!locOpidAccIds.isEmpty()){
    //             for(PMP_OPID_MPI_Rel__c opidMPI : [select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
    //                                                PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
    //                                                PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false and
    //                                               /* PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and*/ PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and 
    //                                                PMP_One_Partner_ID__c in :locOpidAccIds]){
                                                       
    //                                                    compAccIds.put(opidMPI.PMP_One_Partner_ID__c,opidMPI.PMP_Marketing_Profile_Id__c);  
    //                                                } 
    //         }
            
    //         if(!surveysWithContact.isEmpty()){
    //             for(ArdiraSurvey__Survey_Result__c sr : surveysWithContact){
    //                 if(!contactLocAccountMap.isEmpty() && contactLocAccountMap.containsKey(sr.ArdiraSurvey__Assigned_To_Contact__c)){
    //                     sr.PSS_Partner_Account_Id__c = contactLocAccountMap.get(sr.ArdiraSurvey__Assigned_To_Contact__c);
    //                     if(!locWithOPID.isEmpty() && locWithOPID.containsKey(sr.PSS_Partner_Account_Id__c)){
    //                         sr.PSS_OPID_Account_Id__c = locWithOPID.get(sr.PSS_Partner_Account_Id__c);
    //                     }
                        
    //                 }
    //                 else if(!contactPAGAccountMap.isEmpty() && contactPAGAccountMap.containsKey(sr.ArdiraSurvey__Assigned_To_Contact__c)){
    //                     sr.PSS_OPID_Account_Id__c = contactPAGAccountMap.get(sr.ArdiraSurvey__Assigned_To_Contact__c);
    //                     if(!opidWithLocation.isEmpty() && opidWithLocation.containsKey(sr.PSS_OPID_Account_Id__c)){
    //                         sr.PSS_Partner_Account_Id__c = opidWithLocation.get(sr.PSS_OPID_Account_Id__c);
                            
    //                     }
    //                 }
                    
    //             }
    //         }
    //         //added by krishna ch for company name display
    //         if(!surveysWithContact.isEmpty()){
    //             for(ArdiraSurvey__Survey_Result__c sr : surveysWithContact){
                    
    //                 sr.PSS_Partner_Account_Id__c = contactLocAccountMap.get(sr.ArdiraSurvey__Assigned_To_Contact__c);
    //                 if(!compAccIds.isEmpty() && compAccIds.containskey(locWithOPID.get(sr.PSS_Partner_Account_Id__c))){
    //                     sr.PSS_Company_Id__c = compAccIds.get(locWithOPID.get(sr.PSS_Partner_Account_Id__c)); 
    //                 }
    //                 else if(!compAccIds.isEmpty() && compAccIds.containskey(sr.PSS_Partner_Account_Id__c)){
                        
    //                     sr.PSS_Company_Id__c = compAccIds.get(sr.PSS_Partner_Account_Id__c);
    //                 }
    //             }
    //         }
    //     }
    // }
    // //new opidmpi added and updated logic on solution by Krishna ch
    // public static void populateMPIOPIDOnSolution(List<PMP_OPID_MPI_Rel__c> newList,Map<Id,PMP_OPID_MPI_Rel__c> oldMap,Boolean isInsert,Boolean isUpdate){
    //     Set<Id> inactiveOpIds = new Set<Id>();
    //     Set<Id> reActivedOpIds = new Set<Id>();
    //     Map<Id,Id> locatOPIDAccIdsMap = new Map<Id,Id>();
    //     Set<Id> mpiIds = new Set<Id>();
    //     Map<Id,Id> opidMPIMap = new Map<Id,Id>();
    //     Map<Id,Id> mpiOPIDMap = new Map<Id,Id>();
    //     Map<Id,Id> mpiOPIDActiveMap = new Map<Id,Id>();
    //     List<ArdiraSurvey__Survey_Result__c> solutionListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<ArdiraSurvey__Survey_Result__c> solutionListToInsert = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<PMP_Company__c> cmpList = new List<PMP_Company__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveyList = new List<ArdiraSurvey__Survey_Result__c>();
    //     if(!newList.isEmpty() && isInsert){
    //         for(PMP_OPID_MPI_Rel__c opidMPI : newList){
    //             if(opidMPI.Is_Active__c == true && opidMPI.PMP_One_Partner_ID__c != NULL){
    //                 opidMPIMap.put(opidMPI.PMP_One_Partner_ID__c,opidMPI.PMP_Marketing_Profile_Id__c);
    //             }
    //         }    
            
    //         if(!opidMPIMap.Keyset().isempty()){
    //             surveyList = [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,PSS_Company_Id__c  
    //                           from ArdiraSurvey__Survey_Result__c  
    //                           where PSS_OPID_Account_Id__c  
    //                           IN :opidMPIMap.Keyset()];
    //             for(ArdiraSurvey__Survey_Result__c survey:surveyList){
    //                 if(survey.PSS_OPID_Account_Id__c != NULL && opidMPIMap.containsKey(survey.PSS_OPID_Account_Id__c)){
    //                     survey.PSS_Company_Id__c=opidMPIMap.get(survey.PSS_OPID_Account_Id__c);
    //                     solutionListToInsert.add(survey);
    //                 }
                    
    //             }
                
    //         }
    //         if(!solutionListToInsert.isempty()){
    //             PSS_StaticConstants.opIDTriggerLogicStop = False;
    //             update solutionListToInsert;
    //             PSS_StaticConstants.opIDTriggerLogicStop = True;
    //         }
            
    //     }
    //     if(!newList.isEmpty() && isUpdate){
    //         for(PMP_OPID_MPI_Rel__c opidMPI : newList){
    //             if((opidMPI.Is_Active__c == False && opidMPI.PMP_One_Partner_ID__c != NULL 
    //                && (opidMPI.Is_Active__c != oldMap.get(opidMPI.id).Is_Active__c )) ||Test.isRunningTest() ){ 
    //                    inactiveOpIds.add(opidMPI.PMP_One_Partner_ID__c);
    //                }
    //             else if(opidMPI.Is_Active__c == True && opidMPI.PMP_One_Partner_ID__c != NULL 
    //                     && (opidMPI.Is_Active__c != oldMap.get(opidMPI.id).Is_Active__c)){
    //                         reActivedOpIds.add(opidMPI.PMP_One_Partner_ID__c);
    //                         mpiOPIDActiveMap.put(opidMPI.PMP_One_Partner_ID__c,opidMPI.PMP_Marketing_Profile_Id__c);
    //                     }
    //         } 
            
    //         if(!inactiveOpIds.isEmpty()){
    //             updateMPIOPIDOnSolution(inactiveOpIds);
    //         } 
            
    //         if(!mpiOPIDActiveMap.keySet().isEmpty()){
    //             for(ArdiraSurvey__Survey_Result__c sur : [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,PSS_Company_Id__c  
    //                                                       from ArdiraSurvey__Survey_Result__c  
    //                                                       where PSS_Partner_Account_Id__c  
    //                                                       IN :mpiOPIDActiveMap.keySet() OR PSS_OPID_Account_Id__c in :mpiOPIDActiveMap.keySet()]){
                                                              
    //                                                           if(sur.PSS_OPID_Account_Id__c != NULL && mpiOPIDActiveMap.containskey(sur.PSS_OPID_Account_Id__c)){
    //                                                               sur.PSS_Company_Id__c = mpiOPIDActiveMap.get(sur.PSS_OPID_Account_Id__c);
    //                                                           }
    //                                                           else if(sur.PSS_Partner_Account_Id__c != NULL && mpiOPIDActiveMap.containskey(sur.PSS_Partner_Account_Id__c)){
    //                                                               sur.PSS_Company_Id__c = mpiOPIDActiveMap.get(sur.PSS_Partner_Account_Id__c);
    //                                                           }
    //                                                           else{
    //                                                               sur.PSS_Company_Id__c = NULL;
    //                                                           }
    //                                                           solutionListToUpdate.add(sur);
    //                                                       }
    //         }
    //         if(!solutionListToUpdate.isEmpty()){
    //             PSS_StaticConstants.opIDTriggerLogicStop = False;
    //             update solutionListToUpdate;
    //             PSS_StaticConstants.opIDTriggerLogicStop = True;
    //         }
            
    //     } 
        
    // }
    
    // public static void updateMPIOPIDOnSolution(Set<Id> opIDs){
    //     Set<Id> locatAccIds = new Set<Id>();
    //     Map<Id,Id> activeLocationMPIMap = new Map<Id,Id>();
    //     List<PMP_OPID_MPI_Rel__c> locatMpiList=new List<PMP_OPID_MPI_Rel__c>();
    //     List<PMP_Company__c> cmpList=new List<PMP_Company__c>();
    //     List<ArdiraSurvey__Survey_Result__c> solutionListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //     List<ArdiraSurvey__Survey_Result__c> surveyList = new List<ArdiraSurvey__Survey_Result__c>();
        
    //     if(!opIDs.isempty()){
    //         for(Core_Account_Group_Member__c agm :[Select Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
    //                                                from Core_Account_Group_Member__c 
    //                                                where Core_Inactive_Ind__c = False AND (Core_Partner_Account_Id__c IN : opIDs OR Core_Intel_Account_Id__c IN :opIDs)]){
                                                       
    //                                                    locatAccIds.add(agm.Core_Intel_Account_Id__c);    
    //                                                }
            
    //         if(!locatAccIds.isempty()){
                
    //             locatMpiList =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name,PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
    //                            PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c, 
    //                            PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.DeveloperName from PMP_OPID_MPI_Rel__c where Is_Active__c = true and PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false and
    //                            PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published' and PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true and 
    //                            PMP_One_Partner_ID__r.RecordType.DeveloperName=: PSS_StaticConstants.INTEL_ACCOUNT_DEVELOPERNAME and PMP_One_Partner_ID__c in :locatAccIds];
                
    //             for(PMP_OPID_MPI_Rel__c opid : locatMpiList){
    //                 if(opid.PMP_One_Partner_ID__c != NULL && opid.PMP_One_Partner_ID__r.recordtype.DeveloperName == PSS_StaticConstants.INTEL_ACCOUNT_DEVELOPERNAME){
    //                     activeLocationMPIMap.put(opid.PMP_One_Partner_ID__c,opid.PMP_Marketing_Profile_Id__c);
    //                 }
    //             }
                
    //         }
            
    //         if(!opIDs.isEmpty()){
                
    //             surveyList = [Select Id,PSS_Partner_Account_Id__c,PSS_OPID_Account_Id__c,PSS_Company_Id__c  
    //                           from ArdiraSurvey__Survey_Result__c  
    //                           where PSS_OPID_Account_Id__c  
    //                           IN :opIDs];
    //         }
            
    //         for(ArdiraSurvey__Survey_Result__c survey : surveyList){
    //             if(survey.PSS_Partner_Account_Id__c != NULL 
    //                && activeLocationMPIMap.containsKey(survey.PSS_Partner_Account_Id__c)){
    //                    survey.PSS_Company_Id__c =  activeLocationMPIMap.get(survey.PSS_Partner_Account_Id__c);
    //                }
    //             else{
    //                 survey.PSS_Company_Id__c = NULL;
    //             }
    //             solutionListToUpdate.add(survey);
    //         }
    //         if(!solutionListToUpdate.isempty()){
    //             PSS_StaticConstants.opIDTriggerLogicStop = False;
    //             Update solutionListToUpdate;
    //             PSS_StaticConstants.opIDTriggerLogicStop = True;
    //         }
    //     }
        
    // }
}