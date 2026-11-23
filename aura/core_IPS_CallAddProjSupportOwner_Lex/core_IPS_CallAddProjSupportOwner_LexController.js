({
	  callSaveMethod : function(component, event, helper) {

        var findChildComp=component.find('core_IPS_AddProjSupportOwner_LexId');

        findChildComp.handleSave();

      },
    callCancelMethod : function(component, event, helper) {

        var findChildComp=component.find('core_IPS_AddProjSupportOwner_LexId');

        findChildComp.handleCancel();

      }
})