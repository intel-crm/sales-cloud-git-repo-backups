@isTest
public class showMAGquestionaire_Test{
    static testMethod void showMAGquestionaire_PositiveTest(){   
     Test.startTest();
        Document doc = new Document();
        doc.body = blob.valueOF('sdadsad');
        doc.Name='test';
        doc.FolderId=UserInfo.getUserId();
        insert doc;
        // VF Page Testing
       
        PageReference pageRef = Page.showMAGquestionaire;
        Test.setCurrentPage(pageRef);
        showMAGquestionaire showM = new showMAGquestionaire();        
        showM.getHtmlText();
        showM.disclaimerPage();        
        Test.stopTest();
    } 
}