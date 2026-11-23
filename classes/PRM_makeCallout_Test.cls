@isTest
public class PRM_makeCallout_Test {
    
    //test data creation
    @isTest
    
    static void setupDataCreation()
    {
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdOPIDRec = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get('OPID Recommendation').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';    
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        /*PRM_Value_Exchange_Recommendation__c vxRecommnedation1 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation1.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation1.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation1.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation1.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation1.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation1.PRM_Market_Type_Nm__c='Mature';
        vxRecommnedation1.PRM_Recommendation_Type_Nm__c='OPID';
        try{
            insert vxRecommnedation1; 
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
        
        PRM_Value_Exchange_Recommendation__c vxRecommnedation2 = new PRM_Value_Exchange_Recommendation__c();
        vxRecommnedation2.RecordTypeId=recordTypeIdOPIDRec;
        vxRecommnedation2.PRM_Account_Id__c=newAccount.Id;
        vxRecommnedation2.PRM_Tier_Id__c=cpl.Id;
        vxRecommnedation2.PRM_Recommendation_Status_Nm__c = 'In Process';
        vxRecommnedation2.PRM_Partner_Role_Nm__c='Solution Integrator';
        vxRecommnedation2.PRM_Market_Type_Nm__c='Mature';
        vxRecommnedation2.PRM_Grouping_Method_Nm__c='CTRY';
        vxRecommnedation2.PRM_Recommendation_Type_Nm__c='OPID';
        insert vxRecommnedation2;
        */
       
        Core_Integration_Outbound_Message__c obmsrec=new Core_Integration_Outbound_Message__c();
        obmsrec.Core_Tags__c=newAccount.id;
    obmsrec.Core_Status__c='Successful';
        obmsrec.Core_MessageType__c='OPID Request' ;
        insert obmsrec;
        List<Core_Integration_Outbound_Message__c> listofIntegrationOutMsg = [SELECT Id 
                                                                              FROM Core_Integration_Outbound_Message__c 
                                                                              limit 1 ];
        List<id> OBMIds = new List<id>();
        For (Core_Integration_Outbound_Message__c outMsg : listofIntegrationOutMsg ){
            OBMIds.add(outMsg.Id);
        }
            System.enqueueJob(new PRM_makeCallout(OBMIds));
        
    }
    
}