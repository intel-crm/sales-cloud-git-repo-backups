@isTest
public class Core_MDF_DynamicContentGenerator_Test {
  @TestSetup
    public static void createData(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'ConfigUser Test';
        Database.insert(usr);
        System.runAs(usr){
            List<Core_MDF_Content_Configuration__c> contentList = new List<Core_MDF_Content_Configuration__c>();
            Core_MDF_Content_Configuration__c conConfig1= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode',Core_MDF_Sort_Order_nbr__c = 1, 
                                                                                                Core_MDF_Content_Label_txt__c='Test1',Core_MDF_isActive_Ind__c = true,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/'
                                                                                               );
            Core_MDF_Content_Configuration__c conConfig2= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode',Core_MDF_Sort_Order_nbr__c = 2, 
                                                                                                Core_MDF_Content_Label_txt__c='Test2',Core_MDF_isActive_Ind__c = true,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/'
                                                                                               );
            Core_MDF_Content_Configuration__c conConfig3= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode',Core_MDF_Sort_Order_nbr__c = 3, 
                                                                                                Core_MDF_Content_Label_txt__c='Test3',Core_MDF_isActive_Ind__c = false,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/'
                                                                                               );
            Test.startTest();
            contentList.add(conConfig1);
            contentList.add(conConfig2);
            contentList.add(conConfig3);
            Database.insert(contentList);
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testHomeContent(){
        List<user> userList = [select id from user where LastName='ConfigUser Test'];
        if (userList!=null && !userList.isEmpty()){
            system.runAs(userList[0]){
                List<Core_MDF_dynamicUrlsOnCommunity.ContentWrapperObj> contentlist = Core_MDF_dynamicUrlsOnCommunity.getHomeContent('SectionCode');
                assert.areEqual(contentlist.size() == 2, true);
            }
        }
    }
    
}