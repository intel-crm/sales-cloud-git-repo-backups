({
   init : function(cmp, event, helper) {
      // Figure out which buttons to display
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
        if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } 
      }
   },
        
   onButtonPressed: function(cmp, event, helper) {
      var actionClicked = event.getSource().getLocalId();
      var navigate = cmp.get('v.navigateFlow');
      navigate(actionClicked);
   }
})