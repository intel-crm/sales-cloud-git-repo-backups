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
    
    @testSetup
    static void setup(){
       
        User testUser;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
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

        system.runAs(newUser){
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PMP_ExportListViewMock());
            PMP_ExportListView.sObjectNames();
            PMP_ExportListView.listValues(sobjectName);
            PMP_ExportListView.fetchRecords(listview[0].id, sobjectName);
            PMP_ExportListView.fetchKeys(listview[0].id, sobjectName);
           	System.assertEquals(true, (PMP_ExportListView.listValues(sobjectName).size() > 0), LIST_SIZE_MSG); 
            Test.stopTest();
          
        }
       
    }
}