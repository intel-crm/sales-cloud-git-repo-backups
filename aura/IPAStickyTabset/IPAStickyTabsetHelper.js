({
  getAllTabs: function(component) {
    var findTabs = function(cmp) {
      return cmp.get("v.body").reduce(function(list, c) {
        var tabs = [];
        if (!c.getName) {
          tabs = findTabs(c);
        } else if (c.getName() == "cIPAStickyTab") {
          tabs = c;
        }
        return list.concat(tabs);
      }, []);
    };
    return findTabs(component);
  },

  recalculateElementsOffset: function(component, event, helper) {
    if (component.isValid()) {
      // component offset
      var stickySectionContainer = component.find("stickyTabContainer");
      var containerOffset = helper.calculateOffset(
        stickySectionContainer.getElement()
      );
      component.set("v.containerOffsetTop", containerOffset.top);
      component.set("v.containerOffsetBottom", containerOffset.bottom);

      // Calculate offset of tab sections
      var allTabs = component.get("v.allTabs");
      var tabsOffset = [];
      allTabs.forEach(function(tab, idx) {
        tabsOffset.push(helper.calculateOffset(tab.getElement()).top);
      });
      component.set("v.tabsOffset", tabsOffset);
    }
  },

  calculateOffset: function(element) {
    var rect = element.getBoundingClientRect(),
      scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    return { top: rect.top + scrollTop, bottom: rect.bottom + scrollTop };
  },

  setTabs: function(component, helper) {
    var allTabs = this.getAllTabs(component);
    var allTabLabels = [];

    allTabs.forEach(function(tab, index) {
      allTabLabels.push(tab.get("v.label"));
      tab.set("v.anchorId", "StickyTab" + index);
    });

    component.set("v.allTabs", allTabs);
    component.set("v.allTabLabels", allTabLabels);
  },

  selectTab: function(component, helper, index) {
    component.set("v.currentTabIndex", index);

    // if (typeof onActive === 'function' && index > -1) {
    // 	onActive(component, index);
    // }
  },
  // Taken from Tabset Helper
  addScreenSizeChangeHandler: function(component, helper) {
    if (!component.get("v.screenResizeHandler")) {
      component.set("v.screenResizeHandler", true);
      window.addEventListener(
        "resize",
        $A.getCallback(function() {
          if (component.isValid()) {
            // reset to 0 translate for screensize
            helper.recalculateElementsOffset(component, event, helper);

            var innerNavigation = component
              .find("inner-link-list")
              .getElement();
            if (innerNavigation) {
              innerNavigation.style.transform = "translateX(-" + 0 + "px)";
              component.set("v.scrollOffset", 0);
              helper.checkPaddleState(component);
            }
          } else {
            // remove listener
          }
        })
      );
    }
  },

  checkPaddleState: function(component) {
    if (component.find("inner-link-list")) {
      var innerNavigation = component.find("inner-link-list").getElement();
      var scrollOffset = component.get("v.scrollOffset");
      var navWidth = innerNavigation.scrollWidth;
      var pageWidth = window.innerWidth;
      var prevVisible = scrollOffset > 0;
      var nextVisible = scrollOffset < navWidth - pageWidth;
      // no scroll needed
      if (pageWidth === navWidth) {
        prevVisible = false;
        nextVisible = false;
      }
      component.set("v.paddlePrevVisible", prevVisible);
      component.set("v.paddleNextVisible", nextVisible);
    }
  }
});