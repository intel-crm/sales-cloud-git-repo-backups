@isTest(SeeAllData=false)
public class Core_MDF_FlowInputWrapper_Test {
 @TestSetUp
    static void createTestData(){
        Core_MDF_FlowInputWrapper flowWrap = new Core_MDF_FlowInputWrapper(null, null,null,null,null,null,null);
    }
    
    @isTest
    static void Test2(){
        Core_MDF_FlowInputWrapper flowWrap = new Core_MDF_FlowInputWrapper(null, null,null,null,null,null,null);
    // US - TWC702-14285: Unit Test Method should include System.Assert    
    System.assertEquals(null, flowWrap.createdByExternal);
    System.assertEquals(null, flowWrap.createdById);
    System.assertEquals(null, flowWrap.memberOfActivity);
    System.assertEquals(null, flowWrap.recordId);
    System.assertEquals(null, flowWrap.status);
    System.assertEquals(null, flowWrap.program);
    System.assertEquals(null, flowWrap.proposalBasedIndicator);
    }
}