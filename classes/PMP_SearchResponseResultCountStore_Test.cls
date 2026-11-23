@isTest
private class PMP_SearchResponseResultCountStore_Test {
    /*@testSetup static void testDataFactory(){
        /*SELECT COUNT(PMP_Offering_Id__c)cnt,PMP_Event_Id__c
from PMP_Marketplace_Event_Offering__c
WHERE  PMP_Offering_Id__c in: ids AND
(PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
GROUP BY PMP_Event_Id__c//
        /* Select COUNT(PMP_Company_Id__c)cnt,PMP_Event_Id__c
from PMP_Marketplace_Event_Partner__c 
where PMP_Company_Id__c in: ids AND
(PMP_Event_Id__r.PMP_Marketplace_Event_Start_Dt__c <= :SYSTEM.NOW() AND PMP_Event_Id__r.PMP_Marketplace_Event_End_Dt__c >= :SYSTEM.NOW())
GROUP BY PMP_Event_Id__c
//
        //PMP_Category__c WHERE PMP_Partner_Product_Category_Cd__c  =:pimId AND PMP_Active_Ind__c = true
    //PMP_Partner_Offering_Category__c WHERE PMP_Offering_Id__c in:ids AND PMP_Category_Id__r.PMP_Active_Ind__c = true AND (';
    
        PMP_Partner_Program__c partnerProgramParent = new PMP_Partner_Program__c();
        partnerProgramParent.PMP_Is_Active_Ind__c=true;
        partnerProgramParent.PMP_Partner_Program_Value_Txt__c='Solution, Software, and Service Providers';
        partnerProgramParent.name='Solution, Software, and Service Providers';
        insert partnerProgramParent;
        

        PMP_Partner_Program__c partnerProgram = new PMP_Partner_Program__c();
        partnerProgram.PMP_Is_Active_Ind__c=true;
        partnerProgram.PMP_Partner_Program_Value_Txt__c='Service Provider';
        partnerProgram.name='Service Provider';
        partnerProgram.PMP_Partner_Role_Parent_Id__c=partnerProgramParent.Id;
        insert partnerProgram;
        
        PMP_Partner_Program__c partnerProgramwithoutParentRole = new PMP_Partner_Program__c();
        partnerProgramwithoutParentRole.PMP_Is_Active_Ind__c=true;
        partnerProgramwithoutParentRole.PMP_Partner_Program_Value_Txt__c='Manufacturer';
        partnerProgramwithoutParentRole.name='Manufacturer';
        insert partnerProgramwithoutParentRole;
        
        
        PMP_Partner_Specialty__c partnerSpecialty= new PMP_Partner_Specialty__c();
        partnerSpecialty.PMP_Is_Active_Ind__c=true;
        partnerSpecialty.Name='Device as a Service Specialist';
        insert partnerSpecialty;
        
        Account acc= new Account();
        acc.Name='Test Acc';
        acc.Core_Account_Type__c='Intel Approved Component Supplier (IACS)';
        acc.BillingCity='Bangalore';
        acc.BillingCountry='India';
        acc.BillingCity='Bangalore';
        acc.BillingPostalCode='107609';
        acc.BillingStreet='street1';
        insert acc;
        //Create MP Event
        PMP_Marketplace_Event__c mpEvent= new PMP_Marketplace_Event__c();
        mpEvent.Name='Intel MP Event';
        mpEvent.PMP_Marketplace_Event_Start_Dt__c=System.now();
        mpEvent.PMP_Marketplace_Event_End_Dt__c=System.now()+1;
        insert mpEvent;
        
        //create partner
        PMP_Company__c partner= new  PMP_Company__c();
        partner.name= 'Partner Inc';
        partner.PMP_Account_Id__c=acc.Id;
        partner.PMP_Disti_Sys_Solutions_Nm__c='Data Center';   
        partner.PMP_Is_Published_Ind__c=true;
        partner.PMP_Partner_Program_nm__c='Service Provider;Manufacturer';
        //partner.PMP_Disti_Components_Nm__c='Client CPUs and NUC;Field Programmable Gate Array';
        partner.PMP_Disti_Country_Coverage_Txt__c ='India'; /*Commented as part of datatype change//
        partner.PMP_Account_Program_Membership__c ='Manufacturer - Titanium|Solution Integrator - Gold|Seller - Member|Service Provider - Titanium';
        //partner.PMP_IPA_Badge_Tier_Txt__c='Titanium';
        //partner.PMP_Account_Specialty__c='Device as a Service Specialist';
        partner.PMP_Partner_Segment_Nm__c='Internet of Things and Embedded';
        insert partner;
        //SELECT Id, Name, PMP_Admin_Name__c, PMP_Company_Id__c FROM PMP_Partner_Offering__c
        
        //create offering
        PMP_Partner_Offering__c offering= new PMP_Partner_Offering__c();
        offering.Name='test publish';
        offering.PMP_Company_Id__c=partner.Id;
        offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        offering.PMP_Business_Segment_Nm__c='IoT;Server;Personal Computers';
        insert offering;
        
        
        
        PMP_Marketplace_Event_Partner__c mp= new PMP_Marketplace_Event_Partner__c();
        mp.PMP_Company_Id__c=partner.Id;
        mp.PMP_Event_Id__c=mpEvent.Id;
        insert mp;
        
        PMP_Marketplace_Event_Offering__c mpEventWithOffering= new PMP_Marketplace_Event_Offering__c();
        mpEventWithOffering.PMP_Offering_Id__c=offering.Id;
        mpEventWithOffering.PMP_Event_Id__c=mpEvent.Id;
        insert mpEventWithOffering;
        
          PMP_Category__c category= new PMP_Category__c();
        category.PMP_Active_Ind__c=true;
        category.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
        category.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_APP';
        //category.PMP_Ancestor_Category_Cd__c='NPP_01_APP';
        category.Name='Robotic Process Automation';
        insert category;
        
        PMP_Partner_Offering_Category__c poc= new PMP_Partner_Offering_Category__c();
        poc.PMP_Ancestor_Category_Cd__c='NPP_01_APP';
        poc.PMP_Offering_Id__c=offering.Id;
        insert poc;
        
        PMP_Partner_Category__c partnerCategory= new PMP_Partner_Category__c();
        partnerCategory.PMP_Partner_Id__c=partner.Id;
        partnerCategory.PMP_Category_Id__c=category.Id;
        insert partnerCategory;
        
        PMP_Partner_Segment__c partnerSegment= new PMP_Partner_Segment__c();
        partnerSegment.PMP_Partner_Segment_Value_Txt__c='Internet of Things and Embedded';
        partnerSegment.Name='Internet of Things and Embedded';
        partnerSegment.PMP_Is_Active_Ind__c=true;
        insert partnerSegment;
        
        //SELECT Id, Name, PMP_Ancestor_Specification_Cd__c, PMP_Active_Ind__c FROM PMP_Specification__c
        
        PMP_Specification__c spec= new PMP_Specification__c();
        spec.name='Intel® Celeron® Processor';
        spec.PMP_Active_Ind__c=true;
        insert spec;
        //SELECT Id, PMP_Offering_Id__c, PMP_Specification_Id__c FROM PMP_Partner_Offering_Specification__c
        
        
        PMP_Partner_Offering_Specification__c pos = new PMP_Partner_Offering_Specification__c();
        pos.PMP_Specification_Id__c=spec.Id;
        pos.PMP_Offering_Id__c=offering.Id;
        insert pos;
        
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='2-in-1';
        newPMPOfferingCat.PMP_Offering_Id__c=offering.Id;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
        newPMPOfferingCat.PMP_Category_Id__c = category.Id;
        insert newPMPOfferingCat;
        
        
    }
    /* resultCount = getOfferingCategoryFilters(ids, searchType, 'NPP_01_APP');
resultCount.putAll(getOfferingCategoryFilters(ids, searchType, 'NPP_01_Industry'));
resultCount.putAll(getPartnerSpecialtyCount(ids, searchType));
resultCount.putAll(getOfferingSegmentCount(ids, searchType));
resultCount.putAll(getPartnerRoleCount(ids, searchType));
resultCount.putAll(getPartnerTierCount(ids, searchType));
resultCount.putAll(getMPEventCount(ids, searchType));
resultCount.putAll(getDistiBizOrgTypeCount(ids, searchType));
resultCount.putAll(getDistiSystemSolutionCount(ids, searchType));
resultCount.putAll(getDistiComponentsCount(ids, searchType));
resultCount.putAll(getDistiCountriesCount(ids, searchType));

    
    @isTest
    public static void getMPEventCount_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getMPEventCount(offerings,'pmp-category'), null,'Failed');
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getMPEventCount(partners,''), null,'Failed');
        PMP_SearchResponseResultCountStore result = new PMP_SearchResponseResultCountStore();
        test.stopTest();
    } 
    
    @isTest
    public static void getDistiBizOrgTypeCount_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getDistiBizOrgTypeCount(partners,''),null,'Failed');
        test.stopTest();
        
    } 
    //getDistiSystemSolutionCount
        @isTest
    public static void getDistiSystemSolutionCount_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getDistiSystemSolutionCount(partners,''),null,'Failed');
        test.stopTest();
        
    } 
    //getDistiSystemSolutionCount
    @isTest
    public static void getOfferingSegmentCount_test(){
        test.startTest();
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getOfferingSegmentCount(offerings,'pmp-category'),null,'Failed');
        test.stopTest();
        
    } 
    
    //getOfferingPartnerFilter
        //getDistiSystemSolutionCount
    @isTest
    public static void getOfferingPartnerFilter_test(){
        test.startTest();
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getOfferingPartnerFilter(offerings,'pmp-category'),null,'Failed');
        test.stopTest();
        
    } 
    
       @isTest
    public static void getPartnerRoleCount_test(){
        test.startTest();
        PMP_Company__c partner = [SELECT Id,PMP_Partner_Program_nm__c FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1];
        List<String> partners= new List<String>();
        partners.add(partner.Id);
        //PMP_SearchUtilityNew.allPartners.put(partner.Id, partner);

        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerRoleCount(offerings,'pmp-category'),null,'Failed');
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerRoleCount(partners,''),null,'Failed');
        test.stopTest();
        
    } 
    
    //getPartnerTierCount
   
          @isTest
    public static void getPartnerTierCount_test(){
        test.startTest();
        PMP_Company__c partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1];
        partner.PMP_IPA_Badge_Tier_Txt__c = 'Gold';
        update partner;
        List<String> partners= new List<String>();
        partners.add(partner.Id);
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerTierCount(offerings,'pmp-category'),null,'Failed');
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerTierCount(partners,''),null,'Failed');
        test.stopTest();
        
    } 
    //getDistiComponentsCount
             @isTest
    public static void getDistiComponentsCount_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getDistiComponentsCount(partners,''),null,'Failed');
        test.stopTest();
    }
    
    //getDistiCountriesCount
               @isTest
    public static void getDistiCountriesCount_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getDistiCountriesCount(partners,''),null,'Failed');
        test.stopTest();
    }
    //getPartnerSpecialtyCount
    
        @isTest
    public static void getPartnerSpecialtyCount_test(){
        test.startTest();
        //Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        PMP_Company__c partner = [SELECT Id,PMP_Account_Specialty__c FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1];
        
        List<String> partners= new List<String>();
        partners.add(partner.Id);
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        /*PMP_SearchUtilityNew.allPartners.put(partner.Id, partner);
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerSpecialtyCount(offerings,'pmp-category','en_US'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerSpecialtyCount(partners,'','en_US'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerSpecialtyCount(partners,'','ja'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerSpecialtyCount(partners,'','zh-Hans-CN'),null,'Failed');//
        test.stopTest();
        
    } 
    //NPP_01_APP
     @isTest
    public static void getOfferingCategoryFilters_test(){
        test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getOfferingCategoryFilters(offerings,'pmp-category','NPP_01_APP'),null,'Failed');
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getOfferingCategoryFilters(partners,'','NPP_01_APP'),null,'Failed');
        test.stopTest();
        
    } 
    
    //getPartnerSegmentCount
     @isTest
    public static void getPartnerSegmentCount_test(){
        test.startTest();
        PMP_Company__c partner = [SELECT Id,PMP_Partner_Segment_Nm__c FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1];
        List<String> partners= new List<String>();
        partners.add(partner.Id);
        //PMP_SearchUtilityNew.allPartners.put(partner.Id, partner);

        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getPartnerSegmentCount(partners,''),null,'Failed');
        test.stopTest();
        
    } 
    //getTechSpecCount
    
     @isTest
    public static void getTechSpecCount_test(){
        test.startTest();
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getTechSpecCount(offerings,'pmp-category'),null,'Failed');
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getOfferingCategoryFilters(partners,''),null);
        test.stopTest();
        
    } 
    
     @isTest
    public static void getServiceProviderTypeCount_test(){
       test.startTest();
        Id partner = [SELECT Id FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1].Id;
        List<String> partners= new List<String>();
        partners.add(partner);
        //System.assertNotEquals(PMP_SearchResponseResultCountStore.getServiceProviderTypeCount(partners,'searchtype'),null,'Failed');
        test.stopTest();
    }
    
    //getResultCount
    //    public static Map<String, Integer> getResultCount(String searchType, Map<String , List<String>> selectedFilters, List<String> ids, Boolean isDisti){

     @isTest
    public static void getResultCount_test(){
        test.startTest();
        PMP_Company__c partner = [SELECT Id,PMP_Partner_Segment_Nm__c,PMP_Partner_Program_nm__c, PMP_Account_Specialty__c FROM PMP_Company__c WHERE Name='Partner Inc' LIMIT 1];
        List<String> partners= new List<String>();
        partners.add(partner.Id);
        Id offering = [SELECT Id FROM PMP_Partner_Offering__c WHERE Name='test publish' LIMIT 1].Id;
        List<String> offerings= new List<String>();
        offerings.add(offering);
        /*PMP_SearchUtilityNew.allPartners.put(partner.Id, partner);
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getResultCount('pmp-category',new Map<String, List<String>>(),offerings,false, false,'en_US'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getResultCount('',new Map<String, List<String>>(),partners,false, false,'en_US'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getResultCount('',new Map<String, List<String>>(),partners,true, false,'en_US'),null,'Failed');
        System.assertNotEquals(PMP_SearchResponseResultCountStore.getResultCount('',new Map<String, List<String>>(),partners,false, true,'en_US'),null,'Failed');
        test.stopTest();
        
    }*/
    
    
}