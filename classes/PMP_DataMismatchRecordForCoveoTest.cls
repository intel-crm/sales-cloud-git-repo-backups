@isTest
public class PMP_DataMismatchRecordForCoveoTest {
    
      @testSetup static void setup() {
        // Create common test accounts 
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account pagAcc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', pagAcc.Id, true);
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
          cmp1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        update cmp1;
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= pagAcc.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun; 
          
          
          PMP_Partner_Program__c pm=new PMP_Partner_Program__c();
        pm.Name='Distributor';
        pm.PMP_Partner_Program_Value_Txt__c='Distributor';
        pm.PMP_Is_Active_Ind__c = TRUE;
        insert pm;
        
        PMP_Partner_Program__c pm1=new PMP_Partner_Program__c();
        pm1.Name='Cloud & Comms Service Provider';
        pm1.PMP_Partner_Program_Value_Txt__c='Cloud & Comms Service Provider';
        pm1.PMP_Is_Active_Ind__c = TRUE;
        insert pm1;
          
          
          PMP_Partner_Specialty__c ps= new PMP_Partner_Specialty__c();
        ps.name='Cloud Data Center Specialist';
        ps.PMP_Is_Active_Ind__c=true;
        insert ps;
          
          PMP_Partner_Specialty__c ps2= new PMP_Partner_Specialty__c();
        ps2.name='Networking Specialist';
        ps2.PMP_Is_Active_Ind__c=true;
        insert ps2;
        
        PMP_Partner_Segment__c segment= new  PMP_Partner_Segment__c();
        segment.name='Client Computing';
        segment.PMP_Is_Active_Ind__c= true;
        segment.PMP_Partner_Segment_Value_Txt__c='Client Computing';
        insert segment;
          
          PMP_Partner_Segment__c segment2= new  PMP_Partner_Segment__c();
        segment2.name='Data Center';
        segment2.PMP_Is_Active_Ind__c= true;
        segment2.PMP_Partner_Segment_Value_Txt__c='Data Center';
        insert segment2;
          
          
          
          PMP_Partner_Tier__c pt= new PMP_Partner_Tier__c();
        pt.Name= 'Gold';
        insert pt;
        
         /* PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Partner_Tier__c = pt.Id;
        attr.PMP_Marketing_Profile_Id__c = cmp1.Id;
        attr.PMP_Partner_Role__c = pm.Id;
          attr.PMP_Partner_Segment__c=segment.Id;
          attr.PMP_Partner_Specialty__c=ps.Id;
        insert attr;
         */ 
          
     }
    
    @isTest
    public static void fetchCoveoRecords_Partner_Tier(){
        PMP_Company__c cmp1 = [select id, Name from PMP_Company__c];
        cmp1.PMP_IPA_Badge_Tier_Txt__c = 'Member';
        update cmp1;
        
        PMP_Partner_Tier__c pt = [select Id, Name from PMP_Partner_Tier__c];
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr;
        
        Set<Id> rec = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr2 = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr2.PMP_Partner_Tier__c = pt.Id;
        attr2.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr2;
        
        Set<Id> rec2 = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
    }
    
     @isTest
    public static void fetchCoveoRecords_Partner_Role(){
        PMP_Company__c cmp1 = [select id, Name from PMP_Company__c];
        cmp1.PMP_Partner_Program_nm__c = 'Cloud & Comms Service Provider';
        update cmp1;
        
        List<PMP_Partner_Program__c> pp = [select Id, Name from PMP_Partner_Program__c];
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Partner_Role__c = pp[0].Id;
        attr.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr;
        
        Set<Id> rec = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr2 = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr2.PMP_Partner_Role__c = pp[1].Id;
        attr2.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr2;
        
        Set<Id> rec2 = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
    }
    
     @isTest
    public static void fetchCoveoRecords_Partner_Specialty(){
        PMP_Company__c cmp1 = [select id, Name from PMP_Company__c];
        cmp1.PMP_Account_Specialty__c = 'Networking Specialist';
        update cmp1;
        
        List<PMP_Partner_Specialty__c> ps = [select Id, Name from PMP_Partner_Specialty__c];
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Partner_Specialty__c = ps[0].Id;
        attr.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr;
        
        Set<Id> rec = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr2 = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr2.PMP_Partner_Specialty__c = ps[1].Id;
        attr2.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr2;
        
        Set<Id> rec2 = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
    }
    
     @isTest
    public static void fetchCoveoRecords_Partner_Segment(){
        PMP_Company__c cmp1 = [select id, Name from PMP_Company__c];
        cmp1.PMP_Partner_Segment_Nm__c = 'Data Center';
        update cmp1;
        
        List<PMP_Partner_Segment__c> ps = [select Id, Name from PMP_Partner_Segment__c];
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr.PMP_Partner_Segment__c = ps[0].Id;
        attr.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr;
        
        Set<Id> rec = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
        
        PMP_Marketing_Profile_Attributes_Mapping__c attr2 = new PMP_Marketing_Profile_Attributes_Mapping__c();
        attr2.PMP_Partner_Segment__c = ps[1].Id;
        attr2.PMP_Marketing_Profile_Id__c = cmp1.Id;
        insert attr2;
        
        Set<Id> rec2 = PMP_DataMismatchRecordForCoveo.fetchCoveoRecords();
    }

}