@isTest
public class Core_MDF_dynamicUrlsOnCommunity_Test {
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
                                 
            Core_MDF_Content_Configuration__c conConfig4= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode1',Core_MDF_Sort_Order_nbr__c = 1, 
                                                                                                Core_MDF_Content_Label_txt__c='Test4',Core_MDF_isActive_Ind__c = true,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/', Core_MDF_Category_nm__c= 'Section Header',
                                                                                                Core_MDF_Is_Icon_Required_ind__c= false
                                                                                               );
                                                                                           
             
            Test.startTest();
            contentList.add(conConfig1);
            contentList.add(conConfig2);
            contentList.add(conConfig3);
            contentList.add(conConfig4);
            Database.insert(contentList);
            
            Core_MDF_Content_Configuration__c conConfig5= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode1',Core_MDF_Sort_Order_nbr__c = 1, 
                                                                                                Core_MDF_Content_Label_txt__c='Test4',Core_MDF_isActive_Ind__c = true,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/', Core_MDF_Category_nm__c= 'Section SubHeader',
                                                                                                Core_MDF_Is_Icon_Required_ind__c= false,Core_MDF_Parent_Content_Config_Id__c=conConfig4.Id
             
                                                                                               );
            
            contentList.add(conConfig5);
            Database.insert(conConfig5);
            Core_MDF_Content_Configuration__c conConfig6= new Core_MDF_Content_Configuration__c(Core_MDF_Section_Code_txt__c= 'SectionCode1',Core_MDF_Sort_Order_nbr__c = 1, 
                                                                                                Core_MDF_Content_Label_txt__c='Test4',Core_MDF_isActive_Ind__c = true,
                                                                                                Core_MDF_Content_URL__c = 'https://www.intel.com/', Core_MDF_Category_nm__c= 'Section Line Item',
                                                                                                Core_MDF_Is_Icon_Required_ind__c= false,Core_MDF_Parent_Content_Config_Id__c=conConfig5.Id
             
                                                                                               );
            contentList.add(conConfig6);
            Database.insert(conConfig6);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testgetContent(){
        List<user> userList = [select id from user where LastName='ConfigUser Test'];
        if (userList!=null && !userList.isEmpty()){
            system.runAs(userList[0]){
                List<Core_MDF_dynamicUrlsOnCommunity.ContentWrapperObj> contentlist = Core_MDF_dynamicUrlsOnCommunity.getHomeContent('SectionCode');
                assert.areEqual(contentlist.size() == 2, true);
            }
        }
    }
    
     @isTest
    public static void testgetResourcesContent(){
        List<user> userList = [select id from user where LastName='ConfigUser Test'];
        if (userList!=null && !userList.isEmpty()){
            system.runAs(userList[0]){
                List<Core_MDF_dynamicUrlsOnCommunity.sectionWrapper> contentlist = Core_MDF_dynamicUrlsOnCommunity.getResourceContent('SectionCode1');
               assert.areEqual(contentlist.size() == 1, true);
            }
        }
    }
    
     @isTest
    public static void testgetBrandContent(){
        List<user> userList = [select id from user where LastName='ConfigUser Test'];
        if (userList!=null && !userList.isEmpty()){
            system.runAs(userList[0]){
                List<Core_MDF_dynamicUrlsOnCommunity.tableRowHeaderWrapper> contentlist = Core_MDF_dynamicUrlsOnCommunity.getBrandContent('SectionCode1');
               assert.areEqual(contentlist.size() == 1, true);
            }
        }
    }  
}