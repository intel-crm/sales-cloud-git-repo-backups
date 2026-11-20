({
    handleDestroy: function (component, event, helper) {
        $A.get("e.force:refreshView").fire();
    },

    cancelPopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
  })