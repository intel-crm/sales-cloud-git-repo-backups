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
        //add by rajeswari for code coverage 20 june 22
         //Custom Setting - Core IPS Labels
        List<Core_IPS_Labels__c> listofIpsLables = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
        Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
        Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
        listofIpsLables.add(ipsLables1);
        listofIpsLables.add(ipsLables2);
        listofIpsLables.add(ipsLables3);  
        List<Core_IPS_Labels__c> ipsLabelsForGlobalAsset = TestUtilities.getIPSLabel();
        for(Core_IPS_Labels__c ipl : ipsLabelsForGlobalAsset){
            if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                ipl.value__c = 'Core_Public_Product';
            }
        }
        listofIpsLables.addAll(ipsLabelsForGlobalAsset);  
        
        insert listofIpsLables;

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
         Core_IPS_Labels__c label6 = new Core_IPS_Labels__c();
        label6.name='Backend Integration';
        label6.value__c='Backend Integration';
        insert label6;
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
        //start added by rajeswari for increasing codecoverage 21 June 22
		  Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.name='Backend Integration';
        label7.value__c='Backend Integration';
        insert label7;    
         Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
        label8.name='Comment Source - Email';
        label8.value__c='Comment Source - Email';
        insert label8;
         Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
        label9.name='Comment Source - Backend System';
        label9.value__c='Comment Source - Backend System';
        insert label9;
          Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
        label10.name='Data Migration';
        label10.value__c='Data Migration';
        insert label10;
         Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Comment Source - Data Migration';
        label11.value__c='Comment Source - Data Migration';
        insert label11;
        
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Comment Source - Internal';
        label12.value__c='Comment Source - Internal';
        insert label12;
          Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Comment Source - Customer';
        label13.value__c='Comment Source - Customer';
        insert label13;
         Core_IPS_Labels__c label14 = new Core_IPS_Labels__c();
        label14.name='Comment Source - N/A';
        label14.value__c='Comment Source - N/A';
        insert label14;
        //Partner - DFAE
         Core_IPS_Labels__c label15 = new Core_IPS_Labels__c();
        label15.name='Partner - DFAE';
        label15.value__c='Partner - DFAE';
        insert label15;
        //end added by rajeswari for increasing codecoverage 21 June 22
        
         Case Cs =  TestUtilities.getCase(); 
        insert Cs;
       
        
        List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
                //add by rajeswari for codecoverage 21 June 22
             casecomments.Core_IPS_Comment_Author_Type__c='Agent';
             casecomments.Core_IPS_Case_Comment_Source__c='Customer Portal';
                //end by rajeswari for codecoverage 21 June 22
            }
        insert lstcsecomment;
        
      
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Cs);
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
        //start samplecustom data added by rajeswari for increasing codecoverage  20 June 22
          Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
        label7.name='Backend Integration';
        label7.value__c='Backend Integration';
        insert label7;
         Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
        label8.name='Comment Source - Email';
        label8.value__c='Comment Source - Email';
        insert label8;
         Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
        label9.name='Comment Source - Backend System';
        label9.value__c='Comment Source - Backend System';
        insert label9;
          Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
        label10.name='Data Migration';
        label10.value__c='Data Migration';
        insert label10;
         Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
        label11.name='Comment Source - Data Migration';
        label11.value__c='Comment Source - Data Migration';
        insert label11;
        Core_IPS_Labels__c label12 = new Core_IPS_Labels__c();
        label12.name='Comment Source - Internal';
        label12.value__c='Comment Source - Internal';
        insert label12;
          Core_IPS_Labels__c label13 = new Core_IPS_Labels__c();
        label13.name='Comment Source - Customer';
        label13.value__c='Comment Source - Customer';
        insert label13;
         Core_IPS_Labels__c label14 = new Core_IPS_Labels__c();
        label14.name='Comment Source - N/A';
        label14.value__c='Comment Source - N/A';
        insert label14;
         Core_IPS_Labels__c label15 = new Core_IPS_Labels__c();
        label15.name='Partner - DFAE';
        label15.value__c='Partner - DFAE';
        insert label15;
        //end  code added by rajeswari for increasing codecoverage 20 June 22
        Case Cs =  TestUtilities.getCase(); 
        insert Cs;
        List<Core_IPS_Case_Comments__c> lstcsecomment = TestUtilities.getCaseComments(2);
            For (Core_IPS_Case_Comments__c casecomments : lstcsecomment){
            casecomments.Core_IPS_Case__c = cs.id;
            casecomments.Core_IPS_Comment_Author_Type__c='Agent'; 
              casecomments.Core_IPS_Case_Comment_Source__c='Customer Portal';
               
                
            }
        insert lstcsecomment;
        ApexPages.StandardController StndContr = new ApexPages.standardController(cs);
        Core_IPS_CaseCommentsController caseComments = new Core_IPS_CaseCommentsController(StndContr);
        //Commented by Sugandha as per Sumukh
        //caseComments.getStatus(lstcsecomment);
}


}