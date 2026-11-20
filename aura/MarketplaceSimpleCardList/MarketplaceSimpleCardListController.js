({
    doInit : function(component, event, helper) {
      var showOnlyFirst = component.get('v.showOnlyFirst'),
          showOnlyFirstMobile = component.get('v.showOnlyFirstMobile');

      component.set('v.mapStateToAttributes', function(state) {
        return {
          indexShowCount: state.currentScreenSize === 'desktop' ? showOnlyFirst : showOnlyFirstMobile
        };
      });


    },
    expandAll : function(component, event, helper) {
        component.set('v.viewAll', true);
    },

    handleClick : function(component, event, helper) {
        event.preventDefault();
        var currentIndex = event.currentTarget.dataset.index;

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.data')[currentIndex].link
        });
        urlEvent.fire();
    }
})