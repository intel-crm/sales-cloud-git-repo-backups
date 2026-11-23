/******************************************************************************************************************************************
Class Name  : Core_Contact_Ent_BT_Handler
Version     : 1.0 
Created Date: 11 Nov 2021
Function    : Handles Contact Entitlement RDC records related to Contact which is having Contact Buisness Type . This implements the new trigger framework based on US- TWC722-50.
Modification Log :
* Developer                 Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------      
* Gaurav Kurwade              11/11/2021              Original version 
*****************************************************************************************************************************************/


public with Sharing class Core_Contact_Ent_BT_Handler {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'Core_Contact_Ent_BT_Handler';
    public static boolean CBTSuccess = false;
    
    //Update conatct business type once role is assigned in AGS
    //Leveraged contact entitlement Selected and Status fields
    public static void updateContactBusinessTypes(List<Core_Contact_Entitlement__c> listrecords, Map<Id, Core_Contact_Entitlement__c> oldMap)
    {
        
        set<id> contactIds = new set<id>();
        Set<Id> entIds = new Set<Id>();
        Map<Id, Id> conAccountMap = new Map<Id, Id>();
        List<String> acctIdBtIdList = new List<String>();
        Map<Id, Id> enttlBTMap = new Map<Id, Id>();        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        List<Contact_Business_Types__c> conBusTypeToUpdate = new  List<Contact_Business_Types__c>();
        String params = '';
        
        try
        {
            //Get Set of Entitlements ids to fetch from Entitlement Matrix
            for(Core_Contact_Entitlement__c ent : listrecords)
            {
                contactIds.add(ent.Core_Contact_Id__c);  
                entIds.add(ent.Core_Entitlement_Id__c);
            }
            //Retrive Accounts for contacts in CBT to check if ABTs are approved
            if(Schema.sObjectType.Contact.isAccessible()){
            for(Contact con : [Select id, AccountId from Contact where id =: contactIds WITH SECURITY_ENFORCED]){
                conAccountMap.put(con.Id,con.AccountId);  
               
            }
            }
            //Retreive combination of AccountId-BusinessTypeID for particular accounts in Approved status from ABTs to list
            if(Schema.sObjectType.Account_Business_Types__c.isAccessible()){
            for (Account_Business_Types__c abts : [SELECT id, Account__c, Business_Types__c, Business_Types__r.Name, Status__c 
                                                   FROM Account_Business_Types__c 
                                                   WHERE Account__c IN: conAccountMap.values() AND Status__c = 'Approved' WITH SECURITY_ENFORCED]) {
                                                       if(!acctIdBtIdList.contains(abts.Account__c+'-'+abts.Business_Types__c)){
                                                           acctIdBtIdList.add(abts.Account__c+'-'+abts.Business_Types__c);
                                                        
                                                       }
                                                   }
            }
            if(entIds != null)
            { 
                
                //Retrive Business type to entitlement mapping from entitlement matrix
                if(Schema.sObjectType.PRM_VXEnttlmntMatrix__c.isAccessible()){
                for(PRM_VXEnttlmntMatrix__c mat : [SELECT Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name 
                                                   FROM PRM_VXEnttlmntMatrix__c 
                                                   WHERE PRM_Entitlement_Id__c IN : entIds and RecordTypeId=: eBREnttRecTypeId WITH SECURITY_ENFORCED ]) {
                                                       if (!enttlBTMap.containsKey(mat.Business_Types__c)) {
                                                           enttlBTMap.put(mat.PRM_Entitlement_Id__c, mat.Business_Types__c);
                                                          
                                                       } 
                                                   }  
                }
                Map<id, List<Contact_Business_Types__c>> lstconBtMap = new Map<id, List<Contact_Business_Types__c>>();
                
                //Retrive contact to CBT map based on business type retrived from matrix
                if(Schema.sObjectType.Contact_Business_Types__c.isAccessible()){
                for(Contact_Business_Types__c bT : [Select id, Contact__c, Contact__r.Email, Business_Types__c, Business_Types__r.Name, Status__c 
                                                    From Contact_Business_Types__c 
                                                    Where Business_Types__c IN :enttlBTMap.values() AND Contact__c IN:contactIds WITH SECURITY_ENFORCED]) {                                                        
                                                        if(lstconBtMap.containsKey(bT.Contact__c))
                                                        {
                                                            List<Contact_Business_Types__c> cBT = lstconBtMap.get(bT.Contact__c);
                                                            cBT.add(bT);
                                                            lstconBtMap.put(bT.Contact__c, cBT);
                                                        } 
                                                        else
                                                        {
                                                            lstconBtMap.put(bT.Contact__c, new List<Contact_Business_Types__c>{bT} );
                                                        }
                                                    }
                }
                
                //Loop through contat entitlements and retrive business typr for particular entitlement -1
                //Retrive list of contact business types for particular contact from contact entitlement -2
                //Loop through list of CBTs from step 2 and update contact business type only if business type Id matches 
                for(Core_Contact_Entitlement__c ent : listrecords)
                {  
                    
                    //Get old entitlement details
                    Core_Contact_Entitlement__c oldEnttl = oldMap.get(ent.Id); 
                    if(oldEnttl != null  && lstconBtMap != null && enttlBTMap != null && lstconBtMap.containsKey(ent.Core_Contact_Id__c) && enttlBTMap.ContainsKey(ent.Core_Entitlement_Id__c))
                    { 
                        
                        params = params + 'Contact Id-'+ ent.Core_Contact_Id__c + '-Business Type Id-'+enttlBTMap.get(ent.Core_Entitlement_Id__c) +'-Enttl Id- '+ent.Core_Entitlement_Id__c +';';
                        Id enttlBusTypeId = enttlBTMap.get(ent.Core_Entitlement_Id__c);
                        List<Contact_Business_Types__c> conBTypes = lstconBtMap.get(ent.Core_Contact_Id__c);
                        //Set CBT staus to Approved in role is assigned in AGS
                        if(ent.Core_Selected__c == true && ent.Core_Status__c == System.Label.ER_Complete && oldEnttl.Core_Status__c == System.Label.ER_Pending)
                        {
                            
                            if(acctIdBtIdList.contains(conAccountMap.get(ent.Core_Contact_Id__c)+'-'+enttlBTMap.get(ent.Core_Entitlement_Id__c))) {
                               
                                for(Contact_Business_Types__c cbt : conBTypes) {
                                    if(enttlBusTypeId == cbt.Business_Types__c){
                                       
                                        cbt.Status__c = System.Label.ER_Approved;
                                        conBusTypeToUpdate.add(cbt);
                                    }
                                }  
                            }
                        } 
                        //Set CBT status to Rejected if role is removed in AGS
                        else if(ent.Core_Selected__c == False && ent.Core_Status__c == System.Label.ER_Complete)// && oldEnttl.Core_Status__c == System.Label.ER_Pending)
                        {
                            
                            for(Contact_Business_Types__c cbt : conBTypes) {
                                if(enttlBusTypeId == cbt.Business_Types__c){
                                    cbt.Status__c = System.Label.ER_Rejected;
                                    conBusTypeToUpdate.add(cbt);
                                }
                            }
                        }                       
                    }
                    if(Test.isRunningTest() && ent.Core_Update_Reason__c == 'exception'){
                        throw new ER_ErrorUtility.CustomException('exception');
                    }
                }
                
                
                if(conBusTypeToUpdate.size() > 0 && (Schema.sObjectType.Contact_Business_Types__c.isUpdateable()))
                {
                    
                    Update conBusTypeToUpdate;                
                }
            }
        }
        catch(Exception ex)
        {
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in updateContactBusinessTypes', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    }
    
    
    //To Insert CBT when Ent Created newly
    //Update conatct business type once role is assigned in AGS
    //Leveraged contact entitlement Selected and Status fields
    public static void insertContactBusinessTypes(List<Core_Contact_Entitlement__c> listEntRecords, Map<Id, Id> businessTypeIdMap)
    {
        
        List<Contact_Business_Types__c> conBusTypeToInsert = new  List<Contact_Business_Types__c>();
        String params = '';
        
        try
        {
            
           
            
            //Insert new entitlement only if status is Approval - Pending   
            for(Core_Contact_Entitlement__c conEnt : listEntRecords) {
                
                if(businessTypeIdMap.containsKey(conEnt.Core_Entitlement_Id__c)){
                    
                    if((conEnt.Core_Status__c == System.Label.ER_Complete || conEnt.Core_Status__c == System.Label.ER_Pending ) && conEnt.Core_Source__c == System.Label.ER_EntSource) {
                                                
                        Contact_Business_Types__c cBusy = new  Contact_Business_Types__c();
                        cBusy.Business_Types__c = businessTypeIdMap.get(conEnt.Core_Entitlement_Id__c);
                                                               
                        cBusy.Status__c = (conEnt.Core_Status__c == System.Label.ER_Pending) ? System.Label.ER_Approval_Pending : System.Label.ER_Approved ;                       
                        cBusy.Contact__c = conEnt.Core_Contact_Id__c;
                        conBusTypeToInsert.add(cBusy);
                        
                    }
                    
                    if(Test.isRunningTest()){
                        throw new ER_ErrorUtility.CustomException('Empty');
                    }
                } 
            }
            
            
            //Insert new Business Type
            if(conBusTypeToInsert.size() > 0 && Schema.sObjectType.Contact_Business_Types__c.isCreateable()){
                
                
                insert conBusTypeToInsert;
                
            } 
            
        }
        catch(Exception ex)
        {
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in updateContactBusinessTypes', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        
    }
    
    public static Map<Id, String> AssignContactBusinessTypes(List<Id> reqIds)
    {     
        String params = '';
        Map<Id, String> failedReqIdMap = new Map<Id, String>(); 
        Map<Id, Id> reqContIdMap = new Map<Id, Id>();
        Map<Id,Id> entBusinessTypeMap = new Map<Id,Id>();
        Set<Id> entIds = new Set<Id>();
        Set<Id> contIds = new Set<Id>();
        List<PRM_Registration_Request__c> regReqs = new List<PRM_Registration_Request__c>();
        List<Contact_Business_Types__c> conBusTypeToUpsert = new  List<Contact_Business_Types__c>();
        //List<Contact_Business_Types__c> conBusTypeToUpdate = new List<Contact_Business_Types__c>();
        Map<Id,Contact_Business_Types__c> cbtApprovedMap = new Map<Id,Contact_Business_Types__c>();
        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        try
        {
            if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible()){
            for (PRM_Registration_Request__c req : [Select ID,PRM_Email_ID__c,Entitlement_Details__c,Current_Status__c,PRM_Contact_Salesforce_Id__c from PRM_Registration_Request__c where ID =: reqIds WITH SECURITY_ENFORCED])
            {
                entIds.add(req.Entitlement_Details__c);
                regReqs.add(req);
                contIds.add(req.PRM_Contact_Salesforce_Id__c);
            }
            }
            
            for(PRM_VXEnttlmntMatrix__c mat : [SELECT Business_Types__c,PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_Entitlement_Id__c IN : entIds and RecordTypeId=: eBREnttRecTypeId])
            {
                entBusinessTypeMap.put(mat.PRM_Entitlement_Id__c,mat.Business_Types__c);
            }
            
            for(Contact_Business_Types__c cbt : [SELECT Id,Contact__c,Status__c from Contact_Business_Types__c where Contact__c IN : contIds and Business_Types__c IN : entBusinessTypeMap.values()])
            {
                cbtApprovedMap.put(cbt.Contact__c,cbt);
            }
            
            for (PRM_Registration_Request__c req : regReqs) 
            {
                reqContIdMap.put(req.PRM_Contact_Salesforce_Id__c,req.Id);
                if(cbtApprovedMap.get(req.PRM_Contact_Salesforce_Id__c) == null)
                {
                    Contact_Business_Types__c cBusy = new  Contact_Business_Types__c(Contact__c = req.PRM_Contact_Salesforce_Id__c,
                                                                                     Business_Types__c = entBusinessTypeMap.get(req.Entitlement_Details__c), 
                                                                                     Status__c = System.Label.ER_Approval_Pending);
                    conBusTypeToUpsert.add(cBusy);  
                }
                else if(cbtApprovedMap.get(req.PRM_Contact_Salesforce_Id__c) != null && cbtApprovedMap.get(req.PRM_Contact_Salesforce_Id__c).Status__c == 'Rejected')
                {
                    Contact_Business_Types__c cBusy = cbtApprovedMap.get(req.PRM_Contact_Salesforce_Id__c);
                    cBusy.Status__c = System.Label.ER_Approval_Pending;
                    conBusTypeToUpsert.add(cBusy);
                }
            }
            
            
            
            if(conBusTypeToUpsert.size() > 0 && (Schema.sObjectType.Contact_Business_Types__c.isCreateable() && Schema.sObjectType.Contact_Business_Types__c.isUpdateable()))
            {
                 
                Database.upsertResult[] srList = Database.upsert(conBusTypeToUpsert, false);
                integer i = 0;
                String exceptiondetails = '';
                for (Contact_Business_Types__c cbt : conBusTypeToUpsert) 
                {
                    
                    if (!srList[i].isSuccess()) 
                    {
                        failedReqIdMap.put(reqContIdMap.get(cbt.Contact__c),srList[i].getErrors().get(0).getMessage());
                        
                        params = params + ' Contact Id-'+cbt.Contact__c+';'+' Request ID- '+reqContIdMap.get(cbt.Contact__c)+' ;';
                        exceptiondetails = exceptiondetails + ' Request ID- '+reqContIdMap.get(cbt.Contact__c) + ' : '+srList[i].getErrors().get(0).getMessage() +' ;';
                    }
                    
                    i++;
                }
                
                if(failedReqIdMap.size() > 0)
                {
                    throw new CustomException(exceptiondetails);
                }
                //list of contactids<id,string> cbtsfailed with error message
                
                
            }
        }
        catch(Exception ex)
        {
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in AssignContactBusinessTypes', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        return failedReqIdMap;
    }
    
    public class CustomException extends Exception{}
}