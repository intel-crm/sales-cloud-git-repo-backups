@isTest 
public class Core_IPS_AddDependentAnswersLEX_Test {
 
    public static User userRecord;
    public static Group QueueRecord;
    public static Core_IPS_Question__c EnvironmentalDetailMaster1;
    public static Core_IPS_Question__c EnvironmentalDetailMaster2;
    public static Core_IPS_Supported_Product__c supportedProductRecord;

    static void getRecords(){
        
    // Query Admin Profile
    Profile ProfileRec = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
    // Create User
    userRecord = TestUtilities.getUser();
    userRecord.username = 'TestUserTest@intel.com';
    userRecord.ProfileID = ProfileRec.Id;
    insert userRecord;
        
    // Creating Queue
    QueueRecord = new Group(Name='SupportOrgQueue', 
                            Type='Queue'
                           );
    insert QueueRecord;
        
    // Creating Public Group
    Group PublicGroupRecord = new Group(Name = 'SupportOrgPublicGroup');
    insert PublicGroupRecord;
        
    System.runAs(userRecord){
        
        // Mapping the Queue to the Core_IPS_Product_Organization__c object
        QueuesObject MappingQueueRecord = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_Product_Organization__c');
        insert MappingQueueRecord;
        
        QueuesObject MappingQueueRecord2 = new QueueSObject(QueueID = QueueRecord.Id, SobjectType = 'Core_IPS_MAP_PAR__c');
        insert MappingQueueRecord2;
        
        // Adding Public Group to the Queue
        GroupMember groupMemberObject_Group = new GroupMember(GroupId = QueueRecord.Id,
                                                               UserOrGroupId = PublicGroupRecord.Id  
                                                              );           
        insert groupMemberObject_Group;
        
        // Adding Member to the Public Group
        GroupMember groupMemberObject_User = new GroupMember(GroupId = PublicGroupRecord.Id,
                                                             UserOrGroupId = userRecord.Id
                                                             );
        insert groupMemberObject_User;
        
        // Creating Product Record
        Product2 createProductRecord = TestUtilities.getProduct();
        insert createProductRecord;
        System.Assert(createProductRecord.Id != null, 'Record not created');
        
        // Creating Support Org (Core_IPS_Product_Organization__c) Record
        Core_IPS_Product_Organization__c SupportOrgRecord = TestUtilities.getSupportOrg();
        SupportOrgRecord.OwnerId = QueueRecord.Id;
        insert SupportOrgRecord;
        System.Assert(SupportOrgRecord.Id != null, 'Record not created');
        
        // Creating Core Supported Product
        supportedProductRecord = TestUtilities.getSupportedProduct();
        supportedProductRecord.Core_Product__c = createProductRecord.id;
        supportedProductRecord.Core_Product_Organization__c = SupportOrgRecord.id;
        insert supportedProductRecord;
        System.Assert(supportedProductRecord.Id != null, 'Record not created');
        
        EnvironmentalDetailMaster1 = TestUtilities.getCoreQuestion();
        EnvironmentalDetailMaster1.Core_IPS_Product_Organization__c = SupportOrgRecord.id;
        insert EnvironmentalDetailMaster1;
      }
    } 
    
    @isTest
    public static void getParentAnswersTest(){
        getRecords();
        Test.startTest();
        
          Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        Core_IPS_AddDependentAnswersLEX.getParentAnswers(parQues.Id);
       Test.stopTest();
    }
    
    @isTest
    public static void getChildQuestionsTest(){
        getRecords();
        Test.startTest();
          Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
          Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();

         //Parent Question Record
         Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
         parQues.recordTypeId = edqRecordTypeId;
         parQues.Core_IPS_Question__c = 'Test Parent Question';
         parQues.Core_IPS_Datatype__c = 'Picklist';
         parQues.Core_IPS_Status__c = 'Active';
         parQues.Core_IPS_Product_Organization__c = supportOrg.id; 
         insert parQues;
        
         //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        Core_IPS_Question__c css = [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Core_IPS_Parent_Question__c =: parQues.Id ];
        Core_IPS_AddDependentAnswersLEX.getChildQuestions(parQues.Id);
       Test.stopTest();
    }
    
    @isTest
    public static void getChildQuestionIdTest(){
        getRecords();
        Test.startTest();
          Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
          Id edqRecordTypeId = Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();

         //Parent Question Record
         Core_IPS_Question__c parQues = new Core_IPS_Question__c();       
         parQues.recordTypeId = edqRecordTypeId;
         parQues.Core_IPS_Question__c = 'Test Parent Question';
         parQues.Core_IPS_Datatype__c = 'Picklist';
         parQues.Core_IPS_Status__c = 'Active';
         parQues.Core_IPS_Product_Organization__c = supportOrg.id; 
         insert parQues;
        
         //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        Core_IPS_Question__c css = [SELECT Id, Name, Core_IPS_Question__c FROM Core_IPS_Question__c WHERE Core_IPS_Parent_Question__c =: parQues.Id ];
        Core_IPS_AddDependentAnswersLEX.getChildQuestions(parQues.Id);
       Test.stopTest();
    }
    
    @isTest
    public static void getChildAnswersTest(){
        getRecords();
        Test.startTest();
          Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Child Quesion record.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.Id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.Id;
        insert childQuestion;
        
        //Child Answer record.   
         Core_IPS_Answer__c ans =  new Core_IPS_Answer__c();
         ans.Core_IPS_Answer__c = 'Test Answer';
         ans.Core_IPS_Status__c = 'Active';
         ans.Core_IPS_Question__c = childQuestion.Id;
         insert ans;
        
        Core_IPS_AddDependentAnswersLEX.getChildAnswers(parQues.Id,new List<String>{childQuestion.Id});
       Test.stopTest();
    }
    
    @isTest
    public static void updateParentAnswerOnChildAnswerTest(){
        getRecords();
        Test.startTest();
          Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        //List of answer records for child question
        List<Core_IPS_Answer__c> childAnsList = new List<Core_IPS_Answer__c>();
        for(Integer i=0;i<5;i++){
            Core_IPS_Answer__c ans =  new Core_IPS_Answer__c();
            ans.Core_IPS_Answer__c = 'Test Answer'+i;
            ans.Core_IPS_Status__c = 'Active';
            
            if(i == 2) 
              ans.Core_IPS_Parent_Answer__c = parentAns2.id;
              ans.Core_IPS_Question__c = childQuestion.id;
            
            childAnsList.add(ans);
        }
        insert childAnsList;
        
        List<Core_IPS_AddDependentAnswersLEX.selectDependentAnswer> selectedAnswer = Core_IPS_AddDependentAnswersLEX.getChildAnswers(parQues.Id, new List<String>{childQuestion.Id});
        Core_IPS_AddDependentAnswersLEX.updateParentAnswerOnChildAnswer(parQues.Id, parentAns.Id,selectedAnswer);
        
        Test.stopTest();
    }
    
     @isTest
    public static void updateParentAnswerOnChildAnswersNull(){
        getRecords();
        try{
          Core_IPS_AddDependentAnswersLEX.updateParentAnswerOnChildAnswer(null, null, null);
        }   
        catch(Exception e){
	     }
    }
    
    @isTest
    public static void validateChildAnswersTest(){
        getRecords();
        Test.startTest();
        Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        //List of answer records for child question
        List<Core_IPS_Answer__c> childAnsList = new List<Core_IPS_Answer__c>();
        for(Integer i=0;i<5;i++){
            Core_IPS_Answer__c ans =  new Core_IPS_Answer__c();
            ans.Core_IPS_Answer__c = 'Test Answer'+i;
            ans.Core_IPS_Status__c = 'Active';
            
            if(i == 2) 
              ans.Core_IPS_Parent_Answer__c = parentAns2.id;
              ans.Core_IPS_Question__c = childQuestion.id;
            
            childAnsList.add(ans);
        }
        insert childAnsList;
        List<Core_IPS_AddDependentAnswersLEX.SelectedAnswerWrapper> answerWrapperList = new List<Core_IPS_AddDependentAnswersLEX.SelectedAnswerWrapper>();
        Core_IPS_AddDependentAnswersLEX.SelectedAnswerWrapper answerWrapper = new Core_IPS_AddDependentAnswersLEX.SelectedAnswerWrapper();
        answerWrapper.Id = childAnsList[0].Id;
        answerWrapper.isChecked = true;
        answerWrapperList.add(answerWrapper);
        
        Core_IPS_AddDependentAnswersLEX.validateChildAnswers(parQues.Id);
        Core_IPS_AddDependentAnswersLEX.saveDependentAnswers(parQues.Id, JSON.serialize(childAnsList));
        Test.stopTest();
    }
    
    @isTest
    public static void validateChildQuestionsTest(){
        getRecords();
        Test.startTest();
        Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        Core_IPS_AddDependentAnswersLEX.validateChildQuestions(parQues.Id);
        Test.stopTest();
    }
    
      @isTest
    public static void validateParentAnswersTest(){
        getRecords();
        Test.startTest();
        Core_IPS_Product_Organization__c  supportOrg = TestUtilities.getSupportOrg();
          insert supportOrg;
        
          //EDQ record type
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
        
        //Parnet Question- Answer Record       
        Core_IPS_Answer__c parentAns2 =  new Core_IPS_Answer__c();
        parentAns2.Core_IPS_Answer__c = 'Test Answer 2';
        parentAns2.Core_IPS_Status__c = 'Active';
        parentAns2.Core_IPS_Question__c = parQues.id;
        insert parentAns2;
        
        //List of child quesion records.
        Core_IPS_Question__c childQuestion = new Core_IPS_Question__c();
        childQuestion.recordTypeId = edqRecordTypeId;
        childQuestion.Core_IPS_Question__c = 'Test Child Question';
        childQuestion.Core_IPS_Datatype__c = 'Picklist';
        childQuestion.Core_IPS_Status__c = 'Active';
        childQuestion.Core_IPS_Product_Organization__c = supportOrg.id;
        childQuestion.Core_IPS_Parent_Question__c = parQues.id;
        
        insert childQuestion;
        
        Core_IPS_AddDependentAnswersLEX.validateParentAnswers(parQues.Id);
        Test.stopTest();

    }
}