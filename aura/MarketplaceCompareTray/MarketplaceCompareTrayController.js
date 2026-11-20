({

  doInit : function(component, event, helper) {

    var maxItems = component.get('v.maxItemsToCompare');
    component.set('v.mapStateToAttributes', function(state) {
      var openState = component.get('v.open');
      return {
        items: state.items,
        open: state.items.length == 0 ? false : openState, // keep open state if items value changed
        notificationMessage: state.notificationMessage,
        placeholders: Array(maxItems - state.items.length)
      };
    });     
      //component.set('v.open',false);
  },
    doSomething : function(component, event, helper) {
        // added because having issues
    },

  handleNotification : function(component, event, helper) {
    if(component.get('v.notificationMessage')) component.set('v.open', true);
  },

  handleClearAll : function(component, event, helper) {
    helper.dispatch(component, 'clearCompareTray');
  },

  handleOpenClose : function(component, event, helper) {
    component.set('v.open', !component.get('v.open'));
    if (!component.get('v.open')) helper.dispatch(component, 'clearCompareTrayNotification');
  },

  handleRemoveItem : function(component, event, helper) {
    helper.dispatch(component, 'toggleCompareTrayItem',
      { item: { id: event.currentTarget.dataset.id } }
    );
  },

})