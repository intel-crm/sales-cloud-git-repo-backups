/******************************************************************************************************************************************
Class Name  : ER_cmfGroupBusinessLogic
Test Class Name : ER_cmfGroupBusinessLogic_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : Apex class to handle CMF group business logics like cloning of cmf group.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         25/11/2023              Original version 
*****************************************************************************************************************************************/
public class ER_cmfGroupBusinessLogic {
   public static void beforeInsertUpdateOperation(List<ER_Customer_Master_File_Group__c> cmfGroupList,Map<id,ER_Customer_Master_File_Group__c> oldMap, Boolean isInsert){
       
   }
    public static void afterInsertUpdateOperation(List<ER_Customer_Master_File_Group__c> cmfGroupList,Map<id,ER_Customer_Master_File_Group__c> oldMap, Boolean isInsert){
        Boolean isUpdate =!isInsert;
        List<String> cloneGroupIdList = new List<String>();
        if(isInsert){
            for(ER_Customer_Master_File_Group__c cmfGroupRec : cmfGroupList){
                if(cmfGroupRec.isClone()){
                    cloneGroupIdList.add(cmfGroupRec.getCloneSourceId());
                }
            }
            if(!cloneGroupIdList.isEmpty()){
                processCloneRecords(cloneGroupIdList,cmfGroupList[0].id);
            }
        }
    }
    public static void processCloneRecords(List<String> cloneGroupIdList,string Bagid){
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
    
}