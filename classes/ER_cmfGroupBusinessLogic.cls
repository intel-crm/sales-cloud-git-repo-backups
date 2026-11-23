/******************************************************************************************************************************************
Class Name  : ER_cmfGroupBusinessLogic
Test Class Name : ER_cmfGroupBusinessLogic_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : Utility class to handle email delivery logic, Email logs creation.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         25/11/2023              Original version 
*****************************************************************************************************************************************/
public class ER_cmfGroupBusinessLogic {
   public static boolean isCMF=Boolean.valueOf(label.ER_IsCMF);
   public static void beforeInsertUpdateOperation(List<ER_Customer_Master_File_Group__c> cmfGroupList,Map<id,ER_Customer_Master_File_Group__c> oldMap, Boolean isInsert){
       
   }
    public static void afterInsertUpdateOperation(List<ER_Customer_Master_File_Group__c> cmfGroupList,Map<id,ER_Customer_Master_File_Group__c> oldMap, Boolean isInsert){
        Boolean isUpdate =!isInsert;
        List<String> cloneGroupIdList = new List<String>();
        // Track the newly inserted cloned group Ids to update
        List<Id> clonedNewGroupIdsToZero = new List<Id>();
        if(isInsert){
            for(ER_Customer_Master_File_Group__c cmfGroupRec : cmfGroupList){
                if(cmfGroupRec.isClone()){
                    cloneGroupIdList.add(cmfGroupRec.getCloneSourceId());
                    clonedNewGroupIdsToZero.add(cmfGroupRec.Id);
                }
            }
            if(!cloneGroupIdList.isEmpty()){
                processCloneRecords(cloneGroupIdList,cmfGroupList[0].id);
                // when isCMF = true and record is a clone, set both counters to 0 on the new group(s)
                if (isCMF && !clonedNewGroupIdsToZero.isEmpty()){
                    List<ER_Customer_Master_File_Group__c> toUpdate = new List<ER_Customer_Master_File_Group__c>();
                    for (Id newId : clonedNewGroupIdsToZero){
                        ER_Customer_Master_File_Group__c upd = new ER_Customer_Master_File_Group__c(
                            Id = newId,
                            ER_Inactive_Account_Business_Partners__c = 0,
                            ER_Active_Account_Business_Partners__c = 0
                        );
                        toUpdate.add(upd);// added as defect fix for ABP and inActive ABP not reseting to 0
                    }
                    if(!toUpdate.isEmpty()){
                        Database.update(toUpdate, AccessLevel.USER_MODE);
                    }
                }
            }
        }
    }
    public static void processCloneRecords(List<String> cloneGroupIdList,string Bagid){
        if(isCMF){
        List<String> fields = new List<String>(ER_CMFGroupAssociation__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<ER_CMFGroupAssociation__c> cmfAssocListToBeInserted = new  List<ER_CMFGroupAssociation__c> ();
        String groupId = cloneGroupIdList[0];
       String soql ='select ' + String.join(fields, ',')
       + ' from ER_CMFGroupAssociation__c'
        + ' where ER_Customer_Master_File_Group__c = :groupId AND ER_End_Date__c = null';
         //System.debug('At 27' + Database.query(soql));
         System.debug('bagId' + groupId);
         System.debug('At 28' + soql );
        for(ER_CMFGroupAssociation__c cmfAssoRec : (List<ER_CMFGroupAssociation__c>) Database.query(soql) ){
            System.debug('At 28' + cmfAssoRec);
            ER_CMFGroupAssociation__c newcmfAssocRec = cmfAssoRec.clone(false,true);
            newcmfAssocRec.ER_StartDate__c = System.now();
            newcmfAssocRec.ER_Customer_Master_File_Group__c = Bagid;
            System.debug('new obj'+ newcmfAssocRec);
           cmfAssocListToBeInserted.add(newcmfAssocRec);
        }
        System.debug('List'+cmfAssocListToBeInserted.size());
        if(!cmfAssocListToBeInserted.isEmpty()){
             System.debug('Inside INsert');
            //try{
                insert cmfAssocListToBeInserted;
            /*}
            catch(exception ex){
                System.debug(ex.getLineNumber()+ex.getLineNumber());
            }*/
            
       }
    }
        //As part of IAO- CMF TO BPID changes
        else{
            List<String> fields = new List<String>(ER_Account_Business_Partner__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<ER_Account_Business_Partner__c> accountBPListToBeInserted = new  List<ER_Account_Business_Partner__c> ();
        String groupId = cloneGroupIdList[0];
       String soql ='select ' + String.join(fields, ',')
       + ' from ER_Account_Business_Partner__c'
        + ' where ER_Customer_Master_File_Grouping__c = :groupId AND ER_End_Date__c = null';
         System.debug('bagId' + groupId);
         System.debug('At 28' + soql );
        for(ER_Account_Business_Partner__c accountBPRec : (List<ER_Account_Business_Partner__c>) Database.query(soql) ){
            System.debug('At 28' + accountBPRec);
            ER_Account_Business_Partner__c newaccountBPRec = accountBPRec.clone(false,true);
            newaccountBPRec.ER_Start_Date__c = System.now();
            newaccountBPRec.ER_Customer_Master_File_Grouping__c = Bagid;
            System.debug('new obj'+ newaccountBPRec);
           accountBPListToBeInserted.add(newaccountBPRec);
        }
        System.debug('List'+accountBPListToBeInserted.size());
        if(!accountBPListToBeInserted.isEmpty()){
             System.debug('Inside INsert');
            {
                insert accountBPListToBeInserted;
           
            }
       }
        }
    }
    
}