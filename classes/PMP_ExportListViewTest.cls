@isTest
public class PMP_ExportListViewTest {
    private static final String LIST_SIZE_MSG = 'No list views returned';
    private static final String ALIAS_NAME = 'testUser';
    private static final string sobjectName = 'PMP_Partner_Offering__c'; 
    private static final PMP_ExportListView.SingleColumn tes = new PMP_ExportListView.SingleColumn();
    private static final string asce = tes.ascendingLabel;
    private static final string des = tes.descendingLabel;
    private static final string sor = tes.sortDirection;
    private static final string type = tes.type;
    private static final integer sorIn = tes.sortIndex;
    private static final boolean sortable = tes.sortable;
    private static final boolean isDateType = tes.isDateType;
    
    @testsetup
    static void setup(){
        
        User testUser;
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];       
        
        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        System.runAs(itAdminUser) {
            testUser = new User();
            testUser = PMP_TestDataUtility.createUser(true);
            testUser.Alias = ALIAS_NAME;
            
            update testUser;
            
        }
        
        
    }
    
    
    public static List<ListView> getListViews(string sobjectName){        
        return [SELECT id, Name FROM ListView WHERE SobjectType = :sobjectName Limit 1];
    }
    
    
    private static user getUser(String alias) {
        User newUser = [SELECT id, name, CreatedbyId FROM User WHERE Alias = :alias LIMIT 1];
        return newUser;
    }
    
    
    @isTest
    static void exportTest1() {   
        
        List<ListView> listview = PMP_ExportListViewTest.getListViews(sobjectName);
        
        User newUser = getUser(ALIAS_NAME);
        
        List<Core_CustomMetadata_Object__c> cms = new List<Core_CustomMetadata_Object__c>();
        
        Core_CustomMetadata_Object__c cm1 = new Core_CustomMetadata_Object__c();
        cm1.DeveloperName__c = 'DeveloperName';
        cm1.MasterLabel__c = 'MasterLabel';
        cm1.Metadata_Name__c = 'PMP_ListViewMapping__mdt';
        cm1.Field_1__c = 'PMP_Is_Active__c';
        cm1.Field_2__c='PMP_List_View_Name__c';
        cm1.Field_3__c='PMP_sObjectName__c'; 
        cm1.Field_1_Text_Area_Long__c = 'Hyperlink_Field_Names__c';
        insert cm1;
        
        Core_CustomMetadata_Object__c cm2 = new Core_CustomMetadata_Object__c();
        cm2.Header_row__c = cm1.Id;
        cm2.DeveloperName__c = 'All Offerings';
        cm2.MasterLabel__c = 'All Offerings';
        cm2.Metadata_Name__c = 'PMP_ListViewMapping__mdt';
        cm2.Field_1__c = 'TRUE';
        cm2.Field_2__c='All_Offerings';
        cm2.Field_3__c='PMP_Partner_Offering__c'; 
        cm2.Field_1_Text_Area_Long__c = 'PMP_Offering_Nm_Hyperlink__c';
        cms.add(cm2);
        
        Core_CustomMetadata_Object__c cm3 = new Core_CustomMetadata_Object__c();
        cm3.Header_row__c = cm1.Id;
        cm3.DeveloperName__c = 'Admin_Review_Queue';
        cm3.MasterLabel__c = 'Admin Review Queue';
        cm3.Metadata_Name__c = 'PMP_ListViewMapping__mdt';
        cm3.Field_1__c = 'TRUE';
        cm3.Field_2__c='Admin_Review_Queue';
        cm3.Field_3__c='PMP_Partner_Offering__c'; 
        
        cms.add(cm3);
        
        insert cms;
        
        system.runAs(newUser){
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PMP_ExportListViewMock());
            PMP_ExportListView.sObjectNames();
            PMP_ExportListView.listValues(sobjectName);
            PMP_ExportListView.fetchRecords(listview[0].id, sobjectName);
            PMP_ExportListView.fetchKeys(listview[0].id, sobjectName);
            system.debug('object and size>>'+sobjectName+''+PMP_ExportListView.listValues(sobjectName).size());
            System.assertEquals(true, (PMP_ExportListView.listValues(sobjectName).size() > 0), LIST_SIZE_MSG); 
            Test.stopTest();
            
        }
        
    }
}