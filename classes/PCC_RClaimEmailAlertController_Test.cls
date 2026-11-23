@isTest
public class PCC_RClaimEmailAlertController_Test {
    
    @isTest
    public static void testRCEmailAlert(){
        
        Test.StartTest();
        List<PCC_Rebate_Claim__c> lstPCC_Rebate_Claim = [SELECT Id FROM PCC_Rebate_Claim__c  LIMIT 1]; 
        
     
        PCC_RebateClaimEmailAlertController p1 = new PCC_RebateClaimEmailAlertController();
    
        if (lstPCC_Rebate_Claim.size()>0)
        {
            p1.rebateClaimId = lstPCC_Rebate_Claim[0].Id;
        }
     
        Test.StopTest();
    }
    /*
    @isTest
    public static void getHeaderURL(){
        Test.StartTest();
        
        String domainName;
        String orgId;
        String URL;
        Document document;            
        document = [select Id from Document where Name=:Label.Pricing_IQR_Intel_Logo LIMIT 1];
        domainName = String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        orgId = UserInfo.getOrganizationId();
        URL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
        Core_PCCRebateClaimEmailAlertController p1 = new Core_PCCRebateClaimEmailAlertController();
        p1.headerURL =  URL;
        
        Test.StopTest();
    }
    */

}