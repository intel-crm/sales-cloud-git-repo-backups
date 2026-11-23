/******************************************************************************************************************************************
Test Class Name : ER_cmfGroupBusinessLogic_Test
Class Name  : ER_cmfGroupTriggerHandler,ER_cmfGroupBusinessLogic,ER_cmfGroupTrigger
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : Utility class to handle email delivery logic, Email logs creation.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Hemant                    25/11/2023              Original version 
*****************************************************************************************************************************************/
@IsTest
public class ER_cmfGroupBusinessLogic_Test {

    /*-----------------------------------------------------------
      TEST DATA SETUP
    -----------------------------------------------------------*/
    @testSetup
    public static void recordSetup(){

        // Create CMF Groups
        List<ER_Customer_Master_File_Group__c> cmfGroupList =
            new List<ER_Customer_Master_File_Group__c>();

        for(Integer i = 0; i < 5; i++){
            cmfGroupList.add(
                new ER_Customer_Master_File_Group__c(
                    Name = 'testName' + i
                )
            );
        }
        insert cmfGroupList;

        // Create CMF
        ER_Customer_Master_File__c cmf = new ER_Customer_Master_File__c(
            Name = 'testCmfName',
            ER_CMF_Name__c = 'testCMF',
            ER_Sales_Disti_Chnl_Code__c = 'EU02'
        );
        insert cmf;

        // Create CMF Group Associations (ACTIVE)
        List<ER_CMFGroupAssociation__c> assocList =
            new List<ER_CMFGroupAssociation__c>();

        for(ER_Customer_Master_File_Group__c grp : cmfGroupList){
            assocList.add(
                new ER_CMFGroupAssociation__c(
                    ER_Customer_Master_File__c = cmf.Id,
                    ER_Customer_Master_File_Group__c = grp.Id,
                    ER_StartDate__c = System.now()
                )
            );
        }
        insert assocList;

        // Create Account Business Partner (non-CMF path)
        ER_Account_Business_Partner__c bp =
            new ER_Account_Business_Partner__c(
                ER_Customer_Master_File_Grouping__c = cmfGroupList[0].Id,
                ER_Start_Date__c = System.now()
            );
       // insert bp;
    }

    /*-----------------------------------------------------------
      TEST 1: CMF = TRUE → Clone + After Insert Logic
    -----------------------------------------------------------*/
    @IsTest
    public static void testClone_CMF_True(){

        ER_cmfGroupBusinessLogic.isCMF = true;

        // 🔴 End-date existing associations to avoid validation failure
        List<ER_CMFGroupAssociation__c> activeAssoc =
            [SELECT Id, ER_End_Date__c
             FROM ER_CMFGroupAssociation__c
             WHERE ER_End_Date__c = null];

        for(ER_CMFGroupAssociation__c assoc : activeAssoc){
            assoc.ER_End_Date__c = Date.today();
        }
        update activeAssoc;

        ER_Customer_Master_File_Group__c sourceGroup =
            [SELECT Id
             FROM ER_Customer_Master_File_Group__c
             WHERE Name = 'testName0'
             LIMIT 1];

        Test.startTest();

        ER_Customer_Master_File_Group__c clonedGroup =
            sourceGroup.clone(false, true);
        clonedGroup.Name = 'CMF Clone Group';
        insert clonedGroup;

        ER_cmfGroupBusinessLogic.afterInsertUpdateOperation(
            new List<ER_Customer_Master_File_Group__c>{ clonedGroup },
            null,
            true
        );

        Test.stopTest();
    }

    /*-----------------------------------------------------------
      TEST 2: CMF = FALSE → Account Business Partner Cloning
    -----------------------------------------------------------*/
    @IsTest
    public static void testClone_CMF_False(){

        ER_cmfGroupBusinessLogic.isCMF = false;

        ER_Customer_Master_File_Group__c sourceGroup =
            [SELECT Id
             FROM ER_Customer_Master_File_Group__c
             LIMIT 1];

        Test.startTest();

        ER_Customer_Master_File_Group__c clonedGroup =
            sourceGroup.clone(false, true);
        clonedGroup.Name = 'Non CMF Clone';
        insert clonedGroup;

        ER_cmfGroupBusinessLogic.afterInsertUpdateOperation(
            new List<ER_Customer_Master_File_Group__c>{ clonedGroup },
            null,
            true
        );

        Test.stopTest();
    }

    /*-----------------------------------------------------------
      TEST 3: Direct processCloneRecords Execution
    -----------------------------------------------------------*/
    @IsTest
    public static void testProcessCloneRecordsDirect(){

        ER_cmfGroupBusinessLogic.isCMF = true;

        // 🔴 End-date existing associations
        List<ER_CMFGroupAssociation__c> assocList =
            [SELECT Id, ER_End_Date__c
             FROM ER_CMFGroupAssociation__c
             WHERE ER_End_Date__c = null];

        for(ER_CMFGroupAssociation__c assoc : assocList){
            assoc.ER_End_Date__c = Date.today();
        }
        update assocList;

        ER_Customer_Master_File_Group__c sourceGroup =
            [SELECT Id
             FROM ER_Customer_Master_File_Group__c
             LIMIT 1];

        ER_Customer_Master_File_Group__c newGroup =
            new ER_Customer_Master_File_Group__c(
                Name = 'Direct Process Clone'
            );
        insert newGroup;

        Test.startTest();

        ER_cmfGroupBusinessLogic.processCloneRecords(
            new List<String>{ sourceGroup.Id },
            newGroup.Id
        );

        Test.stopTest();
    }
}