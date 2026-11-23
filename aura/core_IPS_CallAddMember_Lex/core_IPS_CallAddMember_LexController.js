/*({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
    }
})*/
({
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

      findChildComp.auraCancel();

    }
})