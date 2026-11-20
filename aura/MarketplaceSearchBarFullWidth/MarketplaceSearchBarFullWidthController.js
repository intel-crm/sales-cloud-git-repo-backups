({

	doInit : function(component, event, helper) {
    var displayType = component.get('v.displayType');

    if (displayType == 'product') {
      //component.set('v.viewAllLabel', $A.get("$Label.c.PMP_L1_Search_Bar_View_All_Products"));
      component.set('v.viewAllLabel', $A.get("$Label.c.PMP_View_All_Offerings"));
      component.set('v.viewAllSearchParams', { type: 'product' });

    } else if (displayType == 'partner') {
      component.set('v.viewAllLabel', $A.get("$Label.c.PMP_L1_Search_Bar_View_All_Partners"));
        component.set('v.viewAllSearchParams', { type: 'partner'});
    }
	},

  handleClickLink : function(component, event, helper) {
    var urlParams     = { type: component.get('v.displayType') },
        pageName      = 'search',
        urlEvent      = $A.get("e.force:navigateToURL");

    var str = encodeURIComponent(JSON.stringify(urlParams));

    urlEvent.setParams({ url: '/' + pageName + '?search=' + str });
    if (component.get('v.debugMode')) {
      console.log('L2 DEBUG -- PARAMS / URL -- ', urlParams, '/' + pageName + '?search=' + str);
    } else { 
      urlEvent.fire();
    }
  },

})