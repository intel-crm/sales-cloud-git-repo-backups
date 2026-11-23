({
    doInit : function(component, event, helper) {

        var stickySectionContainer = component.find("stickyTabContainer");
        var i, i_l, clickScrollTracker;
        window.setTimeout($A.getCallback(function() {
          helper.setTabs(component);

          stickySectionContainer = component.find("stickyTabContainer");
          // New from Tabs
          helper.addScreenSizeChangeHandler(component, helper);

          window.addEventListener('scroll', $A.getCallback(function() {
              var containerOffsetTop = component.get('v.containerOffsetTop');
              var headerOffset = component.get('v.headerOffset');// subtract component padding
              var isSticky = false;
              var windowOffset = window.pageYOffset;
              var selectedIndex = -1;
              var documentHeight = document.documentElement.scrollHeight;
              if (component.isValid()){
                
                if (containerOffsetTop == -1 || documentHeight != component.get('v.pageHeight')) {
                  // recalculate offset when page height changes
                  component.set('v.pageHeight', document.documentElement.scrollHeight);
                  helper.recalculateElementsOffset(component,event,helper);
                  containerOffsetTop = component.get('v.containerOffsetTop');
                }
                if(windowOffset >= containerOffsetTop) {
                    isSticky = true;
                    $A.util.addClass(stickySectionContainer, 'fixed');
                } else if(windowOffset < containerOffsetTop) {
                    isSticky = false;
                    $A.util.removeClass(stickySectionContainer, 'fixed');
                }

                var tabsOffset = component.get('v.tabsOffset');
                var clickedTo = component.get('v.clickedTo');
                window.clearTimeout(clickScrollTracker);
                clickScrollTracker = window.setTimeout($A.getCallback(function() {
                  component.set('v.clickedTo', undefined);
                }), 100);

                // select the elements basd on scroll position
                if (tabsOffset){
                  var headOffset = isSticky ? headerOffset : headerOffset;

                  for (i = 0, i_l = tabsOffset.length; i < i_l; i++){
                      var nextTop = i + 1 < i_l ? tabsOffset[i+1] : 99999; // peek next top;
                      if (windowOffset >= tabsOffset[i] - headOffset && windowOffset < nextTop - headOffset) {
                        if (clickedTo && clickedTo == (i + 1) && windowOffset >= tabsOffset[i] + ((tabsOffset[i+1] - tabsOffset[i]) / 2)) i++;
                        helper.selectTab(component,helper, i);
                        selectedIndex = i;
                        break;
                      }
                  }
                  if (selectedIndex == -1) {
                    // console.log('no index selected');
                    helper.selectTab(component,helper, 0);
                  }
                }
              }

          }));
        }), 10);

        // needs to be done after render
        window.setTimeout($A.getCallback(function() {
          helper.checkPaddleState(component);
        }), 200);

    },
    handleReset: function(component, event, helper) {
        //alert('Tab click : Line 73');
        console.log('In here Line 74');
      helper.recalculateElementsOffset(component,event,helper);
    },
    scrollToTabBody: function(component, event, helper) {
        //alert('Tab click : Line 78');
        console.log('In here Line 79');
      event.preventDefault();
  		var index = event.currentTarget.dataset.index;
      component.set('v.clickedTo', index);
      var tabsOffset = component.get('v.tabsOffset');
      var allTabs =   component.get('v.allTabs');
      var headerOffset = component.get('v.headerOffset') - 1;// subtract component padding
      var selectedTab = allTabs && allTabs.length ? allTabs[index] : false;
      var scrollTo;
      if (selectedTab) {
        // get actual tab value
        scrollTo = helper.calculateOffset(selectedTab.getElement()).top;
        if (tabsOffset && tabsOffset[index] != scrollTo ){
          // recalculate offsets if different form saved for accuracy
          helper.recalculateElementsOffset(component,event,helper);
        }
        // Note: does not work in ie
        var isSmoothScrollSupported = 'scrollBehavior' in document.documentElement.style;
        if (isSmoothScrollSupported){
          window.scrollTo({
            top: scrollTo - headerOffset,
            behavior: 'smooth',
          });
        } else {
          // usually IE only
          window.scrollTo(0, scrollTo - headerOffset);
        }
      }
      helper.selectTab(component,helper, index);
    },
    // Taken from TabsetController
    handlePaddleClick: function(component, event, helper) {
        //alert('Tab click : Line 108');
        console.log('In here Line 110');
      var direction = event.currentTarget.dataset.direction;
      var navigation = component.find('navigation').getElement();
      var innerNavigation = component.find('inner-link-list').getElement();
      var scrollOffset = component.get('v.scrollOffset');
      var newScrollOffset;
  
      var navWidth = innerNavigation.scrollWidth;
      var pageWidth = window.innerWidth;
  
      if (direction === 'next') {
         newScrollOffset = scrollOffset + pageWidth;
         newScrollOffset = (newScrollOffset > navWidth - pageWidth) ? (navWidth - pageWidth) : newScrollOffset;
  
      } else {
        newScrollOffset = scrollOffset - pageWidth;
        newScrollOffset = (newScrollOffset < 0) ? 0 : newScrollOffset
      }
  
      innerNavigation.style.transform = 'translateX(-' + newScrollOffset + 'px)';
      component.set('v.scrollOffset', newScrollOffset);
      helper.checkPaddleState(component);
    }
})