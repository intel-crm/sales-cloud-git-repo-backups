public class Core_CaseTrigger_Dispatcher{
/****************************************************************************************************** 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Pavani                    20/09/2024              Code Refactor changes TWC745-6459
****************************************************************************************************/  
    
    public static boolean triggerAssignmentRule=true; 
    //public static boolean triggerProvideCaseAccess=true;  //Commented as part of Code Refactor TWC745-6459
    //public static boolean assignUserManagerVar= true;  //Commented as part of Code Refactor TWC745-6459
    public static boolean isLoggeInUserMigrationUser=false;
    public static boolean updateCaseComments=true;         // Added by sumukh for US357190
    public static boolean updateSTOWD=true;
    // added by abhishk to avoid the recursive--25/04/2017 
    //@TestVisible private static boolean recursivetrigger = true;
    @TestVisible public static boolean recursivetrigger1 = true;        //modified and updated to public
    //private static boolean recursivetrigger2 = true;
    public static Integer recursiveError = 0;      //added by Aayushi for 101 SOQL fix    DE36384 02-23-2018
    public static Boolean backendPromotionRecursive = true;      //added for DE34358
    Public Static Final String IPS_FILE_INTEGRATION_USER = Label.Core_IPS_File_Integration_User; //'ips.file.integrationuser'; //Converted to Label as part of Code Refactor TWC745-6459
    public static Boolean IsAutoPromoteRequired = false; // Added as part of Code Refactor TWC745-6459
    // Added by chetan as part of COG fix for GEC cases
    public static Boolean isupdateCOG = true;
    public static void beforeMethod(Map<Id,Case> oldMap,Map<Id,Case> newMap, List<Case> oldList, List<Case> newList ) {      
        
        //[Below 2 lines are making sure to process only IPS records.]
        List<Case> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',newList);
        List<Case> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',oldList);
        //Added logic as part of Code Refactor TWC745-6459
        if(ipsNewRecordList != null && !ipsNewRecordList.isEmpty()){
            
            Core_IPS_CaseTriggerHandler.PrepareGlobalData(ipsNewRecordList,ipsOldRecordList,oldMap);
        }
        isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));         
        if((trigger.isInsert || trigger.isUpdate) && isLoggeInUserMigrationUser)
        {                                     
            if(triggerAssignmentRule)
            {
                triggerAssignmentRule=false;
                if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                    Core_IPS_CaseTriggerHandler.updateSupportedContact(ipsNewRecordList); //US191343
                    Core_IPS_CaseTriggerHandler.assignMigratedCaseInformation(ipsNewRecordList);  
                    Core_IPS_CaseTriggerHandler.assignCaseInformation(ipsNewRecordList,oldMap,isLoggeInUserMigrationUser); 
                }  
            }              
        }
        else  if(!isLoggeInUserMigrationUser) 
        {                             
            if(trigger.isInsert){
                
                Core_IPS_CaseTriggerHandler.updateSupportedContact(ipsNewRecordList); //US191343
                // Added by : Aparna   ----Last Modified/Added Date: 16-05-2017 : Iteration 5----
                Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(ipsNewRecordList); 
                Core_IPS_CaseTriggerHandler.assignCaseInformationfromProject(ipsNewRecordList,oldMap);  //added for US113466,US113488                 
                //moved by Aayushi to this block to resolve 101 SOQL error DE36384 02-23-2018
                Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(ipsNewRecordList,oldMap);
                Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList,oldMap);  //added for US176778                      
            }
            if(trigger.isUpdate){  
                //Core_IPS_CaseTriggerHandler.insertIPSCustomerGroupId(newList);                  
                if(recursivetrigger1){
                    recursivetrigger1 =false; // moved for DE34358 to resolve 101 error -Aparna-20/2/2019
                    
                    if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                        Core_IPS_CaseTriggerHandler.updateSupportedContact(ipsNewRecordList); //US191343
                        //Commented for US257271
                        //Core_IPS_CaseTriggerHandler.assignCaseOwnerOnProdUpdate(oldMap,ipsNewRecordList); //US225815 Gourav
                        Core_IPS_CaseTriggerHandler.validateCaseOwner(oldMap,ipsNewRecordList); //added by Sugandha for DE40252
                        Core_IPS_CaseTriggerHandler.checkCaseClosureParams(ipsNewRecordList, oldMap);
                        Core_IPS_CaseTriggerHandler.assignEntitlementToCase(ipsNewRecordList);
                        Core_IPS_CaseTriggerHandler.assignCaseInformation(ipsNewRecordList,oldMap,isLoggeInUserMigrationUser);                           
                        Core_IPS_CaseTriggerHandler.assignCaseInformationfromProject(ipsNewRecordList,oldMap); //add for US137508                    
                        //Commented as part of Code Refactor TWC745-6459 - Already invoking this method at the end of before update
                        //Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList,oldMap); //added for US176778
                        Core_IPS_CaseTriggerHandler.caseSLAManagement(oldMap,ipsNewRecordList);  
                        //added in the rescursion block by Aayushi to resolve 101 SOQL DE36384 02-23-2018
                        Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(ipsNewRecordList,oldMap); 
                        // Commented by chetan as part of case owner group fix for GEC cases
                        //Core_IPS_CaseTriggerHandler.updateCaseOwnerGroup(ipsNewRecordList,oldMap); //Added by Aparna                                                 
                    }                 
                }
                //moved for DE34358 to resolve 101 error -Aparna-20/2/2019
                if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0 && ipsOldRecordList <> null && ipsOldRecordList.size() > 0){                   
                     //backendPromotionRecursive = false;  
                    Boolean isLoggeInUserIntegrationUser = false;
                    //Added logic and Converted to Label as part of Code Refactor TWC745-6459
                    if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!=null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && Core_IPS_CaseTriggerHandler.GlobalUserRecords.containskey(userinfo.getuserId()) ){
                       
                        if(Core_IPS_CaseTriggerHandler.GlobalUserRecords.get(userinfo.getuserId()).Profile.Name == Label.Core_Integration_Profile_Name){ isLoggeInUserIntegrationUser = true; }
                    }
                    else{
                        
                        isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId())); 
                    }
                    
                    if(!isLoggeInUserIntegrationUser){
                        Core_IPS_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(ipsOldRecordList, ipsNewRecordList, oldMap, newMap);  //IPS Backend CasePromotion
                        //Added by Prem for HSD * please dont delete*
                       Core_IPS_BES_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(ipsOldRecordList, ipsNewRecordList, oldMap, newMap); 
                        Core_IPS_CaseTriggerHandler.backendEndSystemProcessCase(oldMap, newMap);  
                        //Start - US1005666 - Update scenario for MyIntel 3.0 integration.
                        if(backendPromotionRecursive){
                            Core_IPS_CaseTriggerHandler.myIntelIntegration(ipsOldRecordList, ipsNewRecordList, 'Update');
                            backendPromotionRecursive = false;
                        }                        
                        //End - US1005666
                    }
                    else if(Userinfo.getUserName().containsIgnoreCase(IPS_FILE_INTEGRATION_USER)){
                        Core_IPS_CaseTriggerHandler.backendEndSystemProcessCase(oldMap, newMap);  
                        if(backendPromotionRecursive){
                            Core_IPS_CaseTriggerHandler.myIntelIntegration(ipsOldRecordList, ipsNewRecordList, 'Update');
                            backendPromotionRecursive = false;
                        }                        
                    }
                } 
                             
                //added bt ranjini for US476474
                //if(assignUserManagerVar){   //Commented as part of Code Refactor TWC745-6459 - Always boolean is set to TRUE and it never changes
                    Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList, oldMap);                     
                //}                 
            } 
            
            if(trigger.isDelete) {    
                       
            }
             
            //Below Lines are added by Shridhar from CCP Weezer to validate claim case reviewer 04/02/2019
            //caseReviewerCheck method has 1 SOQL and 0 DML
            //Co-Marketing recordType check has been added in this method to avoid impact on other case functionality 
            
            if(trigger.isInsert || trigger.isUpdate){ 
                Core_MDF_ProcessCCP_Case.caseReviewerCheck(newList, oldMap, trigger.isInsert, trigger.isUpdate);
            }
             
        } 
    }  
    
    public static void afterMethod(Map<Id,case> oldMap,Map<Id,case> newMap,List<Case> oldList, List<Case> newList ) {              
        //[Below 2 lines are making sure to process only IPS records.]       
        List<Case> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',newList);
        List<Case> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',oldList);
        //Added logic as part of Code Refactor TWC745-6459
        if(ipsNewRecordList != null && !ipsNewRecordList.isEmpty()){
            Core_IPS_CaseTriggerHandler.PrepareGlobalData(ipsNewRecordList,ipsOldRecordList,oldMap);
            
        }
        if(trigger.isInsert){                
            
            if(triggerAssignmentRule){
                triggerAssignmentRule=false;                                    
                if(!System.isfuture() && !System.isBatch() && !isLoggeInUserMigrationUser && ipsNewRecordList <> null && ipsNewRecordList.size() > 0){                 
                    Core_IPS_CaseTriggerHandler.executeCaseAssignmentRule(oldMap,ipsNewRecordList);                
                } 
            }
            /* US358368 - FAE an automatic Interested Party if creating a Case and not the Contact ISO  -- START */
            if(ipsNewRecordList != null && !ipsNewRecordList.isEmpty()){
                Core_IPS_CaseTriggerHandler.createFAEASInterestedParty(ipsNewRecordList);
                Core_IPS_CaseTriggerHandler.createInsterestedPartiesUsingCase(ipsNewRecordList);  
                Core_IPS_CaseTriggerHandler.insertCommentUSAMinds(ipsNewRecordList); //Added for US253169 by Aparna 
            }
            /* US358368 - FAE an automatic Interested Party if creating a Case and not the Contact ISO  -- END */
            
            //Start - US1005666 - Create Scenario for MyIntel 3.0 Integration
            
            	Core_IPS_CaseTriggerHandler.myIntelIntegration(ipsOldRecordList, ipsNewRecordList, 'Create');
            
            //End - US1005666
        }
        
        if(trigger.isUpdate){
            
            if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                
                /* US368211  STOWD Sub Status & Last Assigned Queue fields must capture transactional snapshot data in each record START  */
                // Commented by Vishal as part of TWC777-3013- STOWD deprecation (26/12/2024)
                /*
                if(updateSTOWD){
                    updateSTOWD = false;  
                    Core_IPS_Calc_Durations_Trigger_Handler.calcDurations(ipsNewRecordList);
                } */             
                /* US368211  STOWD Sub Status & Last Assigned Queue fields must capture transactional snapshot data in each record END */
                
                if(recursiveError<=2){
                    recursiveError++ ;  //Added for DE34358 to resolve 101 error -Aparna-20/2/2019
                    Core_IPS_CaseTriggerHandler.manageCaseAccessForCustomer(oldMap,ipsNewRecordList);   //modified by Aayushi to resolve 101 SOQL error DE36384 02-23-2018                          
                }//end for DE34358               
            }
            
            if(triggerAssignmentRule){
                triggerAssignmentRule=false;
                if(!System.isfuture() && !System.isBatch() && !isLoggeInUserMigrationUser && ipsNewRecordList <> null && ipsNewRecordList.size() > 0){                    
                    Core_IPS_CaseTriggerHandler.executeCaseAssignmentRule(oldMap,ipsNewRecordList);                                                      
                }
                Core_IPS_CaseTriggerHandler.caseEditprojectDetails(ipsNewRecordList, oldMap);
            } 

            //Added by chetan to fix case owner group stamping issue for GEC cases
            if(isupdateCOG){
                isupdateCOG = false;
                Core_IPS_CaseTriggerHandler.updateCaseOwnerGroupnew(ipsNewRecordList,oldMap);                                           
            }                                               

            //Core_CaseTriggerHandler.updateCEPCaseRegionPickListValue(newList,oldMap);   //commented as CEP cases are obsolete
            if(updateCaseComments){                                                       //Added for US357190 by Sumukh
                updateCaseComments=false;
                Core_IPS_CaseTriggerHandler.updateCommentUSAMinds(oldMap,newMap);               
            }              
            //Chandrashekar -- adding this for promote failed comments and attachments , new bridge ipsNewRecordList ipsOldRecordList
            boolean isLoggeInUserIntegrationUser = false;
            //Added logic and Converted to Label as part of Code Refactor TWC745-6459
            if(Core_IPS_CaseTriggerHandler.GlobalUserRecords!=null && Core_IPS_CaseTriggerHandler.GlobalUserRecords.size()>0 && Core_IPS_CaseTriggerHandler.GlobalUserRecords.containskey(userinfo.getuserId())	){
                
                if(Core_IPS_CaseTriggerHandler.GlobalUserRecords.get(userinfo.getuserId()).Profile.Name == Label.Core_Integration_Profile_Name){ isLoggeInUserIntegrationUser = true; }
            }
            else{ 
                
                isLoggeInUserIntegrationUser = Core_IPS_Case_Comments_Handler.isIntegrationUser(string.valueof(userinfo.getuserId())); 
            }
           
            if(isLoggeInUserIntegrationUser) {
                List<Id> caseIds = new List<Id>();
                for(Integer i=0; i<ipsNewRecordList.size(); i++) {
                    if(ipsNewRecordList[i].Core_IPS_BES_Promote_Status__c == 'Done' && !String.isBlank(ipsNewRecordList[i].Core_IPS_BackendID__c)  && String.isBlank(ipsOldRecordList[i].Core_IPS_BackendID__c)){//ipsOldRecordList[i].Core_IPS_BackendID__c
                        caseIds.add(ipsNewRecordList[i].id);
                    }
                }
                if(!caseIds.isEmpty()) {
                    Core_IPS_CaseTriggerHandler.promoteMissedItems(caseIds);
                }
            }
            //End- Chandra
        }
        
        if(trigger.isDelete) {    
                    
        }                 
    }  
}