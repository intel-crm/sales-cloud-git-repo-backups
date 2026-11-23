//test class for the class PMP_RefineFilterController
@isTest
public class PMP_RefineFilterController_Test {
 @TestSetup
    static void prepareData(){
        PMP_Specification__c parentSpec = new PMP_Specification__c();
        parentSpec.name= 'Processors';
        parentSpec.PMP_Active_Ind__c=TRUE;
        parentSpec.PMP_Partner_Product_Specification_Id__c = 'NPP_Processors';
        insert parentSpec;
        
        PMP_Specification__c childSpec = new PMP_Specification__c();
        childSpec.name= 'Other Processors';
        childSpec.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors';
        childSpec.PMP_Active_Ind__c=true;
        childSpec.PMP_Partner_Product_Specification_Id__c = '122309';
        childSpec.PMP_Parent_Specification_Id__c=parentSpec.Id;
        insert childSpec;

        PMP_Specification_Value__c specVal= New PMP_Specification_Value__c();
        specVal.Name = 'DDR3';
        specVal.PMP_Specification_Value_Chinese_Cd__c = 'DDR3';
        specVal.PMP_Specification_Value_Japanese_Cd__c = 'DDR3';
        specVal.PMP_Specification_Value_Nm__c = 'DDR3';
        specVal.PMP_Specification_Product_Cd__c= 'NPP_Processors';
        specVal.PMP_Active_Ind__c = true;
        insert specVal;
                
        PMP_Category__c parentCatogory= new PMP_Category__c();
        parentCatogory.PMP_Active_Ind__c=true;
        parentCatogory.PMP_Partner_Product_Category_Cd__c='NPP_01_Industry';
        parentCatogory.PMP_Partner_Product_Category_Key__c = 'npp_01_industry';
        parentCatogory.PMP_Partner_Product_Parent_Category_Cd__c  ='Solution_Marketplace_Hierarchy';
        parentCatogory.Name='Industry';
        insert parentCatogory;
        
        PMP_Category__c childCategory= new PMP_Category__c();
        childCategory.PMP_Active_Ind__c=true;
        childCategory.PMP_Partner_Product_Category_Cd__c='IPA_Ind_HealthCare';
        childCategory.PMP_Partner_Product_Category_Key__c = 'ipa_ind_healthcare';
        childCategory.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_Industry';
        childCategory.PMP_Parent_Category_Id__c = parentCatogory.Id;
        childCategory.Name='Healthcare';
        insert childCategory;        
    }
    
    @isTest
    public static void  getRefineFilterTaxonomiesTest(){
        test.startTest();
        List<String> pimIds= new List<String>();
        List<PMP_Category__c> categories = [SELECT id,PMP_Partner_Product_Category_Cd__c from PMP_Category__c where PMP_Parent_Category_Id__c=null];
        List<PMP_Specification__c> specList = [SELECT id, PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Id__c FROM PMP_Specification__c WHERE PMP_Product_Parent_Specification_Id__c=null];
        for (PMP_Category__c cat:categories){
            pimIds.add(cat.PMP_Partner_Product_Category_Cd__c);
        }
        for (PMP_Specification__c cat:specList){
            pimIds.add(cat.PMP_Partner_Product_Specification_Id__c);
        }
        system.assertNotEquals(NULL,PMP_RefineFilterController.getRefineFilterTaxonomies('en_US',pimIds), 'Test failed');
        test.stopTest();        
    }
   
}