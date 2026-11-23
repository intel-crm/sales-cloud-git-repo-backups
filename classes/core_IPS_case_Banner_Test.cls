@isTest
public class core_IPS_case_Banner_Test {

    static testMethod void myUnitTest() {
        //core_IPS_case_Banner test  = new core_IPS_case_Banner();
        Core_IPS_Banner_CustomSetting__c banner = new Core_IPS_Banner_CustomSetting__c();
        banner.Name = '%CCP%';
        insert banner;
         Case cas1 = new Case();          
        //cas1.Core_IPS_Project_Case__c = pr.id;
        cas1.status = 'open';   
        cas1.Subject ='Testing with testclass';
        insert cas1;
        list<case> caselst = new list<case>{cas1};
         
       
        ApexPages.StandardController stdController = new ApexPages.StandardController(cas1);
       
      core_IPS_case_Banner testBanner = new core_IPS_case_Banner(stdController);
       PageReference pp= page.core_IPS_case_ExternalCustomerBanner;
         pp.getParameters().put('id',String.valueOf(cas1.id));
         System.assert(cas1.Id!=null);
       Test.setCurrentPage(pp);
        
    }
    
    
       
}