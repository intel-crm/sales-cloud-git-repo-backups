/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_Bulk_CRUD_Operations 
* Version     : 1.0 
* Created Date: 27-01-2025
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JB 		 27-01-2025					  Batch class to enable insertion of sbobjects in multiple batches.
													  This class does not contain any business logic, it is meant only for DML
****************************************************************************************************************************************/
public class Core_MDF_Batch_Bulk_CRUD_Operations implements Database.Batchable<SObject> {
    public List<SObject> sObjectList;
    public string dmlMode = 'insert';
    public boolean allOrNone = false;

    // this constructor is to be deleted
    public Core_MDF_Batch_Bulk_CRUD_Operations(List<SObject> sObjectList) {
        this.sObjectList = sObjectList;
    }
/***********************************************************************************************************   
Constructor Name:   Core_MDF_Batch_Bulk_CRUD_Operations(List<SObject> sObjectList,String dmlMode,boolean allOrNone)
Parameter :         List<SObject>, String, boolean(SObject List, dml mode:insert/update/upsert,AllorNone ind)
Description:        This method is used to submit batch processing of SObjectList DMLs
Added By:           Accenture - JB - 27-01-2025
Modified By:        Date:       Changes: 
*************************************************************************************************************/     
    public Core_MDF_Batch_Bulk_CRUD_Operations(List<SObject> sObjectList,String dmlMode,boolean allOrNone) {
        this.sObjectList = sObjectList;
        this.dmlMode = dmlMode;
        if(!String.isBlank(dmlMode) && !String.isEmpty(dmlMode)){this.dmlMode = dmlMode.toLowercase(); }              
        this.allOrNone = allOrNone;       
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {
        return sObjectList;
    }

    public void execute(Database.BatchableContext bc, List<SObject> sObjectList) {
        List<Database.SaveResult> sResults;
        List<Database.upsertResult> uResults;
        try {
            switch on this.dmlMode{
                when 'insert'{sResults = Database.insert(sObjectList, this.allOrNone);}
                when 'update'{sResults = Database.update(sObjectList, this.allOrNone);}
                when 'upsert'{uResults = Database.upsert(sObjectList, this.allOrNone);}  
                when else{sResults = Database.insert(sObjectList, this.allOrNone);}
            }
        } catch (DmlException e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}