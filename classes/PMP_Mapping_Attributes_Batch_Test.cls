@isTest
public class PMP_Mapping_Attributes_Batch_Test {
    
    @isTest public static void batchTest(){
        
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        
        Core_Trigger_Executions__c cs1 = new Core_Trigger_Executions__c (Name = 'MPI_Mem_Handler',
                                                                         Core_Active__c = true,
                                                                         Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                         Core_Object__c = 'PMP_Company__c',
                                                                         Core_Trigger_Events__c = 'After Insert, After Update',
                                                                         Core_Description__c = 'Trigger to populate MPI records on Solution');
        insert cs1;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
        newPagAccount.Core_IPA_Partner_Segment__c = 'Data Center';
        update newPagAccount;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
           Core_Country_Reference__c  cntRef = new Core_Country_Reference__c();
        cntRef.Name = 'Aruba';
        cntRef.Core_Geo__c='ASMO';
        cntRef.Core_Sub_Geo__c='LAR';
        cntRef.Core_ISO_Code__c = 'ABW';
        Insert cntRef;
        
        
        
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'India';
        company.PMP_Account_Id__c=newAccount.Id;
        company.PMP_Company_Lifecycle_Status_Nm__c ='Draft'; 
        insert company;
        
        
        PMP_Partner_Tier__c pt= new PMP_Partner_Tier__c();
        pt.name= 'Gold';
        insert pt;
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Partner_Tier__c = pt.Id;
        attr.PMP_Marketing_Profile_Id__c = company.Id;
        insert attr;
        
        Test.startTest();
        Database.executeBatch(new PMP_Mapping_Attributes_Creation_Batch(new Set<Id>{company.Id}));
        //Database.executeBatch(new PMP_Mapping_Attributes_Creation_Batch());
        List<PMP_Marketing_Profile_Attributes_Mapping__c> attrmaplst = [select id from PMP_Marketing_Profile_Attributes_Mapping__c];
        system.assertNotEquals(null, attrmaplst.size());
        Test.stopTest();
    }
    
}