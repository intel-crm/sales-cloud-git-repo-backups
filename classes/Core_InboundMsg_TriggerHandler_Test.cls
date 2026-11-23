/*********************************************************************************************************************
Class Name  : PRM_IntOutboundMessageUtilityTest
Version       : 1.0
Created Date  : 25th Oct 2021
Function      : Test Class for 'Core_InboundMsg_TriggerHandler'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* 

*********************************************************************************************************************/
@isTest
public class Core_InboundMsg_TriggerHandler_Test {
    @testSetup
    public static void setUpData() {
         Account intelAccount = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'CCG Sales Group',Core_CIM_ID__c='12345',
                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi',Core_OnePartnerID__c ='12345678',
                                           ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert intelAccount;
    }
    @isTest static void testMehod1(){
        
        Account intelAccount = [Select id,Core_CIM_ID__c from Account where Name = 'IntelAccount1' limit 1];  
        
        OPID_Sync_Request__c opidRec = new OPID_Sync_Request__c();
            opidRec.OP_CIMID__c = intelAccount.Core_CIM_ID__c;
            opidRec.Status__c = 'Sync Response Received';
            opidRec.OPID_Account__c = intelAccount.Id;
            insert opidRec;
            
        set<Id> cimids = new Set<Id>();
            Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
            inboundTable.Core_Status__c ='LOAD COMPLETE';
            inboundTable.Core_SalesCloud_AccountID__c = intelAccount.Id;
            inboundTable.Core_OnePartnerID__c = 2222 ;
            inboundTable.Core_CIM_ID__c=Integer.valueOf(intelAccount.Core_CIM_ID__c);
            inboundTable.Core_OnePartner_Account_Name__c = 'OPID '+ inboundTable.Core_OnePartnerID__c;
            inboundTable.OPID_Sync_Request__c = opidRec.Id;
        	insert inboundTable;
        
        	inboundTable = [SELECT Id,Core_Status__c FROM Core_OnePartner_Inbound_Message__c WHERE Id =: inboundTable.Id];
        	inboundTable.Core_Status__c = 'PROCESSED';
        	update inboundTable;
        
        	Core_OnePartner_Inbound_Message__c errRec = new Core_OnePartner_Inbound_Message__c();
            errRec.Core_Status__c ='LOAD COMPLETE';
            errRec.Core_SalesCloud_AccountID__c = intelAccount.Id;
            errRec.Core_OnePartnerID__c = 2222 ;
            errRec.Core_CIM_ID__c=Integer.valueOf(intelAccount.Core_CIM_ID__c);
            errRec.Core_OnePartner_Account_Name__c = 'OPID '+ errRec.Core_OnePartnerID__c;
            errRec.OPID_Sync_Request__c = opidRec.Id;
        	insert errRec;
            errRec = [SELECT Id,Core_Status__c,Core_OnePartnerID__c,Error_Description__c FROM Core_OnePartner_Inbound_Message__c WHERE Id =: errRec.Id];
        	errRec.Core_Status__c = 'FAILED';
        	errRec.Error_Description__c ='Exception Record';
        	update errRec;
        	
        	//cimids.add(inboundTable.Id);
        	//Core_InboundMsg_TriggerHandler.updateOnDemandSyncRecords(cimids);
        }
        @isTest static void testMehod2(){
            Account intelAccount = [Select id,Core_CIM_ID__c from Account where Name = 'IntelAccount1' limit 1];  

            Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
            inboundTable.Core_Status__c ='NEW';
            inboundTable.Core_SalesCloud_AccountID__c = intelAccount.Id;
            inboundTable.Core_OnePartnerID__c = 2222 ;
            inboundTable.Core_CIM_ID__c=Integer.valueOf(intelAccount.Core_CIM_ID__c);
            inboundTable.Core_OnePartner_Account_Name__c = 'OPID '+ inboundTable.Core_OnePartnerID__c;
            inboundTable.PRM_Retry_Counter__c =1;
        	insert inboundTable;

            inboundTable.Core_Status__c = 'FAILED';
            inboundTable.Error_Description__c ='UNABLE_TO_LOCK_ROW';
        	update inboundTable;
        }
}