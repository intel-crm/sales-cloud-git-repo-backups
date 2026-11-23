@isTest
public class PMP_SearchOfferingImageUtility_Test {

    @testSetup static void setupdata(){
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentAsset ca = new ContentAsset();
        ca.DeveloperName = 'caDev';
        ca.MasterLabel = 'caTest';
        ca.isVisibleByExternalUsers = TRUE;
        insert ca;
        
        contentDocument cd = new contentDocument();
        cd.Id = contentVersion_2.ContentDocumentId;
        cd.ContentAssetId = ca.Id;
        update cd;
        
    }
	
    @isTest static void testGetContentAssetUrlMap(){
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        
        List<String> conDocIds = new List<String>();
        conDocIds.add(contentVersion_2.ContentDocumentId);
        
        Test.startTest();
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds));
        Test.stopTest();
    }
    
    @isTest static void testGetContentAssetUrlMapException(){
        Test.startTest();
        
        
        List<String> conDocIds = new List<String>();
        conDocIds.add('121313');
        
        
        system.assertNotEquals(null, PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocIds));
        Test.stopTest();
    }
    
  /*  @isTest static void getContentVerId_Test(){
        List<String> contIdlst = new List<String>();
        for(ContentDocument cd : [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 5]){
            contIdlst.add(cd.Id);
        }
        Test.startTest();
        system.assertEquals(contIdlst.isEmpty(), false);
        
        PMP_SearchOfferingImageUtility.getContentVerId(contIdlst);
        PMP_SearchOfferingImageUtility.getContentVerId(null);
        Test.stopTest();
    }*/
    @isTest static void getContentDistList_Test(){
        
        List<String> contIdlst = new List<String>();
        for(ContentDocument cd : [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 5]){
            contIdlst.add(cd.Id);
        }
        Test.startTest();
        system.assertEquals(contIdlst.isEmpty(), false);
        
        PMP_SearchOfferingImageUtility.getContentDistList(contIdlst);
        PMP_SearchOfferingImageUtility.getContentDistList(null);
        Test.stopTest();
    }   
    
    
}