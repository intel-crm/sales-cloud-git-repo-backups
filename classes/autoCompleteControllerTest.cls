@isTest
public class autoCompleteControllerTest{
    static testMethod void autoCompleteControllerTest1() 
    {
       User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
       Asset asst = TestUtilities.getAsset();
       asst.AccountId =  [select accountid from  user where ID=:CommunityUser.id].accountid ;
       insert Asst;
        // creating Customer community  user
       System.runAs(CommunityUser){
            Test.startTest();
            autoCompleteController auto =  new autoCompleteController();
            List<Sobject> lstAsset = autoCompleteController.findSObjects('Asset',Asst.Name,'Core_IPS_Global_Search_Field_Result','');
            Test.stopTest();
       }       
    }
    static testMethod void autoCompleteControllerTest2() 
    {
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        Asset asst = TestUtilities.getAsset();
        asst.AccountId =  [select accountid from  user where ID=:CommunityUser.id].accountid ;
        insert Asst;
        // creating Customer community  user
        System.runAs(CommunityUser){             
            Test.startTest();
            autoCompleteController auto =  new autoCompleteController();
            auto.fieldSetName = 'Core_IPS_Global_Search_Field_Result';
            auto.objectname = 'Asset';
            string  strColoumns = auto.getColumnsName();
            Test.stopTest();
        }       
    }
    //Test Method Added By Prem Change Project Bug
    static testMethod void autoCompleteControllerProjectChange(){
       User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
       Asset asst = TestUtilities.getAsset();
       asst.AccountId =  [select accountid from  user where ID=:CommunityUser.id].accountid ;
       insert Asst;
        // creating Customer community  user
       System.runAs(CommunityUser){
            Test.startTest();
            autoCompleteController auto =  new autoCompleteController();
            auto.getAutocomplete_fieldset_feilds();
            system.assertEquals(auto.hiddenProdIdField,null);
            system.assertEquals(auto.prodName,null);
            system.assertEquals(auto.relatedId,null);
            Core_IPS_Project__c cipspro=new Core_IPS_Project__c();
            insert cipspro;
            List<Sobject> lstAsset = autoCompleteController.findSObjects('Asset',Asst.Name,'Core_IPS_Global_Search_Field_Result',cipspro.id);
            Test.stopTest();
       } 
    } 
}