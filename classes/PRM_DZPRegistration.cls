/*************************************************************************************************************************************
Apex Class Name     : PRM_DZPRegistration
Created Date        : 24 Aug 2023
Function            : To make an entry to the Registration Object for DZP
Developer           : Shraddha More
Test Class          : PRM_DZPRegistration_Test
************************************************************************************************************************************************/
public without sharing class PRM_DZPRegistration {
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_DZPRegistration';
    public static final String LOG_ENTRY_PROJECT  = 'IPA DZP Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Create DZP Registration Request';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info'; 
    
    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh); 
    
    /*****************************************************************************************************************
* Method Name: createDZPRegistrationEntry
* Date: 24/08/2023    
* Owner: Shraddha
* Description: make DZP registration entry
* Return: Returns true or false based on success insertion
******************************************************************************************************************/
    @AuraEnabled
    Public Static Boolean createDZPRegistrationEntry(){
        Boolean isSucess = false;
        Boolean isDup = false;
        String strDetailsAndEx;
        List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>(); 
        try{
            User ur = [SELECT Id, AccountId, ContactId, Contact.Email, Contact.Core_Preferred_Language__c, Contact.FirstName, Contact.LastName, Account.Name,Account.BillingCountry,
                       Account.Core_User_Defined_Website__c,Account.BillingCity,Account.Core_Account_Type__c,Contact.Core_Profession__c, Account.BillingAddress,Account.BillingState,Account.BillingPostalCode, Account.BillingStreet
                       FROM User 
                       WHERE Id =:UserInfo.getUserId()];
            
            Core_Entitlement__c ce = [SELECT id, Name, Core_IsActive__c 
                                      FROM Core_Entitlement__c  
                                      WHERE Name = 'Resource & Design Center for Secure Content' 
                                      AND Core_IsActive__c = true 
                                      Limit 1];
            
            //check if any existing DZP registration record is present         
            if(ce.Id != null && ur.Id != null){
                regReqList = [SELECT Id, PRM_Status__c, Entitlement_Details__c, PRM_Contact_Salesforce_Id__c, PRM_Salesforce_ID__c, Current_Status__c, PRM_Email_ID__c
                              FROM PRM_Registration_Request__c 
                              WHERE (Current_Status__c = 'Open' OR Current_Status__c = 'Auto-Approval Pending')
                              AND PRM_Email_ID__c =: ur.Contact.Email 
                              AND Entitlement_Details__c =: ce.Id];
                
                //check if Entitlement is already assigned to the user
                if(regReqList.size() == 0 || regReqList.isEmpty()){
                    for(Contact_Business_Types__c cbt : [SELECT Id, Status__c, Contact__c, Business_Types__r.Name FROM Contact_Business_Types__c 
                                                         WHERE Contact__c =: ur.ContactId  AND Business_Types__r.Name = 'Developer Zone Premier']
                   ){
                       if(cbt.Status__c == 'Approval - Pending' || cbt.Status__c == 'Approved'){
                           isDup = True;
                           break;
                       }
                   }
                }
                
                
                if(regReqList.size() > 0 || isDup){
                    isSucess = true;
                }else{
                    Id RecordTypeDZP = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.label.PRM_Account_Create_Request).getRecordTypeId();

                    //if no record DZP Registration record present then create new record
                    PRM_Registration_Request__c RegReq = new PRM_Registration_Request__c();
                    RegReq.Name = ur.Account.Name;
                    RegReq.PRM_First_Name__c = ur.Contact.FirstName;
                    RegReq.PRM_Last_Name__c  = ur.Contact.LastName;
                    RegReq.PRM_Email_ID__c = ur.Contact.Email;
                    RegReq.Entitlement_Details__c = ce.Id;
                    RegReq.PRM_Contact_Salesforce_Id__c = ur.ContactId;
                    RegReq.PRM_Salesforce_ID__c = ur.AccountId;
                    RegReq.PRM_Preferred_Language__c = ur.Contact.Core_Preferred_Language__c;
                    RegReq.PRM_Auto_Approve__c = true;
                    RegReq.RecordTypeId = RecordTypeDZP;
                    RegReq.PRM_Source__c = 'IPA - Portal';
                    RegReq.Current_Status__c = 'Open';
                    if( ur.Account.Core_User_Defined_Website__c != null){
                        RegReq.PRM_Account_URL__c = ur.Account.Core_User_Defined_Website__c;
                    }
                    RegReq.PRM_City__c = ur.Account.BillingCity;
                    RegReq.PRM_Partner_Type__c = ur.Account.Core_Account_Type__c;
                    if(ur.Contact.Core_Profession__c != null){
                        RegReq.PRM_Profession__c = ur.Contact.Core_Profession__c;
                    }
                    RegReq.PRM_Address_Line_1__c =  ur.Account.BillingStreet;
                    RegReq.PRM_State_Province__c =  ur.Account.BillingState;
                    RegReq.PRM_Zip_Postal_Code__c =  ur.Account.BillingPostalCode;
                    if(ur.Account.BillingCountry.length() == 2 ) {
                        RegReq.PRM_Country__c = ur.Account.BillingCountry;
                    }else {
                        RegReq.PRM_Country__c = getCountryCode(ur.Account.BillingCountry);
                    }
                    RegReq.PRM_Contact_Country__c = RegReq.PRM_Country__c;
                    RegReq.PRM_Account_Name__c = ur.Account.Name;
                   
                    
                    //insert DZP Registration request
                    Database.SaveResult insertResult = Database.insert(RegReq, false);
                    
                    if(insertResult.isSuccess()) {
                        isSucess = true;
                    }else{
                        //create log entry if any error occurred
                        for (Database.Error err : insertResult.getErrors()){ strDetailsAndEx = 'Message: ' + err.getMessage() + '\n'; strDetailsAndEx += 'Fields: ' + err.Fields.toString() + '\n';  strDetailsAndEx += 'StatusCode: ' + err.getStatusCode() + '\n';
                        }
                        
                        if(String.isNotBlank(strDetailsAndEx)){ Core_Log_Entry__c objCLE = new Core_Log_Entry__c(Core_Origin__c = LOG_ENTRY_ORIGIN, Core_Project__c = LOG_ENTRY_PROJECT, Core_Scope__c = LOG_ENTRY_SCOPE, Core_Severity__c = LOG_ENTRY_SEVERITY, Core_Message__c = strDetailsAndEx, Core_When__c = System.now(), Core_Details__c = strDetailsAndEx, Core_sObjectType__c = 'PRM_Registration_Request__c');                        
                            insert objCLE;
                        }
                    }                 
                }
            }            
        }catch(exception ex){ throw new AuraHandledException(ex.getMessage());
        }
        return isSucess;
    }
    
     /*get 2 digit country code from 3 digit country code*/
    public static string getCountryCode(String cntryCd){
        String countryCd;
        for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
            if(allCountry.ISO_Code__c == cntryCd){
                countryCd = allCountry.Country_Code__c;
                break;
            }
        }
        return countryCd;
    }
    /*****************************************************************************************************************
* Method Name: CheckDZPRegEntryCriteria
* Date: 24/08/2023    
* Owner: Shraddha
* Description: check criteria to make DZP registration entry
* Return: Returns true or false
******************************************************************************************************************/ 
    @AuraEnabled
    Public Static Boolean CheckDZPRegEntryCriteria(){
        Boolean makeDZPEntry = false;
        try{
            User ur = [SELECT Id, AccountId, ContactId FROM User WHERE Id =:UserInfo.getUserId()];
            
            //check criteria to make DZP registration entry
            for(PRM_AccountChannelMembership__c acm : [SELECT id, PRM_Account_Id__c, PRM_Tier_Name_txt__c, PRM_Partner_Role__c, 
                                                       PRM_Status_Nm__c, PRM_Channel_Program_Id__r.name
                                                       FROM PRM_AccountChannelMembership__c 
                                                       WHERE PRM_Status_Nm__c = 'Approved' 
                                                       AND PRM_Channel_Program_Id__r.name = 'Intel Partner Alliance'
                                                       AND PRM_Account_Id__c =: ur.AccountId] 
               ){
                    //IPA Refresh 2.0 - DZP Blade pop up defect fix - TWC729-8153
                    /*if(!IPARefresh || Test.isRunningTest()){
                        if(acm.PRM_Tier_Name_txt__c == 'Gold' || acm.PRM_Tier_Name_txt__c == 'Titanium' || 
                        (acm.PRM_Tier_Name_txt__c == 'Member' && acm.PRM_Partner_Role__c == 'Distributor')
                        ){
                            makeDZPEntry = true;
                            break;
                        }
                    }else{*/ // IPA Refresh - switch removal
                            if(acm.PRM_Tier_Name_txt__c == 'Partner' || acm.PRM_Tier_Name_txt__c == 'Prestige'){
                                makeDZPEntry = true;
                                break;
                            }
                    //}
                } 
        }catch(exception ex){  throw new AuraHandledException(ex.getMessage());
        }
        
        return makeDZPEntry;
    }
}