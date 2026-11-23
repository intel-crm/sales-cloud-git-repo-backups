public with sharing class UCD_ReltioAccountHierarchyController {

    @AuraEnabled(cacheable=true)
    public static ReltioHierarchyModelWr getReltioHierarchy() {
        
        //mock data
        ReltioHierarchyModel reltioData3 = new ReltioHierarchyModel();
        reltioData3.accName = 'Lenovo';
        reltioData3.bpId = '1000018339';
        reltioData3.countryName = 'New York';
        
        ReltioHierarchyModel reltioData2 = new ReltioHierarchyModel();
        reltioData2.accName = 'Lenovo';
        reltioData2.bpId = '1000018339';
        reltioData2.countryName = 'California';
        
        ReltioHierarchyModel reltioData1 = new ReltioHierarchyModel();
        reltioData1.accName = 'Lenovo';
        reltioData1.bpId = '1000018339';
        reltioData1.countryName = 'United States';
        
        
        ReltioHierarchyModel reltioData = new ReltioHierarchyModel();
        reltioData.accName = 'Lenovo';
        reltioData.bpId = '1000018334';
        reltioData.countryName = 'UK';
        List<ReltioHierarchyModel> listRe = new List<ReltioHierarchyModel>();
        listRe.add(reltioData3);
        listRe.add(reltioData2);
        listRe.add(reltioData1);
        listRe.add(reltioData);
        ReltioHierarchyModelWr wr = new ReltioHierarchyModelWr();
        wr.childAccounts=listRe;
        wr.accountName = '1000018334 | Lenovo ||';
        return wr;
    }
        
    public class ReltioHierarchyModelWr {
        @AuraEnabled
        public String accountName{get;set;}
        @AuraEnabled
        public List<ReltioHierarchyModel> childAccounts{get;set;} 
    }
    
    public class ReltioHierarchyModel {
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String bpId{get;set;}
        @AuraEnabled
        public String countryName{get;set;}
        @AuraEnabled
        public String reltioUrl{get;set;}
        
    }
}