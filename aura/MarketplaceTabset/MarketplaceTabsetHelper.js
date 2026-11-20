({
    getAllTabs : function(component) {
        var findTabs = function(cmp) {
            var body = cmp.get('v.body');
            return body ? body.reduce(function(list, c) {
                var tabs = [];
                if (!c.getName || (c.getName && c.getName() != 'cMarketplaceTab')) {
                    tabs = findTabs(c);
                } else if (c.getName() == 'cMarketplaceTab') {
                    tabs = c;
                }
                return list.concat(tabs);
            }, []) : [];
        }
        return findTabs(component);
    },
    
    setTabs : function(component, helper) {
        var allTabs = this.getAllTabs(component);
        
        var allTabLabels = [];
        if (allTabs) {
            allTabs.forEach(function(tab) {
                allTabLabels.push(tab.get('v.label'));
            });
        }
        
        component.set('v.allTabs', allTabs);
        component.set('v.allTabLabels', allTabLabels);
    },
    
    selectTab : function(component, helper, index) {
        var onActive = component.get('v.onActive');
        component.set('v.currentTabIndex', index);
        var navItem = component.find('navItem');
        var allTabs = helper.getAllTabs(component);
        
        //Intel change - below code modified by MGDANIES for single tab operation Date: 26-Aug-2019
        var navItem = component.find('navItem');
        if(Array.isArray(navItem)){
            navItem.forEach(function(cmp, idx) {
                if (idx == index) {
                    $A.util.addClass(cmp, 'active');
                } else {
                    $A.util.removeClass(cmp, 'active');
                }
            });
        } else {
        	$A.util.addClass(navItem, 'active');    
        }
        // End mod
        
        if (allTabs) {
            component.set('v.currentTab', allTabs[index]);
            allTabs.forEach(function(tab, index) {
               
                tab.set('v.active', index == component.get('v.currentTabIndex'));
            });
        }
        
        if (typeof onActive === 'function') {
            onActive(component, index);
        }
        
    },
    
    addScreenSizeChangeHandler : function(component, helper) {
        if (!component.get('v.screenResizeHandler')){
            component.set('v.screenResizeHandler', true);
            window.addEventListener('resize', $A.getCallback(function() {
                if(component.isValid()) {
                    // reset to 0 translate for screensize
                    var innerNavigation = component.find('inner-carousel').getElement();
                    if (innerNavigation) {
                        innerNavigation.style.transform = 'translateX(-' + 0 + 'px)';
                        component.set('v.scrollOffset', 0);
                        helper.checkPaddleState(component);
                    }
                } else {
                    // remove listener
                }
            }));
        }
    },
    
    checkPaddleState: function(component) {
        var carousel = component.find('inner-carousel');
        if (carousel) {
            var modalID = document.getElementById("modal-content-id-1");
            var innerNavigation = component.find('inner-carousel').getElement();
            var scrollOffset = component.get('v.scrollOffset');
            var navWidth = innerNavigation.scrollWidth;
            var pageWidth = window.innerWidth;

            //If in Edit Storefront/Profile Tabset Modal
            if (modalID) {
                var modalWidth = modalID.scrollWidth;
                var prevVisible = scrollOffset > 0;
                var nextVisible = (scrollOffset < (navWidth - modalWidth));
            } else {
                var prevVisible = scrollOffset > 0;
                var nextVisible = (scrollOffset < (navWidth - pageWidth));
            }
        
            // no scroll needed
            if (pageWidth === navWidth) {
                prevVisible = false;
                nextVisible = false;
            }
            
            component.set('v.paddlePrevVisible', prevVisible);
            component.set('v.paddleNextVisible', nextVisible);
        }
    }
    
})