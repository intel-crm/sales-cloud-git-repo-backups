public class PRM_ALA_TriggerHandler extends TriggerHandler {
    public static boolean firstRun = true;
    //Added by Anand TB as part of US847809
    public override void afterInsert() {
       /* if(isActive('ALA_Insert_IPA_Integration_Trigger') && firstRun) {
            // Agate - Added is batch check to avoid too many queueable errors
            if(system.isBatch()){
                new ContactERPMIntegrationStatusHandler((List<PRM_AccountLegalAgreemntAssociation__c>)Trigger.new,  Trigger.new.getSObjectType());
            }
            else{
            System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountLegalAgreemntAssociation__c>)Trigger.new,  Trigger.new.getSObjectType()));
            }
            firstRun = false;       
            // Agate - End 
        } */    //chaithaly - commenting as part of IPA2.0 optimization
        
       		//PRM_ALA_Utility.PopulateLegalAgreeOnOPID(Trigger.new); 
       		if(isActive('ALA_Insert_IPA_Integration_Trigger') && !PRM_CreateAccountAndRelatedRecordsAdmin.IS_Admin_Invite){
       		//if(PRM_IPAR_ProfileResponse_Utility.profRespSwitch || test.isRunningTest()){
                PRM_ALA_Utility.updateProfileResponse_IPAR(Trigger.new);
            /*}else{
                
                PRM_ALA_Utility.updateProfileResponse(Trigger.new);
            	}*/ // IPA switch removal
        	}             
       }
    
    public override void afterupdate() {
      if(isActive('ALA_Insert_IPA_Integration_Trigger') && !PRM_CreateAccountAndRelatedRecordsAdmin.IS_Admin_Invite){
        //if(PRM_IPAR_ProfileResponse_Utility.profRespSwitch || test.isRunningTest()){
                PRM_ALA_Utility.updateProfileResponse_IPAR(Trigger.new);
           /* }else{               
                PRM_ALA_Utility.updateProfileResponse(Trigger.new);
            	}*/ // IPA switch removal
        	}    
      }
      
    
    public override void beforeinsert(){
    	if(isActive('ALA_Insert_IPA_Integration_Trigger')){
        	PRM_ALA_Utility.updateLACode(Trigger.new);
        }
    }
    public override void beforeupdate(){
        if(isActive('ALA_Insert_IPA_Integration_Trigger')){
        	PRM_ALA_Utility.updateLACode(Trigger.new);
        }
    }
    
    //IPA Refresh 2.0 - TWC729-8296
    public override void afterdelete() {
        if(isActive('ALA_Insert_IPA_Integration_Trigger')){
            //if(PRM_IPAR_ProfileResponse_Utility.profRespSwitch || test.isRunningTest()){
                PRM_ALA_Utility.updateProfileResponse_IPAR(Trigger.old);
            /*}else{
                PRM_ALA_Utility.updateProfileResponse(Trigger.old);
            }*/ // ipa switch removal
        }
    }
}