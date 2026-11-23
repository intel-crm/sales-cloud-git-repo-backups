@isTest
public class Tooling_CustomLabelCntrl_Test {
    @isTest
    public static void testGetApexBody() {
        Test.startTest();
        List<Tooling_CustomLabelWrapper> apexBodies = Tooling_CustomLabelCntrl.getApexBody();
        Test.stopTest();
        System.assertEquals(true, apexBodies.size()>0);
    }
    
    @isTest
    public static void getApexTriggerBody() {
        Test.startTest();
        List<Tooling_CustomLabelWrapper> apexBodies = Tooling_CustomLabelCntrl.getApexTriggerBody();
        Test.stopTest();
        System.assertEquals(true, apexBodies.size()>0);
    }
    
    @isTest
    public static void getApexPageBody() {
        Test.startTest();
        List<Tooling_CustomLabelWrapper> apexBodies = Tooling_CustomLabelCntrl.getApexPageBody();
        Test.stopTest();
        System.assertEquals(true, apexBodies.size()>0);
    }
    
    @isTest
    public static void getAuraCmpBody() {
        Test.startTest();
        List<Tooling_CustomLabelWrapper> apexBodies = Tooling_CustomLabelCntrl.getAuraCmpBody();
        Test.stopTest();
        System.assertEquals(true, apexBodies.size()>0);
    }
    
    @isTest(seealldata = true)
    public static void testGetLWCResource() {
        
        Test.setMock(HttpCalloutMock.class, new Tooling_LWCMockClass());
        
        Test.startTest();
        List<Tooling_CustomLabelWrapper> lwcBodies = Tooling_CustomLabelCntrl.getLWCResource();
        Test.stopTest();
        
        // Add your assertions here to check if the lwcBodies list contains the expected data.
        // For example, you can check if certain expected LWC resource source is present in the list.
        System.assertEquals(true, lwcBodies.size()>0);
    }
    
    @isTest(seealldata = true)
    public static void testGetCustomLabels() {
        
        Test.setMock(HttpCalloutMock.class, new Tooling_CustomLabelMockClass());
        
        Test.startTest();
        List<Tooling_FieldwrapperClass> customLabels = Tooling_CustomLabelCntrl.getCustomLabels();
        Test.stopTest();
        System.assertEquals(true, customLabels.size()>0);
    }
    
    @IsTest
    static void testFindUnusedCustomLabelsCallout() {
        
        Test.setMock(HttpCalloutMock.class, new Tooling_FindUnsedCustomLabelMock());
        
        Test.startTest();
        List<Tooling_FieldwrapperClass> customLabels = Tooling_CustomLabelCntrl.getCustomLabels();
        Test.stopTest();
        System.assertEquals(true, customLabels.size()>0);
    }
    
}