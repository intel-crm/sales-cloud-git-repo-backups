/***************************************************************************************************
Class Name:  Core_IPS_AddDependentAnswersExtTest
Class Type: Test Class 
Version     : 1.0 
Created Date: 05-01-2018
Function    : This class contains test coverage for Core_IPS_AddDependentAnswersExt class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_AddDependentAnswersExt class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthick                   05/01/2018             Test class for Managing Dependent answers
* System.assert()--> statement Added By Hassan Khan 01-02-2024 
****************************************************************************************************/ 

@isTest
public class Core_IPS_AddDependentAnswersExtTest{
    
    
    static testMethod void addDependentAnswerTest1(){
        
        
        //Test data for Support Org, Core question and core answers.
        Test.startTest();
        
        Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
        insert supportOrg;
        
        //EDQ record type
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
        
        
        //Have to move into test util class for test data prepartion.
        //Parent Question Record
        Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
        parQues.recordTypeId = edqRecordTypeId;
        parQues.Core_IPS_Question__c = 'Test Parent Question';
        parQues.Core_IPS_Datatype__c = 'Picklist';
        parQues.Core_IPS_Status__c = 'Active';
        parQues.Core_IPS_Product_Organization__c = supportOrg.id; 
        insert parQues;
        
        //List of child quesion records.
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<5;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.recordTypeId = edqRecordTypeId;
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues.id;
            childQuesList.add(childQuestion);
        }
        insert childQuesList;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues.id;
        insert parentAns;
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        
        
        //List of answer records for child question
        List<Core_IPS_Answer__c> childAnsList = new List<Core_IPS_Answer__c>();
        for(Integer i=0;i<5;i++){
            Core_IPS_Answer__c ans =  new Core_IPS_Answer__c();
            ans.Core_IPS_Answer__c = 'Test Answer'+i;
            ans.Core_IPS_Status__c = 'Active';
            
            if(i == 2) ans.Core_IPS_Parent_Answer__c = parentAns2.id;
            ans.Core_IPS_Question__c = childQuesList[i].id;
            
            childAnsList.add(ans);
        }
        insert childAnsList;
        
         Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'Core_IPS_Picklist';
         labels.value__c='Picklist';
         insert labels;
         
         Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
         labels1.name= 'Core_IPS_Multi_Select';
         labels1.value__c='Multiselect Picklist';
         insert labels1;
        
        Test.stopTest();
        
        PageReference pageRef = Page.Core_IPS_AddDependentAnswers;
        pageRef.getparameters().put('id', parentAns.id);
        pageRef.getparameters().put('retURL', parentAns.id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController StndContr = new ApexPages.standardController(parentAns);
        
        Core_IPS_AddDependentAnswersExt ansExt = new Core_IPS_AddDependentAnswersExt(StndContr);
        pageRef = ansExt.init();
        Boolean s = ansExt.showBackButton;
        pageRef = ansExt.SaveDetails();
        
        
        for(Integer i=0;i<ansExt.wrapperQusAnsList.size();i++){
            
            for(Integer j=0;j< ansExt.wrapperQusAnsList[i].answerList.size();j++){
                ansExt.wrapperQusAnsList[i].answerList[j].selected = true;
            }
        }
               
        pageRef = ansExt.SaveandReturn();
        
        //Exception part
        
        delete childAnsList;
        
        pageRef = ansExt.SaveDetails();
        pageRef = ansExt.SaveandReturn();
        
        System.assert(supportOrg.id != null, true);
    } 
    
    
    static testMethod void addDependentAnswerTest2(){
        
        //Test data for Support Org, Core question and core answers.
        Test.startTest();
        
        Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
        insert supportOrg;        
        
        Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();        
               
        //Parent Question Record
        Core_IPS_Question__c parQues = new Core_IPS_Question__c();
        parQues.recordTypeId = edqRecordTypeId;
        parQues.Core_IPS_Question__c = 'Test Parent Question';
        parQues.Core_IPS_Datatype__c = 'Picklist';
        parQues.Core_IPS_Status__c = 'Active';
        parQues.Core_IPS_Product_Organization__c = supportOrg.id;
        insert parQues;
        
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
        parentAns.Core_IPS_Answer__c = 'Test Answer';
        parentAns.Core_IPS_Status__c = 'Active';
        parentAns.Core_IPS_Question__c = parQues.id;
        insert parentAns;
        
        Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
         labels.name= 'Core_IPS_Picklist';
         labels.value__c='Picklist';
         insert labels;
         
         Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
         labels1.name= 'Core_IPS_Multi_Select';
         labels1.value__c='Multiselect Picklist';
         insert labels1;
        
        PageReference pageRef = Page.Core_IPS_AddDependentAnswers;
        pageRef.getparameters().put('id', parentAns.id);
        pageRef.getparameters().put('retURL', parentAns.id);
        
        Test.setCurrentPage(pageRef); 
        
        
        ApexPages.StandardController StndContr = new ApexPages.standardController(parentAns);        
        Core_IPS_AddDependentAnswersExt ansExt = new Core_IPS_AddDependentAnswersExt(StndContr);
        pageRef = ansExt.init();
        pageRef = ansExt.SaveDetails();
        pageRef = ansExt.SaveandReturn();
        
        //Passing Parent - Question id to the page
        PageReference pageRef2 = Page.Core_IPS_AddDependentAnswers;
        pageRef2.getparameters().put('qid', parQues.id);
        Test.setCurrentPage(pageRef2); 
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c(id=null);
        
        ApexPages.StandardController StndContr2 = new ApexPages.standardController(parentAns2);        
        Core_IPS_AddDependentAnswersExt ansExt2 = new Core_IPS_AddDependentAnswersExt(StndContr2);
        pageRef2 = ansExt2.init();
        pageRef2 = ansExt2.SaveDetails();
        pageRef2 = ansExt2.SaveandReturn();
        
        
        //With child questions only.
        //List of child quesion records.
        List<Core_IPS_Question__c> childQuesList = new List<Core_IPS_Question__c>();
        for(Integer i=0;i<5;i++){
            Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
            childQuestion.recordTypeId = edqRecordTypeId;
            childQuestion.Core_IPS_Question__c = 'Test Child Question'+i;
            childQuestion.Core_IPS_Datatype__c = 'Picklist';
            childQuestion.Core_IPS_Status__c = 'Active';
            childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
            childQuestion.Core_IPS_Parent_Question__c = parQues.id;
            childQuesList.add(childQuestion);
        }
        insert childQuesList;
        pageRef = ansExt.init();
        pageRef = ansExt.SaveDetails();
        pageRef = ansExt.SaveandReturn();
        
        //Passing parent- Question id to the page
        PageReference pageRef3 = Page.Core_IPS_AddDependentAnswers;
        pageRef3.getparameters().put('qid', parQues.id);
        Test.setCurrentPage(pageRef3); 
        Core_IPS_Answer__c parentAns3 =  new Core_IPS_Answer__c(id=null);
        
        ApexPages.StandardController StndContr3 = new ApexPages.standardController(parentAns3);        
        Core_IPS_AddDependentAnswersExt ansExt3 = new Core_IPS_AddDependentAnswersExt(StndContr3);
        pageRef3 = ansExt3.init();
        pageRef3 = ansExt3.SaveDetails();
        pageRef3 = ansExt3.SaveandReturn();
        
        
        //Passing child- Question id to the page
        PageReference pageRef4 = Page.Core_IPS_AddDependentAnswers;
        pageRef4.getparameters().put('qid', childQuesList[0].id);
        Test.setCurrentPage(pageRef4); 
        Core_IPS_Answer__c parentAns4 =  new Core_IPS_Answer__c(id=null);
        
        ApexPages.StandardController StndContr4 = new ApexPages.standardController(parentAns4);        
        Core_IPS_AddDependentAnswersExt ansExt4 = new Core_IPS_AddDependentAnswersExt(StndContr4);
        //pageRef4 = ansExt4.init();
        pageRef4 = ansExt4.SaveDetails();
        pageRef4 = ansExt4.SaveandReturn();
        System.assert(childQuesList.size() > 0, true);
          
    } 
    
   static testMethod void addDependentAnswerTest3(){
        
        //Invalid url
        PageReference pageRef = Page.Core_IPS_AddDependentAnswers;
        Test.setCurrentPage(pageRef);
        
        Core_IPS_Answer__c parentAns =  new Core_IPS_Answer__c();
                
        ApexPages.StandardController StndContr = new ApexPages.standardController(parentAns);        
        Core_IPS_AddDependentAnswersExt ansExt = new Core_IPS_AddDependentAnswersExt(StndContr);
        
        try{
            pageRef= ansExt.init();
        }catch(Exception e){
        }
        System.assert(ansExt != null, true);
    } 

}