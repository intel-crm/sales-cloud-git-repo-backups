/****************************************************************************************************************************************
* Class Name  : Core_MDF_UpdateOutBasedCampAttr_Sch 
* Version     : 1.0 
* Created Date: 10-05-2026
* Created By  : ACC-Vikas Soni
* Test Class  : Core_MDF_UpdateOutBasedCampAttr_SchTest
* Schedule Script for Hourly:
* System.schedule('Core_MDF_UpdateOutBasedCampAttr_Sch_Hourly', '0 0 * * * ?', new Core_MDF_UpdateOutBasedCampAttr_Sch());
* Modification Log :
* Developer            Date               Description
*****************************************************************************************************************************************/
public class Core_MDF_UpdateOutBasedCampAttr_Sch implements Schedulable {

    public void execute(SchedulableContext sc) {
            Database.executeBatch(new Core_MDF_UpdateOutBasedCampAttrBatch(), 200);
    }
}