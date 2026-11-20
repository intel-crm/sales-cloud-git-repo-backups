/****************************************************************************************************************************************
* Class Name  : PMP_SpecificationTriggerHandler 
* Version     : 1.0 
* Created Date: 13-11-2018
* Modification Log :
* Developer                      Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta       13/11/2018          Created for extending Trigger framework to process 
                                                    Specification Parent lookup update.
*****************************************************************************************************************************************/
public class PMP_SpecificationTriggerHandler extends TriggerHandler
{

    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
        run=false;
        return true;
        }else{
            return run;
        }
    }

    public override void afterInsert(){
        //System.debug('I am here in Trigger Handler');
        PMP_ParentSpecificationUpdate.updateParentSpec(trigger.new);
    }
    
    /*public override void beforeUpdate() {
} */  
    
   /* public override void beforeInsert() {   
    }*/
    
    /*public override void beforeDelete(){
    }*/
    
    public override void afterUpdate(){ 
        if(runOnce())
        {
            PMP_ParentSpecificationUpdate.updateParentSpec(trigger.new);
            //PMP_DeleteOfferingSpecification.deleteOfferingSpecification(trigger.new);            
        }
    }
    
    /*public override void afterDelete(){        
    }*/

  /*  public override void afterUndelete(){        
    }*/
}