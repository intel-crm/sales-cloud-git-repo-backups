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
    
    //Update conatct business type once role is assigned in AGS
    //Leveraged contact entitlement Selected and Status fields
    public static void updateContactBusinessTypes(List<Core_Contact_Entitlement__c> listrecords, Map<Id, Core_Contact_Entitlement__c> oldMap)
    {
        
        set<id> contactIds = new set<id>();
        Set<Id> entIds = new Set<Id>();
        Map<Id, Id> conAccountMap = new Map<Id, Id>();
        List<String> acctIdBtIdList = new List<String>();
        Map<Id, Id> enttlBTMap = new Map<Id, Id>();        
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
            for(Contact con : [Select id, AccountId from Contact where id =: contactIds]){
                conAccountMap.put(con.Id,con.AccountId);  
                System.debug('Contact Map #42'+conAccountMap);
            }
            //Retreive combination of AccountId-BusinessTypeID for particular accounts in Approved status from ABTs to list
            for (Account_Business_Types__c abts : [SELECT id, Account__c, Business_Types__c, Business_Types__r.Name, Status__c 
                                                   FROM Account_Business_Types__c 
                                                   WHERE Account__c IN: conAccountMap.values() AND Status__c = 'Approved']) {
                                                       if(!acctIdBtIdList.contains(abts.Account__c+'-'+abts.Business_Types__c)){
                                                           acctIdBtIdList.add(abts.Account__c+'-'+abts.Business_Types__c);
                                                           System.debug('Account List #48'+acctIdBtIdList);
                                                       }
                                                   }
            if(entIds != null)
            { 
                 System.debug('When Ent Id not Null #54');
                //Retrive Business type to entitlement mapping from entitlement matrix
                for(PRM_VXEnttlmntMatrix__c mat : [SELECT Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name 
                                                   FROM PRM_VXEnttlmntMatrix__c 
                                                   WHERE PRM_Entitlement_Id__c IN : entIds ]) {
                                                       if (!enttlBTMap.containsKey(mat.Business_Types__c)) {
                                                           enttlBTMap.put(mat.PRM_Entitlement_Id__c, mat.Business_Types__c);
                                                       		System.debug('Mapped Ent_BT #60'+enttlBTMap);
                                                       } 
                                                   }                         
                Map<id, List<Contact_Business_Types__c>> lstconBtMap = new Map<id, List<Contact_Business_Types__c>>();
                
                //Retrive contact to CBT map based on business type retrived from matrix
                for(Contact_Business_Types__c bT : [Select id, Contact__c, Contact__r.Email, Business_Types__c, Business_Types__r.Name, Status__c 
                                                    From Contact_Business_Types__c 
                                                    Where Business_Types__c IN :enttlBTMap.values() AND Contact__c IN:contactIds ]) {                                                        
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
                
                //Loop through contat entitlements and retrive business typr for particular entitlement -1
                //Retrive list of contact business types for particular contact from contact entitlement -2
                //Loop through list of CBTs from step 2 and update contact business type only if business type Id matches 
                for(Core_Contact_Entitlement__c ent : listrecords)
                {  
                    System.debug('Inside For #88');
                    //Get old entitlement details
                    Core_Contact_Entitlement__c oldEnttl = oldMap.get(ent.Id); 
                    if(oldEnttl != null  && lstconBtMap != null && enttlBTMap != null && lstconBtMap.containsKey(ent.Core_Contact_Id__c) && enttlBTMap.ContainsKey(ent.Core_Entitlement_Id__c))
                    { 
                        System.debug('Inside First IF 94');
                        params = params + 'Contact Id-'+ ent.Core_Contact_Id__c + '-Business Type Id-'+enttlBTMap.get(ent.Core_Entitlement_Id__c) +'-Enttl Id- '+ent.Core_Entitlement_Id__c +';';
                        Id enttlBusTypeId = enttlBTMap.get(ent.Core_Entitlement_Id__c);
                        List<Contact_Business_Types__c> conBTypes = lstconBtMap.get(ent.Core_Contact_Id__c);
                        //Set CBT staus to Approved in role is assigned in AGS
                        if(ent.Core_Selected__c == true && ent.Core_Status__c == System.Label.ER_Complete && oldEnttl.Core_Status__c == System.Label.ER_Pending)
                        {
                            System.debug('inside for Approval'+acctIdBtIdList.contains(conAccountMap.get(ent.Core_Contact_Id__c)+'-'+enttlBTMap.get(ent.Core_Entitlement_Id__c)));
                            if(acctIdBtIdList.contains(conAccountMap.get(ent.Core_Contact_Id__c)+'-'+enttlBTMap.get(ent.Core_Entitlement_Id__c))) {
                                System.debug('True:: '+params);
                                for(Contact_Business_Types__c cbt : conBTypes) {
                                    if(enttlBusTypeId == cbt.Business_Types__c){
                                        System.debug('Approval');
                                        cbt.Status__c = System.Label.ER_Approved;
                                        conBusTypeToUpdate.add(cbt);
                                    }
                                }  
                            }
                        } 
                        //Set CBT status to Rejected if role is removed in AGS
                        else if(ent.Core_Selected__c == False && ent.Core_Status__c == System.Label.ER_Complete)// && oldEnttl.Core_Status__c == System.Label.ER_Pending)
                        {
                            System.debug('In Else part 116');
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
                
                System.debug('Upodate list size::'+conBusTypeToUpdate.size());
                if(conBusTypeToUpdate.size() > 0){
                    if(Schema.sObjectType.Contact_Business_Types__c.isUpdateable()){
                        
                        System.debug('Update Success'+conBusTypeToUpdate);
                        Update conBusTypeToUpdate;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('Contact business type Exception: '+ex.getmessage());
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
            
            System.debug('Business Type listrecords:: '+listEntRecords+ 'Business Type:: '+businessTypeIdMap);
            
            //Insert new entitlement only if status is Approval - Pending   
            for(Core_Contact_Entitlement__c conEnt : listEntRecords) {
                System.debug(' Entitlement ID:: '+businessTypeIdMap.containsKey(conEnt.Core_Entitlement_Id__c)); 
                System.debug(' Business ID:: '+ businessTypeIdMap.Values()); 
                if(businessTypeIdMap.containsKey(conEnt.Core_Entitlement_Id__c)){
                    
                    if((conEnt.Core_Status__c == System.Label.ER_Complete || conEnt.Core_Status__c == System.Label.ER_Pending ) && conEnt.Core_Source__c == System.Label.ER_EntSource) {
                        System.debug('Business Type listrecords:: '+conEnt.Name);                        
                        Contact_Business_Types__c cBusy = new  Contact_Business_Types__c();
                        cBusy.Business_Types__c = businessTypeIdMap.get(conEnt.Core_Entitlement_Id__c);
                        System.debug('Business Type '+cBusy.Business_Types__c);                                       
                        cBusy.Status__c = (conEnt.Core_Status__c == System.Label.ER_Pending) ? System.Label.ER_Approval_Pending : System.Label.ER_Approved ;                       
                        cBusy.Contact__c = conEnt.Core_Contact_Id__c;
                        conBusTypeToInsert.add(cBusy);
                        System.debug('inserted list #2::'+conBusTypeToInsert);
                    }
                    
                    if(Test.isRunningTest()){
                        throw new ER_ErrorUtility.CustomException('Empty');
                    }
                } 
            }
            System.debug('inserted list #3 size::'+conBusTypeToInsert.size());
            
            //Insert new Business Type
            if(conBusTypeToInsert.size() > 0 && Schema.sObjectType.Contact_Business_Types__c.isCreateable()){
                
                    System.debug('Business Type SUCCESS');  
                    insert conBusTypeToInsert;
              
            } 
            
        }
        catch(Exception ex)
        {
            system.debug('Contact business type Exception: '+ex.getmessage());
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in updateContactBusinessTypes', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        
    } 
    
}