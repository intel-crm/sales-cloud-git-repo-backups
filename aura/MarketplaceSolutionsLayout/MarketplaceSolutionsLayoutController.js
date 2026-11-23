({
    doInit : function(component, event, helper) {
        window.addEventListener('resize', $A.getCallback(function() {
            if(component.isValid()) {
                var currentScreenSize = window.innerWidth < 768 ? 'mobile' : 'desktop';
                var prevScreenSize = component.get('v.appState.Settings.currentScreenSize');
                if (currentScreenSize != prevScreenSize) {
                    helper.dispatch(component, 'changeSetting', {
                        currentScreenSize: currentScreenSize
                    });
                }

                var bpList = [{bp: 'small', maxWidth:768},{bp: 'medium', maxWidth:1024},{bp: 'large', maxWidth:1280},	{bp: 'x-large', maxWidth:10000}	];
                var currentSldsBreakpoint = bpList.find(function(bp){	return (window.innerWidth < bp.maxWidth);	}).bp;

                var prevSldsBreakPoint = component.get('v.appState.Settings.currentSldsBreakPoint');
                if (currentSldsBreakpoint != prevSldsBreakPoint) {
                  helper.dispatch(component, 'changeSetting', {
                    currentSldsBreakPoint: currentSldsBreakpoint
                  });
                }
                
                
            }
        }));
    },
    handlePageEvent: function(component, event, helper) {
        // Handler to dynamically add the lead generation form to the page when
        // the page event has been triggered
            if (event.getParam('type') == 'openLeadGenModal') {
          var payload = event.getParam('payload');
    
          // If component is not yet present, add it here
          if (!component.find('leadGenerationForm')) {
            $A.createComponent("c:MarketplaceLeadGenForm", {
              'aura:id': 'leadGenerationForm',
            },
            function(newComponent, status, errorMessage) {
              if (status === "SUCCESS") {
                var container = component.get("v.main");
                container.push(newComponent);
                component.set("v.main", container);
                // retrigger event
                var appEvent = $A.get("e.c:MarketplacePageEvent");
                appEvent.setParams({
                  type: "openLeadGenModal",
                  payload: payload
                });
                appEvent.fire();
              } else if (status === "INCOMPLETE") {
                console.error("No response from server or client is offline.");
              } else if (status === "ERROR") {
                console.error("Error: " + errorMessage);
              }
            });
          }
    
            }
        },
    //IPA2.0: US-TWC729-7976
    /*handleAdminEvent: function(component, event, helper) {
        
        var isAdmin = event.getParam("isAdmin");
        
        component.set("v.showFullWidth", !isAdmin);
        
    }*/
})