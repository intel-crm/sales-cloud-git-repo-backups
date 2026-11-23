/***************************************************************************************************
Class Name:  Core_IPS_CommentScreenController_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 5th Aug 2016
Function    : This class contains test coverage for Core_IPS_CommentScreenController Apex Class.
Used in     : None
Modification Log :
* Developer                   Date                             Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput            05/08/2016(DD/MM/YY)                Created
****************************************************************************************************/   
@isTest
public class Core_IPS_CommentScreenController_Test{
    static List<User> ListOfUser = new List<User>();
    //Creating standard user
    static void createusers(){
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name in ('System Administrator')];
          for(Profile prf : ProfileList){
              profiles.put(prf.name, prf.id);
          }
        ListOfUser = TestUtilities.getListOfUser(1);
        ListOfUser[0].ProfileID =  profiles.get('System Administrator');    
        insert ListOfUser;
    }
/***************************************************************************************************
Method Name:  Core_IPS_CommentScreenController_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 08 Aug 2016
Description:  Testing with Case record for getcaseComments method with standard user
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput           08/08/2016                Created
****************************************************************************************************/
    public static testmethod void Core_IPS_CommentScreenController_Test(){
        createusers();
        
        System.runAs(ListOfUser[0]){
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
         
         Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;
         
            Test.startTest();
               Case CS =  TestUtilities.getCase(); 
               insert CS;
               PageReference pageRef = Page.Core_IPS_CommentScreen;
               Test.setCurrentPage(pageRef);
               ApexPages.CurrentPage().getparameters().put('id',CS.id);
               ApexPages.StandardController StndContr = new ApexPages.standardController(CS);            
               Core_IPS_CommentScreenController CommentScreen = new Core_IPS_CommentScreenController (StndContr);
                //CommentScreen.init();
               //CommentScreen.getdisableprevious();
               //boolean disablep=commentscreen.getdisableprevious();
               //boolean disableN=commentscreen.getdisbaleNext();    
               //integer i= commentscreen.getTotal_size();
               //integer j= commentscreen.getPageNumber();
               //integer k= commentscreen.getTotalPages();
               //k=commentscreen.count;
               //commentscreen.next();
               //commentscreen.previous();
            Test.stopTest();
        }
    }
/***************************************************************************************************
Method Name:  Core_IPS_CommentScreenController_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 08 Aug 2016
Description:  Testing with Case record for getcomments method with IPS External Customer user.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput           08/08/2016                Created
****************************************************************************************************/
    public static testmethod void Core_IPS_CommentScreenController_Test1(){
        user u1 = TestUtilities.getCustomerUser('IPS External Customer');
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
         
         Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;
        system.runAs(u1){
            Test.startTest();
                Case CS =  TestUtilities.getCase(); 
                insert CS;
                PageReference pageRef = Page.Core_IPS_CommentScreen;
                Test.setCurrentPage(pageRef);
                ApexPages.CurrentPage().getparameters().put('id',CS.id);
                ApexPages.StandardController StndContr = new ApexPages.standardController(CS);
                Core_IPS_CommentScreenController CommentScreen = new Core_IPS_CommentScreenController (StndContr);
                //added by sugandha as per Sumukh
                CommentScreen.externalUser = True;
                CommentScreen.contentType = 'test';
                CommentScreen.UserMap = new map<Id,User>();
                CommentScreen.getcaseComments();
                //End here
                //CommentScreen.init();                                
            Test.stopTest();   
           }
    }
/***************************************************************************************************
Method Name:  getStatus_test
Method Type: Test Method
Version     : 1.0 
Created Date: 08 Aug 2016
Description:  Testing with Case comment record for getStatus method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Rajput           08/08/2016                Created
****************************************************************************************************/
    Public Static testmethod void getStatus_test() {
       createusers();
     
      Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
         
         Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;
         
         Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
         label6.name='Partner';
         label6.value__c='Partner';
         insert label6;
         
         Case Cs =  TestUtilities.getCase(); 
        insert Cs;
       
        
        List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            }
        insert lstcsecomment;
        
      
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Cs);
        ApexPages.currentPage().getParameters().put('Id',Cs.id); 
        ApexPages.StandardController StndContr = new ApexPages.standardController(cs);
      Core_IPS_CommentScreenController CommentScreen = new Core_IPS_CommentScreenController(StndContr);
      
        //Commented by Sugandha as per Sumukh
        //CommentScreen.getStatus(lstcsecomment);
    }
    
    public boolean getRenderValue() {
        return true;
    }
    
    
    Public Static testmethod void getStatustest() {
    Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'PUBLIC_TO_CUSTOMERS';
         labels.value__c='Public to Customers';
         insert labels;
         
         Core_IPS_Labels__c label1= new Core_IPS_Labels__c();
         label1.name= 'PRIVATE_TO_AGENTS';
         label1.value__c= 'Private to Agents';
         insert label1;
         
         Core_IPS_Labels__c Label2 = new Core_IPS_Labels__c ();
         Label2.name= 'PRIVATE_TO_INTEL';
         label2.value__c= 'Private to Intel';
         insert label2;
         
         Core_IPS_Labels__c label3= new Core_IPS_Labels__c();
         label3.name='Customer';
         label3.value__c='Customer';
         insert label3;
         
         Core_IPS_Labels__c label4 = new Core_IPS_Labels__c ();
         label4.name='FAE';
         label4.value__c='FAE';
         insert label4;
         
         Core_IPS_Labels__c label5 = new Core_IPS_Labels__c();
         label5.name='Agent';
         label5.value__c='Agent';
         insert label5;

         Core_IPS_Labels__c label6= new Core_IPS_Labels__c();
         label6.name='Partner';
         label6.value__c='Partner';
         insert label6;
         
        Case Cs =  TestUtilities.getCase(); 
        insert Cs;
        List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            }
        insert lstcsecomment;
        ApexPages.StandardController StndContr = new ApexPages.standardController(cs);
        Core_IPS_CaseCommentsController caseComments = new Core_IPS_CaseCommentsController(StndContr);
        //Commented by Sugandha as per Sumukh
        //caseComments.getStatus(lstcsecomment);
}


}