/****************************************************************************************************************************************
* Class Name  : PMP_SpecValueTriggerHandler 
* Version     : 1.0 
* Created Date: 13-11-2018
* Modification Log :
* Developer                      Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys-Sangeetha Ganta       13/11/2018          Created for extending Trigger framework to process 
                                                    Specification Value lookup update.
*****************************************************************************************************************************************/
public class PMP_SpecValueTriggerHandler extends TriggerHandler
{
   /* public override void afterInsert(){
        
    }*/
    
    /*public override void beforeUpdate() {
} */  
    
   /* public override void beforeInsert() {   
    }*/
    
    /*public override void beforeDelete(){
    }*/
    
    public override void afterUpdate(){ 
        //PMP_DeleteOfferingSpecification.deleteOfferingSpecification2(trigger.new);
    }
    
    /*public override void afterDelete(){        
    }*/

  /*  public override void afterUndelete(){        
    }*/
}