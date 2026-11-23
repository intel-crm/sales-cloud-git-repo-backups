({
    
    doInit : function(component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            helper.setTabs(component);
            helper.addScreenSizeChangeHandler(component, helper);
            helper.selectTab(component, helper, component.get('v.initialTab') || 0);
        }), 5);
        // needs to be done after render
        window.setTimeout($A.getCallback(function() {
            helper.checkPaddleState(component);
        }), 200);
    },
    
    handleChangeTab : function(component, event, helper) {
        var index = event.currentTarget.dataset.index;
        helper.selectTab(component,helper, index);
        if (typeof component.get('v.onTabChange') == 'function') {
            component.get('v.onTabChange')(index);
        }
        event.preventDefault();
        
        if(component.get('v.isFeaturedTabSet')){
            //Analytics code for Featured tabs
            var analyticsData = component.find("analyticsData");
            var type = 'navigation';
            var element = 'tab-nav';
            var detail = component.get('v.allTabLabels')[index];
            var href = '/tabs/'+component.get('v.allTabLabels')[index]; 
            analyticsData.formAnalyticsData(type,detail,element,href);
            //Analytics code end
        }
    },
    
    handleChangeTabMethod: function(component, event, helper) {
        var index = event.getParam("arguments").tabIndex;
        if (typeof component.get('v.onTabChange') == 'function') {
            component.get('v.onTabChange')(index);
        }
        helper.selectTab(component,helper, index);
    },
    
    handlePaddleClick: function(component, event, helper) {
        var direction = event.currentTarget.dataset.direction;
        var navigation = component.find('navigation').getElement();
        var innerNavigation = component.find('inner-carousel').getElement();
        var modalID = document.getElementById("modal-content-id-1");
        var scrollOffset = component.get('v.scrollOffset');
        var newScrollOffset;
        
        var navWidth = innerNavigation.scrollWidth;
        var pageWidth = window.innerWidth;
        var modalWidth = modalID.scrollWidth;
        
        //If in Edit Storefront/Profile Tabset Modal
        if (modalID) {
            if (direction === 'next') {
                newScrollOffset = scrollOffset + modalWidth;
                newScrollOffset = (newScrollOffset > navWidth - modalWidth) ? (navWidth - modalWidth) : newScrollOffset;
                
            } else {
                newScrollOffset = scrollOffset - modalWidth;
                newScrollOffset = (newScrollOffset < 0) ? 0 : newScrollOffset
            }
        } else {
            if (direction === 'next') {
                newScrollOffset = scrollOffset + pageWidth;
                newScrollOffset = (newScrollOffset > navWidth - pageWidth) ? (navWidth - pageWidth) : newScrollOffset;
                
            } else {
                newScrollOffset = scrollOffset - pageWidth;
                newScrollOffset = (newScrollOffset < 0) ? 0 : newScrollOffset
            }
        }
        
        innerNavigation.style.transform = 'translateX(-' + newScrollOffset + 'px)';
        component.set('v.scrollOffset', newScrollOffset);
        helper.checkPaddleState(component);
    }
    
    
})