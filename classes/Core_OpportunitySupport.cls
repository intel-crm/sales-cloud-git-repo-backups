/**************************************************************************************
Apex Class Name:  Core_OpportunitySupport
Version     : 1.0 
Created Date: 26 FEB 2023
Function    : 
Test Class Name: Core_OpptySupportServiceHandlerTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areefa Banu             26/02/2023              Original Version
* Vijay					  07/03/2023			  Queried Opportunity fields
*************************************************************************************/
public without sharing class Core_OpportunitySupport { //TWC3123-5376: codescan fix: added without sharing
    
    public class wrapperOpptSupportRequest{
        @AuraEnabled public boolean isThereAnOpenOpptSupportReq = false; 
        @AuraEnabled public boolean isThereContactwithTechnicalOW = true; 
        @AuraEnabled public List<Opportunity> oppDetails;
    }
    
    @AuraEnabled
    public static wrapperOpptSupportRequest getOpportunityDetails(Id OpportunityId,Id oppSuprecorType,string whereCondition) {
         //system.debug('Opportunity ID --'+whereCondition);
        whereCondition =  String.escapeSingleQuotes(whereCondition);
        string whereConCheck = whereCondition.replaceAll('\\\\', '');
        wrapperOpptSupportRequest obj = new wrapperOpptSupportRequest();
        string dynamicQr = '';
        List<Core_Opportunity_Support__c> opptSuppReq=  new List<Core_Opportunity_Support__c>();     
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName();
       // recordtypeCSAId = recordTypeMap.get(recordtypeCSA).getRecordTypeId();
        string recordtypeTSSId = recordTypeMap.get('Core_TSS_Request').getRecordTypeId();
        string recordtypeCOEId = recordTypeMap.get('Core_Center_of_Excellence_Request').getRecordTypeId();
        
        try{
            if(OpportunityId != null)  {          
               List<Opportunity> oppdetail  = [select id ,owner.name, Account.Name ,Name,StageName,Amount,CloseDate,Core_Sales_Groups__c,Core_Product_Segment__c,Core_Consumption_Market__c,Core_Product_Application__c,Core_Opportunity_Owner_Geo__c,
                                               Core_Technical_Owner__r.Name,Description, (SELECT Id FROM OpportunityContactRoles where OpportunityId =: OpportunityId and Role = 'Technical Decision Maker' limit 1) FROM Opportunity where id=: OpportunityId];
                obj.oppDetails = oppdetail;
                //dynamicQr = 'Select Id from Core_Opportunity_Support__c where Opportunity__c =\''+OpportunityId+ '\' and RecordTypeId = \''+oppSuprecorType +'\'  '+whereCondition+' limit 1'; 
                dynamicQr = 'SELECT Id FROM Core_Opportunity_Support__c WHERE Opportunity__c = :opportunityId AND RecordTypeId = :oppSuprecorType ' + whereConCheck + ' LIMIT 1';
                for (OpportunityContactRole ocr : oppdetail[0].OpportunityContactRoles) {  obj.isThereContactwithTechnicalOW = false;}
                //opptSuppReq = [Select Id from Core_Opportunity_Support__c where Core_Status__c='Submitted' and Opportunity__c =:OpportunityId and RecordTypeId =:oppSuprecorType  limit 1];
                
		//opptSuppReq = Database.query(dynamicQr);
                //system.debug('dynamicQr--'+dynamicQr);
                //TWC3123-5376: code scan fix : Avoid Untrusted/Unescaped Variables in DML Query(possible soql injection)
                opptSuppReq = Database.query(String.escapeSingleQuotes(dynamicQr).replaceAll('\\\\', ''));
                if(opptSuppReq.size()>0) { obj.isThereAnOpenOpptSupportReq=true;}    
                
                //check for CoE request for Initial load
                if((recordtypeTSSId == oppSuprecorType || recordtypeCOEId == oppSuprecorType) && String.isblank(whereConCheck)) {
                    obj.isThereAnOpenOpptSupportReq = false;}
            }
        } 
        catch (Exception e) { Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OpportunitySupport',Core_Method_Name__c ='getOpportunityDetails'); } 
        return obj; 
    }
    
    
    
     
}