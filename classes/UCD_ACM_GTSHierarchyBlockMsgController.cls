public with sharing class UCD_ACM_GTSHierarchyBlockMsgController {

    /*@AuraEnabled
    public static ReltioNameAndECB getAllHeirarchyRecords(Id accountId){
        ReltioNameAndECB ecbWrap = new ReltioNameAndECB();
        ecbWrap.exportCompliance=false;
        try {
            String query = '';
            if(accountId!=null){
                Account acc=[Select Id, Core_Export_Compliance_Block__c From Account Where Id=:accountId];
                ecbWrap.exportCompliance = acc.Core_Export_Compliance_Block__c;
            }
        }catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        System.debug('$$#ecbwrp '+ecbWrap);
        return ecbWrap;
    }

    public class ReltioNameAndECB{
        @AuraEnabled
        public Boolean exportCompliance;
    }*/
}