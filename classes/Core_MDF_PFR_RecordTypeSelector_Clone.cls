@isTest
public class Core_MDF_PFR_RecordTypeSelector_Clone {
@TestSetup static void createTestData(){ 
		Set<String> psNameSet = new Set<String> ();
      Map<string,String>  psNameVsIdMap = new Map<string,String>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false,'CCP - Core Access');
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);        
    	psNameSet.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
    	psNameSet.add('Core_MDF_CCP_Internal_Generic_Access');
   		psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
    	String ccfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
       String genricAccessPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Generic_Access');

    	List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
     	 psAssignList.add(new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId =ccfAcctMgrPsId));   
    	 psAssignList.add(new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId =genricAccessPsId));   
        insert psAssignList;
    }
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
    	return resultMap;
    }
    
    @isTest 
    private static void fetchRecordTypeValuesPosTest(){
        Test.startTest();
        String objectName = 'PartnerFundRequest';
         Map<String, String> returnResMap = new  Map<String, String>();
        User acctManager = [SELECT ID FROM User where Name='User Test'];
        System.runAs(acctManager){
            returnResMap = Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues(objectName);            
        }
        //Expected - Core_MDF_Client_CoMarketing_Fund
        //actual - returnResMap.keySet();
        Assert.areEqual(true,returnResMap.containsKey('Core_MDF_Client_CoMarketing_Fund'));
        Test.stopTest();
        
    }
   @isTest 
    private static void fetchRecordTypeValuesNegTest(){
         Test.startTest();
        String objectName = null;
         Map<String, String> returnResMap = new  Map<String, String>();
        User acctManager = [SELECT ID FROM User WHERE Name='User Test'];
        System.runAs(acctManager){
            returnResMap = Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues(objectName);            
        }
             Assert.areEqual(0, returnResMap.size());
        Test.stopTest();
        
    }
}