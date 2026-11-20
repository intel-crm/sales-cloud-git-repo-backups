/****************************************************************************************************************************************
* Class Name  : PMP_CategoryTriggerHandler 
* Version     : 1.0 
* Created Date: 09-11-2018
* Modification Log :
* Developer                      Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta       9/11/2018          Created for extending Trigger framework to process 
                                                   Category Parent lookup update.
* Infosys-Sangeetha Ganta       02/26/2019         US247101. Update the Parent Category based on the Active flag valueS
*****************************************************************************************************************************************/
public class PMP_CategoryTriggerHandler extends TriggerHandler
{
    public static boolean triggerSwitch = true;
    public override void afterInsert(){
        PMP_ParentCategoryUpdate.updateParentonInsert(trigger.new);
    }
    
    /*public override void beforeUpdate() {
}*/ 
    
   /* public override void beforeInsert() {   
    }*/
    
    /*public override void beforeDelete(){
    }*/
    
    public override void afterUpdate(){ 
        if(triggerSwitch)
        {
            PMP_ParentCategoryUpdate.updateParentonInsert(trigger.new); 
           // PMP_DeleteOfferingCategory.deleteOfferingCategory(trigger.new);
        }
    }
    
    /*public override void afterDelete(){        
    }*/

  /*  public override void afterUndelete(){        
    }*/
}