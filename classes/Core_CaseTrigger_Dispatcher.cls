public class Core_CaseTrigger_Dispatcher{
    
    public static boolean triggerAssignmentRule=true; 
    public static boolean triggerProvideCaseAccess=true;
    public static boolean assignUserManagerVar= true;
    public static boolean isLoggeInUserMigrationUser=false;
    public static boolean updateCaseComments=true;         // Added by sumukh for US357190
    public static boolean updateSTOWD=true;
    // added by abhishk to avoid the recursive--25/04/2017 
    //@TestVisible private static boolean recursivetrigger = true;
    @TestVisible public static boolean recursivetrigger1 = true;        //modified and updated to public
    //private static boolean recursivetrigger2 = true;
    public static Integer recursiveError = 0;      //added by Aayushi for 101 SOQL fix    DE36384 02-23-2018
    public static Boolean backendPromotionRecursive = true;      //added for DE34358
    
    public static void beforeMethod(Map<Id,Case> oldMap,Map<Id,Case> newMap, List<Case> oldList, List<Case> newList ) {      
        
        //[Below 2 lines are making sure to process only IPS records.]
        List<Case> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',newList);
        List<Case> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Case',oldList);
        
        isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));         
        if((trigger.isInsert || trigger.isUpdate) && isLoggeInUserMigrationUser)
        { //System.debug('line 24 in dispatcher');                                     
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
                //System.debug('Before Insert 888888 :'+trigger.new+ 'is Before'+trigger.isBefore);
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
                        Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList,oldMap); //added for US176778
                        Core_IPS_CaseTriggerHandler.caseSLAManagement(oldMap,ipsNewRecordList);  
                        //added in the rescursion block by Aayushi to resolve 101 SOQL DE36384 02-23-2018
                        Core_IPS_CaseTriggerHandler.updateSupportLevelOnCase(ipsNewRecordList,oldMap); 
                        Core_IPS_CaseTriggerHandler.updateCaseOwnerGroup(ipsNewRecordList,oldMap); //Added by Aparna                                                 
                    }    
                            
                }
                //moved for DE34358 to resolve 101 error -Aparna-20/2/2019
                if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0 && ipsOldRecordList <> null && ipsOldRecordList.size() > 0){                   
                    // backendPromotionRecursive = false;                                                     
                    Core_IPS_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(ipsOldRecordList, ipsNewRecordList, oldMap, newMap);  //IPS Backend CasePromotion
                }                 
                //added bt ranjini for US476474
                if(assignUserManagerVar){
                    Core_IPS_CaseTriggerHandler.assignUserManager(ipsNewRecordList, oldMap);                     
                }             
            } 
            
            if(trigger.isDelete) {    
                system.debug('Delete Trigger');         
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
            }
            /* US358368 - FAE an automatic Interested Party if creating a Case and not the Contact ISO  -- END */
            
            //Update CEP Case Region
            //Core_CaseTriggerHandler.updateCEPCaseRegionPickListValue(newList,oldMap);//commented as CEP cases are obsolete
            //Rakesh -US107411 -calling a new method(create_InsterestedParties_UsingCase) from here
            Core_IPS_CaseTriggerHandler.createInsterestedPartiesUsingCase(ipsNewRecordList);  
            Core_IPS_CaseTriggerHandler.insertCommentUSAMinds(ipsNewRecordList); //Added for US253169 by Aparna           
        }
        
        if(trigger.isUpdate){
            
            if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                
                /* US368211  STOWD Sub Status & Last Assigned Queue fields must capture transactional snapshot data in each record START  */
                if(updateSTOWD){
                    updateSTOWD = false;  
                    /*Core_IPS_Calc_Durations_Trigger_Handler.calcDurations(ipsNewRecordList);*/
                }               
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
            //Core_CaseTriggerHandler.updateCEPCaseRegionPickListValue(newList,oldMap);   //commented as CEP cases are obsolete
            if(updateCaseComments){                                                       //Added for US357190 by Sumukh
                updateCaseComments=false;
                Core_IPS_CaseTriggerHandler.updateCommentUSAMinds(oldMap,newMap);               
            }              
        }
        
        if(trigger.isDelete) {    
            system.debug('Delete After Trigger');        
        }                 
    }  
}