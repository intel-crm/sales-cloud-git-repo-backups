@istest()
public class PRM_Specialty_Qualitative_Criteria_Test {
    
    
    static testmethod void testduplicateRecordCheck(){
        test.startTest();
        Map <String,Schema.RecordTypeInfo> recordTypeMap = PRM_Specialty_Criteria__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        
        PRM_Specialty_Criteria__c sc= new PRM_Specialty_Criteria__c();
        sc.name= 'Speciality criteria';
        sc.RecordTypeId=recordTypeMap.get('Qualitative').getRecordTypeId();
        sc.PRM_Start_Date_Dt__c = System.today()+4;
        sc.PRM_Type_Nm__c = 'Qualitative';
        insert sc;
        
        PRM_Specialty_Criteria__c sc1= new PRM_Specialty_Criteria__c();
        sc1.name= 'Speciality criteria1';
        sc1.RecordTypeId=recordTypeMap.get('Qualitative').getRecordTypeId();
        sc1.PRM_Start_Date_Dt__c = System.today()+4;
        sc1.PRM_Type_Nm__c = 'Qualitative';
        insert sc1;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty_Qualitative_Criteria__c sqc = new PRM_Specialty_Qualitative_Criteria__c();
        sqc.PRM_Criteria_Id__c = sc.id;
        sqc.PRM_Specialty_Id__c= spec.id;
        insert sqc;
        
        PRM_Specialty_Qualitative_Criteria__c sqc1 = new PRM_Specialty_Qualitative_Criteria__c();
        sqc1.PRM_Criteria_Id__c = sc.id;
        sqc1.PRM_Specialty_Id__c= spec.id;
        
        try{ 
            insert sqc1;
            System.assert(false);
        }
        catch(exception e){   
            System.debug(e.getMessage());
        }
        test.stopTest();  
        
    }
    
    static testmethod void updatetestduplicateRecordCheck(){
        test.startTest();
        Map <String,Schema.RecordTypeInfo> recordTypeMap = PRM_Specialty_Criteria__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        
        PRM_Specialty_Criteria__c sc= new PRM_Specialty_Criteria__c();
        sc.name= 'Speciality criteria';
        sc.RecordTypeId=recordTypeMap.get('Qualitative').getRecordTypeId();
        sc.PRM_Start_Date_Dt__c = System.today()+4;
        sc.PRM_Type_Nm__c = 'Qualitative';
        insert sc;
        
        PRM_Specialty_Criteria__c sc1= new PRM_Specialty_Criteria__c();
        sc1.name= 'Speciality criteria1';
        sc1.RecordTypeId=recordTypeMap.get('Qualitative').getRecordTypeId();
        sc1.PRM_Start_Date_Dt__c = System.today()+4;
        sc1.PRM_Type_Nm__c = 'Qualitative';
        insert sc1;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty_Qualitative_Criteria__c sqc = new PRM_Specialty_Qualitative_Criteria__c();
        sqc.PRM_Criteria_Id__c = sc.id;
        sqc.PRM_Specialty_Id__c= spec.id;
        insert sqc;
        
        PRM_Specialty_Qualitative_Criteria__c sqc1 = new PRM_Specialty_Qualitative_Criteria__c();
        sqc1.PRM_Criteria_Id__c = sc1.id;
        sqc1.PRM_Specialty_Id__c= spec.id;
        insert sqc1;
        
        try{ 
            sqc1.PRM_Criteria_Id__c=sc.id;
            update sqc1;
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
        test.stopTest();  
        List<PRM_Specialty_Qualitative_Criteria__c> sqcList = [select Id, PRM_Criteria_Id__c from PRM_Specialty_Qualitative_Criteria__c where Id=:sqc1.Id ];
        String v1 = 'Error';
        System.assertNotEquals(sc.id, sqcList[0].PRM_Criteria_Id__c,v1);
    }
    
}