public with sharing class UCD_ReltioAccountHierarchyController {

    @AuraEnabled
    public static ReltioHierarchyModel getReltioHierarchy() {

        //mock data
        UCD_ReltioAccountHierarchyController.ReltioHierarchyModel reltioData3 = new UCD_ReltioAccountHierarchyController.ReltioHierarchyModel();
        reltioData3.accName = 'Lenovo';
        reltioData3.bpId = '1000018339';
        reltioData3.countryName = 'New York';

        UCD_ReltioAccountHierarchyController.ReltioHierarchyModel reltioData2 = new UCD_ReltioAccountHierarchyController.ReltioHierarchyModel();
        reltioData2.accName = 'Lenovo';
        reltioData2.bpId = '1000018339';
        reltioData2.countryName = 'California';

        UCD_ReltioAccountHierarchyController.ReltioHierarchyModel reltioData1 = new UCD_ReltioAccountHierarchyController.ReltioHierarchyModel();
        reltioData1.accName = 'Lenovo';
        reltioData1.bpId = '1000018339';
        reltioData1.countryName = 'United States';
        reltioData1.childAccounts.add(reltioData2);
        reltioData1.childAccounts.add(reltioData2);


        UCD_ReltioAccountHierarchyController.ReltioHierarchyModel reltioData = new UCD_ReltioAccountHierarchyController.ReltioHierarchyModel();
        reltioData.accName = 'Lenovo';
        reltioData.bpId = '1000018334';
        reltioData.countryName = '';
        reltioData.childAccounts.add(reltioData1);

        return reltioData;
    }

    /**********ReltioHierarchyModel****************/
    public class ReltioHierarchyModel {
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String bpId{get;set;}
        @AuraEnabled
        public String countryName{get;set;}
        @AuraEnabled
        public String reltioUrl{get;set;}
        @AuraEnabled
        public List<ReltioHierarchyModel> childAccounts{get;set;}
    }
}