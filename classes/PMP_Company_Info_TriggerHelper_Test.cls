@isTest
public class PMP_Company_Info_TriggerHelper_Test {
    
    @isTest
    public static void  insertUtility() { 
        
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
        
        //Set<Id> accIds = new Set<Id> { newAccount.Id };
            
       Core_Country_Reference__c cntRef = new Core_Country_Reference__c();
        cntRef.Name = 'Aruba';
        cntRef.Core_Geo__c='ASMO';
        cntRef.Core_Sub_Geo__c='LAR';
        cntRef.Core_ISO_Code__c = 'ABW';
        Insert cntRef;
        
        List<PMP_Company__c> cmpList = new List<PMP_Company__c>();
        Map<id,PMP_Company__c>  comMap =new Map<id,PMP_Company__c>(); 
        
        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'India';
        company.PMP_Account_Id__c=newAccount.Id;
        company.PMP_Company_Lifecycle_Status_Nm__c ='Draft';
        insert company;
        comMap.put(company.id,company);
        
        PMP_Company__c company1 = new PMP_Company__c();
        company1.id =company.id;
        company1.PMP_Partner_Country_Txt__c = 'Aruba';
        company1.PMP_Company_Lifecycle_Status_Nm__c ='Update Required';
       Test.startTest();
       update company1;
       cmpList.add(company1); 
       system.assertEquals('Aruba', company1.PMP_Partner_Country_Txt__c,'Company Name is matched');
       Test.stopTest();
        
    }
    
    @isTest
    public static void  insertUtility1() { 
        
          Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update,before Insert,before Update',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        
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
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        
        Set<Id> accIds = new Set<Id> { newAccount.Id };
            
         Core_Country_Reference__c cntRef = new Core_Country_Reference__c();
        cntRef.Name = 'India';
        cntRef.Core_Geo__c='India';
        cntRef.Core_Sub_Geo__c='India';
        cntRef.Core_ISO_Code__c = 'IND';
        Insert cntRef;
        
        List<PMP_Company__c> cmpList = new List<PMP_Company__c>();
        Set<Id> compIds = new Set<Id>();
        List<PMP_Company__c> compList = new List<PMP_Company__c>();

        PMP_Company__c company = new PMP_Company__c();
        company.Name='company1';
        company.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company.PMP_Partner_Country_Txt__c = 'IND';
        company.PMP_Account_Id__c=newAccount.Id;
        compList.add(company);

        PMP_Company__c company12 = new PMP_Company__c();
        company12.Name='company2';
        company12.PMP_IPA_Badge_Tier_Txt__c='Gold';
        company12.PMP_Partner_Country_Txt__c = 'IND';
        company12.PMP_Account_Id__c=newAccount.Id;
        compList.add(company12);

        //Map<id,PMP_Company__c> oldMap = new Map<id,PMP_Company__c>();
        Test.startTest();
        insert compList;
        Map<id,PMP_Company__c> oldMap = new Map<Id,PMP_Company__c>([select id, PMP_Marketing_Profile_Id__c,PMP_Account_Specialty__c, PMP_Partner_Segment_Nm__c,PMP_Partner_Program_nm__c,PMP_IPA_Badge_Tier_Txt__c from pmp_company__c]);
        system.assertEquals(2, compList.size(),'Company size');
        company.PMP_Partner_Segment_Nm__c ='Data Center';
        update company;

        compIds.add(company.id);
        PMP_Company_Info_TriggerHelper.updatecompanyAttributeMappingRecords(compList, oldMap);
        //PMP_Company_Info_TriggerHelper.updateCompanyAttributeMappingRecordsAsynchronously(compIds);
        system.assertEquals('IND', company.PMP_Partner_Country_Txt__c,'Company Name is matched');
        system.assertEquals('Data Center', company.PMP_Partner_Segment_Nm__c,'Company segment is matched');
        Test.stopTest();

        
    }
    
    
}