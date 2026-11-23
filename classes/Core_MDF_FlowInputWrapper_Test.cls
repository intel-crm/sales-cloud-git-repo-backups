@isTest(SeeAllData=false)
public class Core_MDF_FlowInputWrapper_Test {
 @TestSetUp
    static void createTestData(){
        Core_MDF_FlowInputWrapper flowWrap = new Core_MDF_FlowInputWrapper(null, null,null,null,null,null,null);
    }
    
    @isTest
    static void Test2(){
        Core_MDF_FlowInputWrapper flowWrap = new Core_MDF_FlowInputWrapper(null, null,null,null,null,null,null);
    }
}