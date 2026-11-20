({
    
    getFeaturedProducts : function(component, helper) {
        var action = component.get("c.someControllerMethod");
        action.setParams(params);
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var featuredProducts = returnValue;
                component.set('v.featuredProducts', featuredProducts);
                component.set('v.displayCardAttributes', window.innerWidth < 768);
                component.set('v.displayByPartner', window.innerWidth < 768);
                helper.resetPages(component);
                // make sure the height is the same for all cards
                // helper.resetHeight(component);
                // set the correct carousel position
                helper.resetCarouselPosition(component, 0);
                component.set('v.loading', false);
                
            } else if (status === "INCOMPLETE") {
                // do something?
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error(errors[0].message);
                    };
                }
            } else {
                this.reject('Unknown error.');
            }
        });
      //  $A.enqueueAction(action);
    },
    
    changePage : function(component, helper, page) {
        component.set('v.currentPage', parseInt(page));
        helper.resetCarouselPosition(component, parseInt(page) - 1);
	//new changes (12-Oct-2019)
    window.setTimeout(function(){
      helper.updateRenderIndex(component, helper);
    },450);
    },
  updateRenderIndex: function(component, helper) {
    var renderIndex = component.get('v.renderIndex');
    var perPage = component.get('v.perPage');
    var currentPage = component.get('v.currentPage');
    var newRenderIndex = currentPage * perPage;
    var idx = component.get('v.index');
    // add +1 on mobile and tablet bp because of peek
    if (window.innerWidth < 1024) {
      newRenderIndex++;
    }

    if (renderIndex < newRenderIndex) {
      component.set('v.renderIndex', newRenderIndex);
      // helper.lazyRenderOtherItems(component, helper);
    }
  },
  /* Optional to render other items once paging starts */
  lazyRenderOtherItems: function(component, helper) {
    var renderIndex = component.get('v.renderIndex');
    var perPage = component.get('v.perPage');
    var maxItems = component.get('v.numberOfPages') * perPage;
    var newRenderIndex = renderIndex + perPage;
    var lazyLoadTimer = component.get('v.lazyLoadingTimer');
    var idx = component.get('v.index');

    newRenderIndex = newRenderIndex > maxItems ? maxItems : newRenderIndex;

    window.clearTimeout(lazyLoadTimer);

    if (newRenderIndex && renderIndex != newRenderIndex){
      // run a timer
      var lazyLoaderTimer = window.setTimeout(function(){
        component.set('v.renderIndex', newRenderIndex);
        helper.lazyRenderOtherItems(component, helper);
      }, 1500);
      component.set('v.lazyLoaderTimer', lazyLoadTimer);
    }
    

  },
//new changes end
    // resetHeight : function(component) {
    // var cards = component.find('card');
    // if (cards && cards.length) {
    // 	var height = 0;
    //   cards.forEach(function(card) {
    // 		card.getElement().style.height = '';
    // 	});
    // 	cards.forEach(function(card) {
    // 	   if (card.getElement().offsetHeight > height) height = card.getElement().offsetHeight;
    // 	});
    // 	cards.forEach(function(card) {
    // 		card.getElement().style.height = height + 'px';
    // 	});
    // }
    // },
    
    resetCarousel : function(component, helper) {
        // set Number of Pages here based on breakpoint value
        // NOTE the breakpoint here can be different than overall site breakpoint (768px)
        // 
        var perPage = 1;
        if (window.innerWidth >= 768) {
            perPage = 2;
        }
        if (window.innerWidth >= 1024) {
            perPage = 4;
        }
        var currentPerPage = parseInt(component.get('v.perPage'));
        if (perPage != currentPerPage) {
            // blurs all bubbles -- page might change
            var carouselBubbles = component.find('carouselBubble');
            if (carouselBubbles) {
                [].concat(carouselBubbles).forEach(function(cmp, idx) {
                    cmp.getElement().blur();
                });
            }
            // sets per page
            component.set('v.perPage', perPage);
            helper.resetPages(component);
            var currentPage = component.get('v.currentPage') || 1;
            var newPage = Math.ceil((((currentPage - 1) * (currentPerPage || 1)) + 1) / perPage);
            helper.changePage(component, helper, newPage);
        }
    },
    
    resetCarouselPosition : function(component, page) {
        var transform, perPage = component.get('v.perPage');
        // mobile (adds offset to show siblings)
        if (perPage == 1 || perPage == 2) {
            transform = -(100 * (10/12) * page) + (100/12);
        } else {
            // desktop
            transform = -100 * page;
        }
        transform = 'translateX(' + transform + '%)';
        component.find('carousel-position').getElement().style.transform = transform;
        var carouselBubbles = component.find('carouselBubble');
        
        if (carouselBubbles && carouselBubbles.getElement) {
           var cb = [].concat(carouselBubbles)[page]
           if(cb.getElement()){
               cb.getElement().focus();
           }
        }
    },
    
    resetPages : function(component) {
        var featuredProducts = component.get('v.featuredProducts');
        
        var numberOfPages = Math.ceil(featuredProducts.length / component.get('v.perPage'));
        var pages = []; // used for iterating page bubbles
        for (var i = 1; i <= numberOfPages; i++) pages.push(i);
        component.set('v.pages', pages);
        component.set('v.numberOfPages', numberOfPages);
    },
    
    addScreenSizeChangeHandler : function(component, helper) {
        var onResize = $A.getCallback(function() {
            if(component.isValid()) {
                // helper.resetHeight(component);
                helper.resetCarousel(component, helper);
            } else {
                window.removeEventListener(onResize);
            }
        });
        window.addEventListener('resize', onResize);
        
  },
  
  performanceLog: function(component, helper) {
    var idx = component.get('v.index');
    console.time('PERF-CarouselInitialRender-' + idx);
    window.setTimeout(function () {
      console.timeEnd('PERF-CarouselInitialRender-'+ idx);
    })

  }
  
  
    
})