@istest
public class Core_Case_CloseControllerTest
{
   
    static testmethod void  Core_Case_CloseControllerTest1(){
        List<Core_IPS_Error_Code__c> LstErrorCode  = TestUtilities.getListOfIpsErrorCodes();
        insert LstErrorCode;
        
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        // creating Customer community  user
        System.runAs(CommunityUser){             
            Test.startTest();
            Case Ca =  TestUtilities.getCase(); 
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            
            Core_Case_CloseController caseClose = new Core_Case_CloseController(StndContr);
            Pagereference Pg = caseClose.redirect();
            Pg  = caseClose.Back();   
            System.assertEquals('/' + Ca.id + '&nooverride=1',Pg.getUrl());
            Test.stopTest();
        }
    }
    
    static testmethod void  Core_Case_CloseControllerTest2(){      
        List<Core_IPS_Error_Code__c> LstErrorCode  = TestUtilities.getListOfIpsErrorCodes();
        insert LstErrorCode;       
        Test.startTest();
        Case Ca =  TestUtilities.getCase(); 
        insert Ca;
        PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getparameters().put('id',Ca.id);
        
        ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
        
        Core_Case_CloseController caseClose = new Core_Case_CloseController(StndContr);
        Pagereference Pg = caseClose.redirect();
        Pg  = caseClose.Back();
        caseClose.errormessage('G103');
        Test.stopTest();  
    }
    
    static testmethod void  Core_Case_CloseControllerTest3(){
        List<Core_IPS_Error_Code__c> LstErrorCode  = TestUtilities.getListOfIpsErrorCodes();
        insert LstErrorCode;
        
        User CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
        RecordType rcType = [select id,name from RecordType where developerName = 'IPS_GEC_ReadOnly' ];
        // creating Customer community  user
        System.runAs(CommunityUser){             
            Test.startTest();
            Case Ca =  TestUtilities.getCase(); 
            ca.recordtypeid =rcType.id;
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_Case_CloseController caseClose = new Core_Case_CloseController(StndContr);
            caseClose.sCaseActionList = null;
            Pagereference Pg = caseClose.redirect();
            Pg  = caseClose.Back();   
            //System.assertEquals('/' + Ca.id + '&nooverride=1',Pg.getUrl());
            Test.stopTest();
        }
    }
   
     static testmethod void  Core_Case_CloseControllerTest4(){
       List<Core_IPS_Error_Code__c> LstErrorCode  = TestUtilities.getListOfIpsErrorCodes();
       insert LstErrorCode;
       User SystUserRunAs; 
        List<User> userList;
        
        Profile prof = [select id from profile where name = 'IPS Agent' limit 1];
        userList = new List<user>();
        userList = TestUtilities.getListOfUser(3);
        userList[0].profileId=prof.id;
        insert userlist[0];
        
         SystUserRunAs = new User();
        SystUserRunAs = userList[0];  
              
       RecordType rcType = [select id,name from RecordType where developerName  = 'IPS_Case_Create'];
       System.runAs(systUserRunAs){             
            Test.startTest();
            Case Ca =  TestUtilities.getCase(); 
            ca.recordtypeid =rcType.id;
            insert Ca;
            System.assert(Ca.Id != null, 'Case Record not created');
            PageReference pageRef = Page.Core_IPS_Case_closeLandingPage;
            Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id',Ca.id);
            ApexPages.StandardController StndContr = new ApexPages.standardController(Ca);
            Core_Case_CloseController caseClose = new Core_Case_CloseController(StndContr);
            caseClose.sCaseActionList = null;
            Pagereference Pg = caseClose.redirect();
            Pg  = caseClose.Back();   
            //System.assertEquals('/' + Ca.id + '&nooverride=1',Pg.getUrl());
            Test.stopTest();
        }
     } 
    
}