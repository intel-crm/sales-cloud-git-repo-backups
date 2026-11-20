({

  doInit : function(component, event, helper) {
      // Wrap in timeout due to load timing issue
      window.setTimeout(function(){
          helper.resetUrls(component, helper);
      });
    
    // Close modal when clicking outside of component
    var closeIfClickedOutsideComponent = function(event) {
      if (component.get('v.modalOpen')) {
        var thisComponent = component.find('outerElement').getElement();
        var isClickInside = thisComponent.contains(event.target);

        if (!isClickInside) {
          component.set('v.modalOpen', false);
          helper.toggleModal(component, false);
        }
      }
    };
    document.addEventListener("touchstart", closeIfClickedOutsideComponent);
    document.addEventListener("click", closeIfClickedOutsideComponent);    
  },

  handleDataChange : function(component, event, helper) {
    // Wrap in timeout due to load timing issue
    window.setTimeout(function(){
    	helper.resetUrls(component, helper);
    });
  },

  handleBreadCrumbClick : function(component, event, helper) {
    event.preventDefault();
    event.stopPropagation();
    component.set('v.modalOpen', false);

    var url = event.getSource().get('v.href');
    if (component.get('v.previewMode')) {
      
    } else if (component.get('v.onselect')) {
      component.get('v.onselect')(url);
    } else {
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({ url: url });
      urlEvent.fire();
    }

  },

  handleCloseMobileOverlay : function(component, event, helper) {
    component.set('v.modalOpen', false);
    event.preventDefault();
  },

  handleOpenMobileOverlay : function(component, event, helper) {
    component.set('v.modalOpen', true);
    event.preventDefault();
  },

})