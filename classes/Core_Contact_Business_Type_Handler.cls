/******************************************************************************************************************************************
Class Name  : Core_Contact_Business_Type_Handler
Version     : 1.0 
Created Date: 11 Nov 2021
Function    : Handles Contact Business Type records and remove the related Entitlement record if CBT Status is Rejected. 
Modification Log :
* Developer                 Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------      
* Gaurav Kurwade            30/11/2021              Original version 
* Gaurav Kurwade            15/02/2022              Added Automation for Subscription of related contact when CBT added  
*****************************************************************************************************************************************/


public with Sharing class Core_Contact_Business_Type_Handler {
    public static Boolean IsNotRecursive = true;
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'Core_Contact_Business_Type_Handler';
    public static Boolean skipsCEProcess = false;
    
    
    //Validation to check if ABT status is approved befor inserting/updating CBT
  /*  public static void ABTApprovedCheck(List<Contact_Business_Types__c> newList) {
        Set<Id> cbtIds = new Set<Id>();
        Map<Id, Id> conAccountMap = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        List<String> acctIdBtIdList = new List<String>();
        String params = '';
        try {
            for(Contact_Business_Types__c conBT : newList){                       
                cbtIds.add(conBT.Business_Types__c);
                contactIds.add(conBT.Contact__c);                
            }
            if(Schema.sObjectType.Contact.isAccessible()){
                //Retrive Accounts for contacts in CBT to check if ABTs are approved
                for(Contact con : [Select id, AccountId from Contact where id =: contactIds WITH SECURITY_ENFORCED]){
                    conAccountMap.put(con.Id,con.AccountId);  
                }
            }
            //Retreive combination of AccountId-BusinessTypeID for particular accounts in Approved status from ABTs to list
            if(Schema.sObjectType.Account_Business_Types__c.isAccessible()){
            for (Account_Business_Types__c abts : [SELECT id, Account__c, Business_Types__c, Business_Types__r.Name, Status__c 
                                                   FROM Account_Business_Types__c 
                                                   WHERE Account__c IN: conAccountMap.values() AND Status__c =: System.Label.ER_Approved WITH SECURITY_ENFORCED]) {
                                                       if(!acctIdBtIdList.contains(abts.Account__c+'-'+abts.Business_Types__c)){
                                                           acctIdBtIdList.add(abts.Account__c+'-'+abts.Business_Types__c);
                                                       }
            }
}
            //Loop through CBTs and check if CBT has Approved Account Business Type. 
            //Validation applies only id Status is getting chanhed to Approval - Pending
            for(Contact_Business_Types__c conBT : newList) {
                params = params + 'Contact Id-'+ conBT.Contact__c + '-Business Type Id-'+conBT.Business_Types__c +';';
                if(!acctIdBtIdList.contains(conAccountMap.get(conBT.Contact__c) +'-'+conBT.Business_Types__c) &&
                   (conBT.Status__c == System.Label.ER_Approval_Pending || conBT.Status__c == System.Label.ER_Approved)) //Approved status added for TWC722-178
                {
                    if(!Test.isRunningTest()){
                        conBT.addError('Account Business Type is not Approved');
                    }
                    else {
                        throw new ER_ErrorUtility.CustomException('Empty');
                    }
                }                                       
            }                                                   
        }
        catch(Exception ex){
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in ABTApprovedCheck', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    }  */
    
    /*  public static void CBTContactEngNameCheck(List<Contact_Business_Types__c> newList) {
Map<Id, Contact> contactsMap = new Map<Id, Contact>();
Set<Id> contactIds = new Set<Id>();
String params = '';
try {
for(Contact_Business_Types__c conBT : newList){
contactIds.add(conBT.Contact__c);                
}
for(Contact con : [Select id, AccountId, Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c  from Contact where id =: contactIds]){
contactsMap.put(con.Id,con);  
}
for(Contact_Business_Types__c conBT : newList) {
params = params +'Contact Id-'+conBT.Contact__c + 'Contact Business Type id-'+conBT.Id +';';
if(contactsMap.ContainsKey(conBT.Contact__c)) {
Contact con = contactsMap.get(conBT.Contact__c);
if(String.IsBlank(con.Core_English_Only_First_Name__c) && String.IsBlank(con.Core_English_Only_Last_Name__c)) //Last Name added for TWC722-178
{
conBT.addError(Label.CBT_Contact_English_Name_Check);
}
}
if(Test.isRunningTest() && conBT.Status_Reason__c == 'exception') {
throw new ER_ErrorUtility.CustomException('exception');
}              
}
}
catch(Exception ex) {
ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
custEx.Message = ex.getMessage();
custEx.Cause = ex.getCause();
custEx.StackTraceString = ex.getStackTraceString();
custEx.LineNumber = ex.getLineNumber();                
custEx.TypeName = ex.getTypeName();            
ER_ErrorUtility.createLogEntry('Error in CBTContactEngNameCheck', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
}
}*/
    
    //Method inserts new entitlement based on business type and triggers AGS role request
    public static void insertContactEntitlement(List<Contact_Business_Types__c> listrecords) {
        Set<Id> cbtIds = new Set<Id>();
        Set<Id> contIds = new Set<Id>();
        boolean EntAvailable = false;
        List<Core_Contact_Entitlement__c> lstConEnt = new  List<Core_Contact_Entitlement__c>(); //for Collecting Contact entitlement records to update
        Map<Id, Id> cbtEnttlMap = new Map<Id, Id>();
        String params = '';
        String conEntId = '';
        
        try {
            //Get Set of CBT ids to fetch from Entitlement Matrix
            for(Contact_Business_Types__c conBT : listrecords){                       
                cbtIds.add(conBT.Business_Types__c);
                contIds.add(conBT.Contact__c);
               
            }
            
            
            
            //Retrive Business type to entitlement mapping from entitlement matrix
            if(Schema.sObjectType.PRM_VXEnttlmntMatrix__c.isAccessible()){
                //for (PRM_VXEnttlmntMatrix__c mat : [SELECT Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name
                //Ganesh Changes 
                for (PRM_VXEnttlmntMatrix__c mat : [SELECT Id, PRM_Entitlement_Id__c, Business_Types__c    
                                                    FROM PRM_VXEnttlmntMatrix__c 
                                                    WHERE Business_Types__c IN: cbtIds WITH SECURITY_ENFORCED]) {
                                                        if (!cbtEnttlMap.containsKey(mat.Business_Types__c)) {
                                                            cbtEnttlMap.put(mat.Business_Types__c, mat.PRM_Entitlement_Id__c);
                                                           
                                                            conEntId = cbtEnttlMap.get(mat.Business_Types__c);
                                                            
                                                        }                                                    
                                                    }
            }
            if(Schema.sObjectType.Core_Contact_Entitlement__c.isAccessible()){
                for(Core_Contact_Entitlement__c conEnts : [Select id, Core_Contact_Id__c, Core_Entitlement_Id__c from Core_Contact_Entitlement__c where Core_Contact_Id__c =:contIds AND Core_Entitlement_Id__c =: conEntId WITH SECURITY_ENFORCED]){                       
                    EntAvailable = true;
                    
                }
            }
            
            //Loop through new CBTs fetch corresponding entitlement and insert new contact entitlement to trigger AGS request
            //Insert new entitlement only if status is Approval - Pending   
            for(Contact_Business_Types__c conBT : listrecords) {
                params = params + 'Contact Id-'+ conBT.Contact__c + '-Business Type Id-'+conBT.Business_Types__c +'-Enttl Id- '+cbtEnttlMap.get(conBT.Business_Types__c) +';';                   
                if(conBT.Status__c == System.Label.ER_Approval_Pending && EntAvailable == false && skipsCEProcess == false) {
                    
                    Core_Contact_Entitlement__c cEnti = new  Core_Contact_Entitlement__c();
                    cEnti.Core_Entitlement_Id__c = cbtEnttlMap.get(conBT.Business_Types__c);
                  
                    cEnti.Core_Selected__c = true; 
                    cEnti.Core_Status__c = System.Label.ER_Pending;
                    cEnti.Core_Contact_Id__c = conBT.Contact__c;
                    cEnti.Core_Data_Loaded__c = true; //Required to send A&E 2.0 message to AGS                   
                    if(cEnti.Core_Entitlement_Id__c != null){
                        lstConEnt.add(cEnti); 
                    }
                }
                if(Test.isRunningTest() && conBT.Status_Reason__c == 'exception'){
                    throw new ER_ErrorUtility.CustomException('Empty');
                }
            }
            
           
            //Insert new entitlements
            if(lstConEnt.size() > 0){
                if(Schema.sObjectType.Core_Contact_Entitlement__c.isCreateable()){
                    Core_Contact_Ent_BT_Handler.skipsCBTProcess = true;
                    insert lstConEnt; 
                }
                
            }
        }
        catch(Exception ex) {
            execptionLogMethod(ex, 'insertContactEntitlement',params);
           /* ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in insertContactEntitlement', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params); */
        }
    }
    //Update contact entitlements based on update on CBTs
    //Once role is assigned in AGS mark CBT status as Approved anf if removed mark CBT status as Rejected
   public static void updateContactEntitlement(List<Contact_Business_Types__c> listrecords, Map<Id, Contact_Business_Types__c> oldMap) {
        Set<Id> cbtIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<Core_Contact_Entitlement__c> lstConEnt = new  List<Core_Contact_Entitlement__c>(); //for Collecting Contact entitlement records
        Map<Id, Id> cbtEnttlMap = new Map<Id, Id>();
        Map<id, List<Core_Contact_Entitlement__c>> lstConEntMap = new Map<id, List<Core_Contact_Entitlement__c>>();
        List<Core_Contact_Entitlement__c> conEnttlToUpdate = new  List<Core_Contact_Entitlement__c>();
        String params = '';
        try {
            for(Contact_Business_Types__c conBT : listrecords){                       
                cbtIds.add(conBT.Business_Types__c);
                contactIds.add(conBT.Contact__c);
            }            
            
            //Retrive Business type to entitlement mapping from entitlement matrix
            if(Schema.sObjectType.PRM_VXEnttlmntMatrix__c.isAccessible()){
                //for (PRM_VXEnttlmntMatrix__c mat : [SELECT Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name 
                //Ganesh Changes  
                for (PRM_VXEnttlmntMatrix__c mat : [SELECT Id, PRM_Entitlement_Id__c, Business_Types__c 
                                                    FROM PRM_VXEnttlmntMatrix__c 
                                                    WHERE Business_Types__c IN: cbtIds WITH SECURITY_ENFORCED]) {
                                                        if (!cbtEnttlMap.containsKey(mat.Business_Types__c)) {
                                                            cbtEnttlMap.put(mat.Business_Types__c, mat.PRM_Entitlement_Id__c);
                                                        }                                                    
                                                    }
            }
            //Retrive contact to entitlements map based entitlement retrived from entitlement matrix
            for (Core_Contact_Entitlement__c contEnt : [SELECT id, Core_Contact_Id__c, Core_Entitlement_Id__c, Core_Entitlement_Id__r.Name, 
                                                        Core_Selected__c,Core_Status__c 
                                                        FROM Core_Contact_Entitlement__c 
                                                        WHERE  Core_Entitlement_Id__c =:cbtEnttlMap.values() AND 
                                                        Core_Contact_Id__c =: contactIds]) {
                                                            if(lstConEntMap.containsKey(contEnt.Core_Contact_Id__c))
                                                            {
                                                                
                                                                List<Core_Contact_Entitlement__c> entts = lstConEntMap.get(contEnt.Core_Contact_Id__c);
                                                                entts.add(contEnt);
                                                                lstConEntMap.put(contEnt.Core_Contact_Id__c, entts);
                                                            } 
                                                            else
                                                            {
                                                                
                                                                lstConEntMap.put(contEnt.Core_Contact_Id__c, new List<Core_Contact_Entitlement__c>{contEnt} );
                                                            }
                                                        }
            
            //Loop through CBTs and fetch entitlement for that business type - 1
            //Retrive list of contact entitlements for particluar contact from CBT - 2
            //Loop through list of entitlements from step 2 and only update entitlement which matched from step 1
            for(Contact_Business_Types__c conBT : listrecords) {
                params = params + 'Contact Id-'+ conBT.Contact__c + '-Business Type Id-'+conBT.Business_Types__c +'-Enttl Id- '+cbtEnttlMap.get(conBT.Business_Types__c) +';';
                Contact_Business_Types__c oldBT = oldMap.get(conBT.Id);
                if(oldBT != null && cbtEnttlMap != null && lstConEntMap != null && lstConEntMap.containsKey(conBT.Contact__c) &&
                   cbtEnttlMap.ContainsKey(conBT.Business_Types__c)&&skipsCEProcess == false) 
                {
                       Id busTypeEnttId = cbtEnttlMap.get(conBT.Business_Types__c);
                       List<Core_Contact_Entitlement__c> conEnttls = lstConEntMap.get(conBT.Contact__c);
                       //Condition to check if entitlement to be removed
                       if(oldBT.Status__c == System.Label.ER_Approved && conBT.Status__c == System.Label.ER_Rejection_Pending) {                          
                           for(Core_Contact_Entitlement__c conEnt : conEnttls){
                               if(busTypeEnttId == conEnt.Core_Entitlement_Id__c){
                                   conEnt.Core_Selected__c = false;
                                   conEnt.Core_Data_Loaded__c = true;
                                   conEnt.Core_Status__c = System.Label.ER_Pending;
                                   conEnttlToUpdate.add(conEnt);
                               }
                           }
                       }
                       //Condition to check if entitlement to be added
                       else if(oldBT.Status__c == System.Label.ER_Rejected && conBT.Status__c == System.Label.ER_Approval_Pending) {
                           for(Core_Contact_Entitlement__c conEnt : conEnttls){
                               if(busTypeEnttId == conEnt.Core_Entitlement_Id__c){
                                   conEnt.Core_Selected__c = true;
                                   conEnt.Core_Data_Loaded__c = true; //required to send A&E 2.0 message for AGS role
                                   conEnt.Core_Status__c = System.Label.ER_Pending;
                                   conEnttlToUpdate.add(conEnt);
                               }
                           }
                       }
                   }
                if(Test.isRunningTest() && conBT.Status_Reason__c == 'exception'){
                    throw new ER_ErrorUtility.CustomException('Empty');
                }
            }
            //Update entitlements
            if(conEnttlToUpdate.size() > 0 && (Schema.sObjectType.Core_Contact_Entitlement__c.isUpdateable()))
            {
                Core_Contact_Ent_BT_Handler.skipsCBTProcess = true;
                update conEnttlToUpdate;
            }
        }
        catch(Exception ex) {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in updateContactEntitlement', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    } 
    
    //Upsert Subscription for related contact when CBT added
    public static void upsertSubscription(List<Contact_Business_Types__c> conBusiness)
    {
        
        
        List<String> lst_str_entName = new List<String>();
        String str_entName;
        Set<Id> conIds = new Set<Id>();
        List<String> email = new List<String>();
        List<Id> cids = new List<Id>();
        String contactIds;
        List<String> statusValues = new List<String>();
        String cbtStatus;
        List<String> cbtype = new List<String>();
        List<String> cbName = new List<String>();
        String cbtName;
        //List<PRM_Registration_Request__c> regReq  = new List<PRM_Registration_Request__c>(); 
        Set<String> subscriptionValues =new Set<String>();
        Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
        Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
        Set<String> subscriptionIds = new Set<String>();
        Map<String,PRM_ContactSubscriptionAssociation__c> existingCSAMap = new Map<String,PRM_ContactSubscriptionAssociation__c>();
        List<PRM_ContactSubscriptionAssociation__c> contactSubscriptionUpsertList = new List<PRM_ContactSubscriptionAssociation__c>();
        
        String params = '';
        try{
           
            for(Contact_Business_Types__c conBT : conBusiness){    
                conIds.add(conBT.Contact__c); 
                
                
                statusValues.add(conBT.Status__c);
                cbtStatus = statusValues[0];
               
                
                cbtype.add(conBT.Business_Types__c);
                
                if(Test.isRunningTest() && conBT.Status_Reason__c == 'exception'){
                    throw new ER_ErrorUtility.CustomException('Empty');
                }
            }
            if(Schema.sObjectType.Business_Types__c.isAccessible()){
                //for(Business_Types__c bT :  [Select id, Name, Business_Type_Code__c from Business_Types__c where id =: cbtype /* AND Name =: System.Label.ER_CBT_DZP */ WITH SECURITY_ENFORCED]){
                //Ganesh Changes    
                for(Business_Types__c bT :  [Select id, Name from Business_Types__c where id =: cbtype /* AND Name =: System.Label.ER_CBT_DZP */ WITH SECURITY_ENFORCED]){
					cbName.add(bT.Name);
                    
                    cbtName = cbName[0];
                }
            }
            
            //if(cbtName.contains(System.Label.ER_CBT_DZP)){
                if(Schema.sObjectType.Contact.isAccessible()){
                    //Retrive contact email in CBT to check if registration record is available
                    //for(Contact con : [Select id, Email, AccountId from Contact where id =: conIds]){
                    //Ganesh Changes  
                    for(Contact con : [Select id, Email from Contact where id =: conIds]){
                        email.add(con.Email);
                        cids.add(con.id);
                        contactIds = cids[0];
                       
                    }
                }
            if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible()){ 
                List<PRM_Registration_Request__c> regRequestList = [Select Id, PRM_Email_ID__c, PRM_Subscriptions__c, Entitlement_Details__r.Name From PRM_Registration_Request__c Where PRM_Email_ID__c =: email and Entitlement_Details__r.Name != NULL WITH SECURITY_ENFORCED order by lastmodifieddate desc limit 1];
                if(regRequestList != null && regRequestList.size() > 0){ 
                    PRM_Registration_Request__c regRequest = regRequestList[0];
                    lst_str_entName.add(regRequest.Entitlement_Details__r.name);
                    if(String.isNotBlank(regRequest.PRM_Subscriptions__c))
                    {
                        subscriptionValues.addall(regRequest.PRM_Subscriptions__c.split(';'));
                        
                    }
                    /* for(PRM_Registration_Request__c regRequest : [Select Id, PRM_Email_ID__c, PRM_Subscriptions__c, Entitlement_Details__r.Name  From PRM_Registration_Request__c Where PRM_Email_ID__c =: email  order by lastmodifieddate desc])
					{


					lst_str_entName.add(regRequest.Entitlement_Details__r.name);
                    /*
                    if(regRequest.Entitlement_Details__r.name !=null)
                    {
                    
                    str_entName = lst_str_entName[0];
                    }
                    */
                                        /*
                    if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                    subscriptionValues.addall(regRequest.PRM_Subscriptions__c.split(';'));
                    
                    }
                    
                    }  */
                }
            }
                if(subscriptionValues != null && (Schema.sObjectType.PRM_Partner_Subscription__c.isAccessible()))
                {
                    for(PRM_Partner_Subscription__c sub : [Select Id,PRM_Subscription_Cd__c,Name from PRM_Partner_Subscription__c where PRM_Subscription_Cd__c IN : subscriptionValues]){
                        subscriptionMap.put(sub.PRM_Subscription_Cd__c,sub);
                        subscriptionIds.add(sub.id);
                       
                    }                    
                }
                
                //check for duplicate records:
                if(Schema.sObjectType.PRM_ContactSubscriptionAssociation__c.isAccessible()){
                    for(PRM_ContactSubscriptionAssociation__c csa : [Select id,PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Contact_Id__c from PRM_ContactSubscriptionAssociation__c where PRM_Partner_Subscription_Id__c in : subscriptionIds and PRM_Contact_Id__c =: contactIds WITH SECURITY_ENFORCED])
                    {
                        existingCSAMap.put(String.valueOf(csa.PRM_Partner_Subscription_Id__c)+String.valueOf(csa.PRM_Contact_Id__c),csa);
                    }
                }
                
                if(subscriptionValues != null && subscriptionMap != null && lst_str_entName !=null){
                    for(String value : subscriptionValues){
                        PRM_ContactSubscriptionAssociation__c cntSubscrAssoc = new PRM_ContactSubscriptionAssociation__c();
                        if(subscriptionMap.containsKey(value))
                        {                       
                            
                            if(cbtStatus == System.Label.ER_Approved){
                                
                                cntSubscrAssoc.PRM_Partner_Subscription_Id__c = subscriptionMap.get(value).Id;
                                cntSubscrAssoc.PRM_Contact_Id__c = contactIds;
                                 
                                if(existingCSAMap != null && existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(contactIds)) != null) { cntSubscrAssoc = existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(contactIds)) ; }
                                cntSubscrAssoc.PRM_Status_Nm__c = 'Active';
                                cntSubscrAssoc.PRM_Status_Reason_Txt__c ='Activated as contact is eligible for Subscription';//TWC729-8089 : Adding reason text 
                                contactSubscriptionUpsertList.add(cntSubscrAssoc);
                            }
                            else if(cbtStatus == System.Label.ER_Rejected)
                            {
                               
                                    cntSubscrAssoc.PRM_Partner_Subscription_Id__c = subscriptionMap.get(value).Id;
                                    cntSubscrAssoc.PRM_Contact_Id__c = contactIds;
                                    
                                    if(existingCSAMap != null && existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(contactIds)) != null) { cntSubscrAssoc = existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(contactIds)) ; }
                                    cntSubscrAssoc.PRM_Status_Nm__c = 'Inactive';
                                    cntSubscrAssoc.PRM_Status_Reason_Txt__c ='Inactivated as contact is not eligible for Subscription';//TWC729-8089 : Adding reason text 
                                    contactSubscriptionUpsertList.add(cntSubscrAssoc);                  
                                
                            }
                        }
                    }
                }
                
                if(contactSubscriptionUpsertList!= null && contactSubscriptionUpsertList.size()>0 ) 
                {
                    
                    if(Schema.sObjectType.PRM_ContactSubscriptionAssociation__c.isUpdateable() || Schema.sObjectType.PRM_ContactSubscriptionAssociation__c.isCreateable())
                    {
                        upsert contactSubscriptionUpsertList;  
                    }
                    else
                    {
                      
                        throw new CBTException('No Upsert access for PRM_ContactSubscriptionAssociation__c object');
                    }
                }
                
                            
            //}   //End of if checking label
            
            
        }
        catch(Exception ex) {
            execptionLogMethod(ex, 'updateContactEntitlement', params);
           /* ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in updateContactEntitlement', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params); */
        }
    }
    public class CBTException extends Exception {}
    
    public static void eRPMIntegrationCBTApproveReject(List<Contact_Business_Types__c> newCBTs, Map<Id, Contact_Business_Types__c> oldMap ) {
        string params = '';
        try {
            boolean isUpdated = false;           
            for(Contact_Business_Types__c cbt : newCBTs) {
                params = params + 'ContactId-'+ cbt.Contact__c + '-Business Type Id-'+cbt.Business_Types__c+';';
                Contact_Business_Types__c oldCBT = (Contact_Business_Types__c)Trigger.oldMap.get(cbt.Id);
                if((oldCBT.Status__c == System.Label.ER_Approval_Pending && cbt.Status__c == System.Label.ER_Approved) ||
                  (oldCBT.Status__c == System.Label.ER_Rejection_Pending && cbt.Status__c == System.Label.ER_Rejected)) {
                    isUpdated = true;
                }                
            }
            if(isUpdated)
            {
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<Contact_Business_Types__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
        }
        catch(Exception ex) {
            execptionLogMethod(ex, 'eRPMIntegrationCBTApproveReject',params);
          /*  ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in eRPMIntegrationCBTApproveReject', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params); */
        }
    }
    //This logic of removing ABT upon removal of last CBT is migrated to apex from flow as flow is throwing cpu limit exception
    //in case an account has large number of contacts
    @InvocableMethod(label='aBTRemovalValidationOnCBTRemoval' description='Removes ABT on the removal of last CBT of the Account')
    public static void aBTRemovalValidationOnCBTRemoval(List<String> cbtIdssList){
        Set<Id> accIdSet = New Set<Id>();
        Set<Id> busiTypeSet = New Set<Id>();
        Map<Id,Id> businessTypeABTMap = New Map<Id,Id>();
        List<Account_Business_Types__c> abtUpdList = New List<Account_Business_Types__c>();
        try{
            for(Contact_Business_Types__c cbt : [Select Id,Contact__c,Contact__r.AccountId,Business_Types__c FROM Contact_Business_Types__c WHERE Id IN: cbtIdssList]){
                accIdSet.add(cbt.Contact__r.AccountId); 
                busiTypeSet.add(cbt.Business_Types__c);
            }
            /*for(Contact_Business_Types__c existingCBT : [Select Id,Contact__c,Contact__r.AccountId,Business_Types__c,Status__c FROM 
                                                         Contact_Business_Types__c WHERE Contact__r.AccountId IN: accIdSet
                                                         AND Business_Types__c IN: busiTypeSet AND Status__c = 'Approved'
                                                         AND Id NOT IN: cbtIdssList]){ 
                                                             accIdSet.Remove(existingCBT.Contact__r.AccountId);
                                                             businessTypeABTMap.put(existingCBT.Contact__r.AccountId,existingCBT.Business_Types__c);
                                                             
                                                         }*/
            //Ganesh Changes
            Set<Id> removedCbtIds = new Set<Id>();
			for(String idStr : cbtIdssList){
    			removedCbtIds.add((Id)idStr);
				}

			for(Contact_Business_Types__c existingCBT : [SELECT Id, Contact__c, Contact__r.AccountId, Business_Types__c, Status__c FROM Contact_Business_Types__c
     													 WHERE Contact__r.AccountId IN :accIdSet
     													 AND Business_Types__c IN :busiTypeSet
     													 AND Status__c = 'Approved']){
    
             if(removedCbtIds.contains(existingCBT.Id)){
        		continue;
             }

    		accIdSet.remove(existingCBT.Contact__r.AccountId);
    		businessTypeABTMap.put(existingCBT.Contact__r.AccountId, existingCBT.Business_Types__c);
			}
            //Ganesh Changes End
            if(accIdSet != null && accIdSet.size() > 0){
                for(Account_Business_Types__c	abt : [SELECT Id,Account__c,Business_Types__c,Status__c FROM Account_Business_Types__c
                                                       WHERE Account__c IN: accIdSet AND Business_Types__c IN: busiTypeSet
                                                       AND Status__c != 'Rejected']){
                                                           if(!businessTypeABTMap.containsKey(abt.Account__c)){
                                                               abt.status__c = 'Rejected';
                                                               abtUpdList.add(abt);
                                                           }
                                                       }
                if(abtUpdList != null && abtUpdList.size() > 0){
                    database.update(abtUpdList,false);
                }
            }
        }catch(exception ex){
            execptionLogMethod(ex, 'aBTRemovalValidationOnCBTRemoval',null);
           /* ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in aBTRemovalValidationOnCBTRemoval', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, null); */
        }
    }
    public static void execptionLogMethod(exception ex, string methodName, string params){
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        custEx.Message = ex.getMessage();
        custEx.Cause = ex.getCause();
        custEx.StackTraceString = ex.getStackTraceString();
        custEx.LineNumber = ex.getLineNumber();                
        custEx.TypeName = ex.getTypeName();            
        ER_ErrorUtility.createLogEntry('Error in '+methodName, custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
    }
}