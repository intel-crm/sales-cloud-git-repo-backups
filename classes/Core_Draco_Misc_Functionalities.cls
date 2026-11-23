/******************************************************************************************************************************************
Class Name  : Core_Draco_Misc_Functionalities
Version     : 1.0
Created Date: 12 DEC 2022
Function    : Various business logics that currespond to Team Draco are implemented in this class   

Modification Log :
* Developer                 	Date [DD/MM/YYYY]           	Description
* ----------------------------------------------------------------------------
* Akshay More [Team: DRACO]			05/07/2022              	Original version
* Akshay More [Team: DRACO]			23/12/2022					Added method to create Integration Monitoring Log Entry
* Shreyas [Team: DRACO]             17/01/2023                  Added method to clean up the Failed Assignment/Removal Entitlement records
*****************************************************************************************************************************************/

public without sharing  class Core_Draco_Misc_Functionalities {
    
    // Main method for reading the called functionality and invoking appropriate functions
    @InvocableMethod(label='Draco miscellaneous functionalities calling Method' description='Calls appropriate method based on the requested functionality')
    public static void functionalityClassificationMethod(List<String> calledFeature){
        if(calledFeature[0] == 'B2BAccountCleanup'){
            b2bFalg_AccountCleanup(); //This method will mark B2B flag on Account to FALSE if there are no B2B TRUE contacts in it
        }
        if(calledFeature[0] == 'DailyEntitlementCleanup'){
            //dailyEntitlementCleanup(); //This method will cleanup all the Failed Assignment and Removal Entitlement Records. It will be called daily from Flow.
            Core_Draco_EntitlementCleanup_Batch schduleBatch = new Core_Draco_EntitlementCleanup_Batch();
            database.executebatch(schduleBatch, Integer.valueOf(System.label.Daily_Entitlement_Retry_Batch_Size));
        }
    }
    
    /************************** This method will mark B2B flag on Account to FALSE if there are no B2B TRUE contacts in it ***************************/
    @future
    public static void b2bFalg_AccountCleanup() {
        Integer accUpdateLimit = integer.valueof(system.label.Core_Account_B2B_Flag_Update_Batch_Size);
        List<Account> accList = new List<Account>();
        //Loop through all the Accounts where B2B flag is TRUE
        for(Account acc : [SELECT Id, Core_B2B_Entitlement__c, (SELECT Id, Core_Contact_B2B_Indicator__c FROM Contacts) FROM Account WHERE Core_B2B_Entitlement__c = TRUE WITH SECURITY_ENFORCED]){
            //Loop through all the contacts in that Account and see if at least 1 contact has Core_Contact_B2B_Indicator__c flag = TRUE
            Boolean b2bAccount = false;
            for(Contact con : acc.Contacts){
                if(con.Core_Contact_B2B_Indicator__c){
                    b2bAccount = true;
                }
            }
            //If there are no contacts with Core_Contact_B2B_Indicator__c = TRUE, then mark Core_B2B_Entitlement__c = FALSE on Account
            if(!b2bAccount){
                acc.Core_B2B_Entitlement__c = false;
                accList.add(acc);
            }
        }
       
        
        //Prepare a sub-list of accounts with total size as specified in Core_Account_B2B_Flag_Update_Batch_Size custom label. This is because CPU time out exception
        //is being thrown if we try to update large number of accounts at a time
        List<Account> accToUpdate = new List<Account>();
        Integer listSize = 0;
        for(Account acc : accList){
            if(listSize <= accUpdateLimit){
                accToUpdate.add(acc);
                listSize ++;
            }
        }
        if(Schema.sObjectType.Account.isUpdateable()){
            database.update (accToUpdate,false);
        }
    }
    
    
    /************************** This method will create Integration Monitoring Log entries for the Reports and Dashboards ***************************/
    public static void createIntgrationMonitoringLog(String IntgScr, String ErrDetail, Id ContactId, Id IIMid, Integer IntgDuration, String IntgLogTags){
        
        Boolean errorCategorised = false;
        Boolean errorTobeIgnored = false;
        Core_AE_Integration_Log__c intgLog = new Core_AE_Integration_Log__c();
        
        //Get the list of Custom Metadata containing the Error String 
        List<Proactive_Alerts_on_A_E_Integration__mdt> lstProactiveAlertMtd = new List<Proactive_Alerts_on_A_E_Integration__mdt>();
        lstProactiveAlertMtd = Proactive_Alerts_on_A_E_Integration__mdt.getall().values();
        
        //Loop across the metadata and see if we can categorise the error into a category
        for(Proactive_Alerts_on_A_E_Integration__mdt ProActAlert : lstProactiveAlertMtd){
        
            if(ProActAlert.Core_Is_Active__c && ProActAlert.DeveloperName != 'Other_Errors' && ProActAlert.Core_Error_Source__c == IntgScr){                    
                if(ErrDetail != null && ErrDetail == 'Success'){
                    intgLog = new Core_AE_Integration_Log__c(Core_Integration_Source__c = IntgScr, Core_Error_Category__c = 'Success', Core_Error_Group__c = 'Success', Core_Error_Detail__c = null, Core_Integration_Contact__c = ContactId,
                                                             Core_Integration_IIM__c = IIMid, Core_Integration_Duration__c = IntgDuration, Core_Integration_Log_Tags__c = IntgLogTags, Core_Log_Generation_Date__c = system.now());
                    errorCategorised = true;
                }
                if(ErrDetail != null && ErrDetail != 'Success' && ErrDetail.containsIgnoreCase(ProActAlert.Core_Error_Text__c) /* && !ProActAlert.IsIgnore__c */){
                    intgLog = new Core_AE_Integration_Log__c(Core_Integration_Source__c = IntgScr, Core_Error_Category__c = ProActAlert.Label, Core_Error_Group__c = ProActAlert.Core_Error_Group__c, Core_Error_Detail__c = ErrDetail, Core_Integration_Contact__c = ContactId,
                                                             Core_Integration_IIM__c = IIMid, Core_Integration_Duration__c = IntgDuration, Core_Integration_Log_Tags__c = IntgLogTags, Core_Log_Generation_Date__c = system.now());
                    errorCategorised = true;
                }
            }
        }
        //If error is not found in custom metadata, add its details under "Uncategorised Errors" category
        if(!errorCategorised /* && !errorTobeIgnored */){
            intgLog = new Core_AE_Integration_Log__c(Core_Integration_Source__c = IntgScr, Core_Error_Category__c = 'Uncategorised '+ IntgScr + ' Errors', Core_Error_Group__c = 'Uncategorised '+ IntgScr + ' Errors', Core_Error_Detail__c = ErrDetail, Core_Integration_Contact__c = ContactId,
                                                     Core_Integration_IIM__c = IIMid, Core_Integration_Duration__c = IntgDuration, Core_Integration_Log_Tags__c = IntgLogTags, Core_Log_Generation_Date__c = system.now());
        }
        
        //Insert the Integration Monitoring Log
        try{
            if(Schema.sObjectType.Core_AE_Integration_Log__c.isCreateable()){
            insert intgLog;
            }
        } catch(DmlException e) {
           
        }
    }
   


/***************************************************************************************************** 
Method Name:    validateBeforeDML
return  :       List<Core_Contact_Entitlement__c>
@parameters:    List<Core_Contact_Entitlement__c>, List<Contact>
Description:    This method will check if the DML on the contact entitlement will cause any validation to hit, and if yes then update the affected CE record before the DML
Added By:       Team Draco
Modified By:        Date:           Changes: 
Akshay More         30-08-2023      Original Version (Only contains logic for pre-DML validation check for CNDA)
******************************************************************************************************/
    public static List<Core_Contact_Entitlement__c> validateBeforeDML(List<Core_Contact_Entitlement__c> contEntList, List<Contact> conList){   
        // --------------- [START] Validate Before Performing DML - CNDA Validation --------------- //
        Map<Id,List<Core_Contact_Entitlement__c>> conIdConEntMap = new Map<Id,List<Core_Contact_Entitlement__c>>();
        Map<Id,Core_Contact_Entitlement__c> conEntIdMap = new Map<Id,Core_Contact_Entitlement__c>();
        Set<Id> conEntSetToRepublish = new Set<Id>();
        for(Core_Contact_Entitlement__c conEnt : contEntList){
            conEntIdMap.put(conEnt.Id, ConEnt);
            if(conIdConEntMap.containsKey(conEnt.Core_Contact_Id__c)) {
                conIdConEntMap.get(conEnt.Core_Contact_Id__c).add(conEnt);
            } else {
                conIdConEntMap.put(conEnt.Core_Contact_Id__c, new List<Core_Contact_Entitlement__c>{conEnt});
            }
        }
        
        for(Contact con : conList){
            Boolean hasCNDA = con.Account.Core_CNDA_Number__c != null ? true :false;
            Boolean hasEmployee = false;
            Boolean hasDZP = false;
            Id DZPEntitlementId;
            for(Core_Contact_Entitlement__c conEnt : conIdConEntMap.get(con.Id)){
                if(conEnt.Core_Entitlement_Id__r.Core_Display_Name__c == 'Employee' && conEnt.Core_Selected__c == true && conEnt.Core_Status__c == 'Complete'){
                    hasEmployee = true;
                }
                if(conEnt.Core_Entitlement_Id__r.Core_Display_Name__c == 'Developer Zone Premier(CNDA required)' && conEnt.Core_Selected__c == true && conEnt.Core_Status__c == 'Complete'){
                    hasDZP = true;
                    DZPEntitlementId = conEnt.Id;
                }
            }
            //At the end check if Contact will have validation if DML is performed
            if(!hasCNDA && !hasEmployee && hasDZP){
                conEntIdMap.get(DZPEntitlementId).Core_Selected__c = false;
                conEntIdMap.get(DZPEntitlementId).Core_Status__c = 'Complete';
                conEntIdMap.get(DZPEntitlementId).Core_Update_Reason__c = 'Removed as part of CNDA validation';
                //conEntIdMap.get(DZPEntitlementId).Core_Data_Loaded__c = true;
                conEntSetToRepublish.add(conEntIdMap.get(DZPEntitlementId).Id);
            }
        }
        if(!conEntSetToRepublish.isEmpty()){
            republishConEntFuture(conEntSetToRepublish);
        }
        return conEntIdMap.values();
        // --------------- [END] Validate Before Performing DML - CNDA Validation --------------- //
    }

    @future
    public static void republishConEntFuture(Set<Id> conEntSetToRepublish){
        List<Core_Contact_Entitlement__c> conEntListToRepublish = new List<Core_Contact_Entitlement__c>();
        for(Id conEntId : conEntSetToRepublish){
            Core_Contact_Entitlement__c conEnt = new Core_Contact_Entitlement__c(Id = conEntId, Core_Status__c = 'Pending', Core_Data_Loaded__c = true);
            conEntListToRepublish.add(conEnt);
        }
        //Integer addSeconds = Integer.valueOf(System.label.Delay_for_Entitlement_Republish_on_Validation_Seconds);
        Integer addSeconds = 5;
        Datetime endTime = System.Now().addSeconds(addSeconds);
        
        while(System.Now() < endTime){ 
        }
        if(Schema.sObjectType.Core_Contact_Entitlement__c.isUpdateable()){
        update conEntListToRepublish;
        }
    }
}