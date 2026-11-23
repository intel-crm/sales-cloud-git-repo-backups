public class Core_CaseTrigger_Dispatcher{

    public static boolean triggerAssignmentRule=true;
    public static boolean triggerProvideCaseAccess=true;
    public static boolean isLoggeInUserMigrationUser=false;
    
    // added by abhishk to avoid the recursive--25/04/2017 
    @TestVisible private static boolean recursivetrigger = true;
    @TestVisible public static boolean recursivetrigger1 = true;        //modified and updated to public
    private static boolean recursivetrigger2 = true;
    public static Integer recursiveError = 0;      //added by Aayushi for 101 SOQL fix    DE36384 02-23-2018
    public static Boolean backendPromotionRecursive = true;      //added for DE34358
    public static void beforeMethod(List<Case> oldList, List<Case> newList, Map<Id,Case> oldMap,Map<Id,Case> newMap) { 
        
        //test comment                  
        //[Below 2 lines are making sure to process only IPS records.]
        List<Case> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',newList);
        List<Case> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',oldList);
        
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
                 if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                System.debug('Before Insert :'+trigger.new+ 'is Before'+trigger.isBefore);
                Core_IPS_CaseTriggerHandler.updateSupportedContact(ipsNewRecordList); //US191343
                // Added by : Aparna   ----Last Modified/Added Date: 16-05-2017 : Iteration 5----
                Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(ipsNewRecordList); 
                Core_IPS_CaseTriggerHandler.assignCaseInformationfromProject(ipsNewRecordList,oldMap);  //added for US113466,US113488                 
                //moved by Aayushi to this block to resolve 101 SOQL error DE36384 02-23-2018
                Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(ipsNewRecordList,oldMap);
                Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList,oldMap);  //added for US176778      
                 }
            }
            if(trigger.isUpdate){  
                //Core_IPS_CaseTriggerHandler.insertIPSCustomerGroupId(newList);
                System.debug('#11 Core_CaseTrigger_Dispatcher  trigger.isUpdate: ' + trigger.isUpdate );//+ ' ipsNewRecordList: ' + ipsNewRecordList+'old Map'+oldMap+'is Before:'+trigger.isBefore+'new'+trigger.new.get(0));
                
                if(recursivetrigger1){
                    if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                        Core_IPS_CaseTriggerHandler.updateSupportedContact(ipsNewRecordList); //US191343
                        //Commented for US257271
                        //Core_IPS_CaseTriggerHandler.assignCaseOwnerOnProdUpdate(oldMap,ipsNewRecordList); //US225815 Gourav
                        Core_IPS_CaseTriggerHandler.validate_CaseOwner(oldMap,ipsNewRecordList); //added by Sugandha for DE40252
                        Core_IPS_CaseTriggerHandler.checkCaseClosureParams(ipsNewRecordList, oldMap);
                        Core_IPS_CaseTriggerHandler.assignEntitlementToCase(ipsNewRecordList);
                        Core_IPS_CaseTriggerHandler.assignCaseInformation(ipsNewRecordList,oldMap,isLoggeInUserMigrationUser); 
                        Core_IPS_CaseTriggerHandler.assignCaseInformationfromProject(ipsNewRecordList,oldMap); //add for US137508                    
                        Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList,oldMap); //added for US176778
                        Core_IPS_CaseTriggerHandler.caseSLAManagement(oldMap,ipsNewRecordList);  
                        //added in the rescursion block by Aayushi to resolve 101 SOQL DE36384 02-23-2018
                        Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(ipsNewRecordList,oldMap); 
                       Core_IPS_CaseTriggerHandler.updateCaseOwnerGroup(ipsNewRecordList,oldMap); //Added by Aparna
                        
                    }
                    recursivetrigger1 =false;                        
                }
                
                if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0 && ipsOldRecordList <> null && ipsOldRecordList.size() > 0){
                    Core_IPS_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(ipsOldRecordList, ipsNewRecordList, oldMap, newMap);  //IPS Backend CasePromotion
                }
                
               
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
        /*commented by Aayushi for 101 SOQL fix    DE36384 02-23-2018                   
        //Added By : Yogesh Sharma(US84823)and Iteration1 and 2
        //Modified By: Neeti Jain(DE33341) to bypass this method for migration user
        if((Trigger.isInsert || Trigger.isUpdate)&& !isLoggeInUserMigrationUser){
        system.debug('========78======='+UserInfo.getProfileId());
        Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(newList,oldMap); 
        }*/ 
        
        System.debug('#Final Core_CaseTrigger_Dispatcher  trigger.isUpdate: ' + trigger.isUpdate + ' ipsNewRecordList: ' + ipsNewRecordList);
        
    }  
    
    public static void afterMethod(List<case> oldList, List<case> newList, Map<Id,case> oldMap,Map<Id,case> newMap) {        
        
        //[Below 2 lines are making sure to process only IPS records.]
        List<Case> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',newList);
        List<Case> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',oldList);
        
        
        if(trigger.isInsert){
            if(triggerAssignmentRule){
                triggerAssignmentRule=false;                     
                
                if(!System.isfuture() && !System.isBatch() && !isLoggeInUserMigrationUser && ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                    Core_IPS_CaseTriggerHandler.executeCaseAssignmentRule(oldMap,ipsNewRecordList); 
                    
                } 
            }
            
            //Update CEP Case Region
            //Core_CaseTriggerHandler.updateCEPCaseRegionPickListValue(newList,oldMap);//commented as CEP cases are obsolete
            //Rakesh -US107411 -calling a new method(create_InsterestedParties_UsingCase) from here
            Core_IPS_CaseTriggerHandler.create_InsterestedParties_UsingCase(ipsNewRecordList);  
        }
        if(trigger.isUpdate){
            
            System.debug('#31 Core_CaseTrigger_Dispatcher  trigger.isUpdate: ' + trigger.isUpdate);// + ' ipsNewRecordList: ' + ipsNewRecordList);
            if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){                                         
                
                if(recursiveError<=2){
                    Core_IPS_CaseTriggerHandler.manageCaseAccessForCustomer(oldMap,ipsNewRecordList);   //modified by Aayushi to resolve 101 SOQL error DE36384 02-23-2018                          
                    recursiveError++;
                }
            }
            
            if(triggerAssignmentRule){
                triggerAssignmentRule=false;
                if(!System.isfuture() && !System.isBatch() && !isLoggeInUserMigrationUser && ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                    Core_IPS_CaseTriggerHandler.executeCaseAssignmentRule(oldMap,ipsNewRecordList);
                    system.debug('testing by venki-executcaseassingment');                 
                }
                Core_IPS_CaseTriggerHandler.case_Edit_projectDetails(ipsNewRecordList, oldMap);
            }
            
            //Core_CaseTriggerHandler.updateCEPCaseRegionPickListValue(newList,oldMap);
            
        
        }
        if(trigger.isDelete) {            
        }            
        
    }  
}