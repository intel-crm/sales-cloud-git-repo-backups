({
   /* doInit: function(component,event,helper){
      var action = component.get("c.checkProjEditAccess");
      action.setParams({projectId:component.get('v.recordId')});
      action.setCallback(this,function(response){
        var state = response.getState();
        if(state == 'SUCCESS'){
          component.set('v.isError',response.getReturnValue());
        }
      });
      $A.enqueueAction(action);
      },
     */
	  callAddMethod : function(component, event, helper) {

        var findChildComp=component.find('core_IPS_AddMembers_LexId');

        findChildComp.addMember();

      },
    callAddDoneMethod : function(component, event, helper) {

        var findChildComp=component.find('core_IPS_AddMembers_LexId');

        findChildComp.addMemberDone();

      },
    callCancelMethod : function(component, event, helper) {

        var findChildComp=component.find('core_IPS_AddMembers_LexId');

        findChildComp.Cancel();

      }
})