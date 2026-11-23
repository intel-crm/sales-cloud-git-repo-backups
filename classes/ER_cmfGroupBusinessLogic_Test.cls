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
    @testSetup
    public static void recordSetup(){
        List<ER_Customer_Master_File_Group__c> cmfGroupList= new List<ER_Customer_Master_File_Group__c>();
        for(Integer i=0; i<5;i++){
            ER_Customer_Master_File_Group__c cmfGroup= new ER_Customer_Master_File_Group__c();
            cmfGroup.Name= 'testName'+i;
            cmfGroupList.add(cmfGroup);
        }
        Database.Insert(cmfGroupList);
        cmfGroupList[1].Name= 'New Test Bag';
        update cmfGroupList[1];
        
        ER_Customer_Master_File__c cmf= new ER_Customer_Master_File__c();
        cmf.Name='testCmfName';
        cmf.ER_CMF_Name__c='testCMF';
        cmf.ER_Sales_Disti_Chnl_Code__c='EU02';
        Database.Insert(cmf);
        List<ER_CMFGroupAssociation__c> cmfAssocList = new  List<ER_CMFGroupAssociation__c>();
        for(ER_Customer_Master_File_Group__c cmfgroup:cmfGroupList){
            ER_CMFGroupAssociation__c cmfAssoc= new ER_CMFGroupAssociation__c();
           cmfAssoc.ER_Customer_Master_File__c=cmf.Id;
            cmfAssoc.ER_Customer_Master_File_Group__c=cmfgroup.Id;
            cmfAssocList.add(cmfAssoc);
        }
        Database.Insert(cmfAssocList);
        
    }
    @IsTest
    public static void cloneData(){
       ER_Customer_Master_File_Group__c cmfGroup=[Select Name from ER_Customer_Master_File_Group__c where Name='testName0' Limit 1];
        ER_Customer_Master_File_Group__c cloneCmfGroup=cmfGroup.clone(false, false, false, false);
        cloneCmfGroup.Name ='TestNewCloneBag';
        insert cloneCmfGroup;
        ER_CMFGroupAssociation__c cmfAssoc=[select ER_CMF_Name__c from ER_CMFGroupAssociation__c Limit 1];
        Assert.areEqual('testCMF',cmfAssoc.ER_CMF_Name__c,'CMF Association Cloned');
    }
}