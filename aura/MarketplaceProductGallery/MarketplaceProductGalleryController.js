({
	doInit : function(component, event, helper) {
		/*
		 *Gireesh:US387913: Change default prefixURL to display image in lightning tab 
		 */
        /*var match = window.location.href.match(/.*Admin_Review(.*)/);		
        // set record ID		
        if (match) {		
            component.set("v.prefixUrl","/sfc/servlet.shepherd/version/download/");		
        } */
        //if(!component.get('v.prefixUrl').includes($A.get("$Label.c.PMP_CommunityURLSuffix"))){
            component.set("v.prefixUrl",'/'+component.get('v.prefixUrl'));
            

        //}
        
        // set after render
		if (component.get('v.galleryData') && component.get('v.galleryData').length) {
			window.setTimeout(
			    $A.getCallback(
			        function() {
									var carousel = component.find('carousel');
									var innerCarousel =  component.find('inner-carousel');
									var carouselItems =  component.find('media-item');
									var length, carouselItem;
									if (carouselItems){
										length = carouselItems.length;
										carouselItem;
										// innerCarousel.getElement().style.marginLeft = -1 * width + 'px';
										innerCarousel.getElement().style.transform = 'translateX(-100%)';
                                        if(length && length>1){
                                            carouselItems.forEach(function(elem,idx){
                                                carouselItem = elem.getElement();
                                                carouselItem.style.order = (idx === length -1) ? -1 : idx;
                                            })
                                        }/*else{
                                            carouselItem = carouselItems.getElement();
                                            carouselItem.style.order = 0;
                                        }*/
                                        
										component.set('v.offsetIndex', 1);
										component.set('v.currentIndex', 0);

										//component.set('v.count', carouselItems.length);
										window.setTimeout(function(){
											$A.util.removeClass(carousel, 'noanimate');
										}, 200);

										var originX = false;
										var referenceMargin = 0;

										function touchStart(e){
											var touchObj = e.changedTouches[0];
											originX = touchObj.pageX;
										}
										function touchEnd(e) {
											var touchObj = e.changedTouches[0];
											var diff = originX - touchObj.pageX;
											if (diff > 150) {
												helper.moveNext(component);
											} else if (diff < -150) {
												helper.movePrev(component);
											}
										}

										carousel.getElement().addEventListener("touchstart", touchStart, false);
										carousel.getElement().addEventListener("touchend", touchEnd, false);
									}

			        }
			    )
			, 1);
		}
		// touch device render
		var isTouchDevice = (('ontouchstart' in window) || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));
		component.set('v.touchDevice', isTouchDevice);
	},
	handleKeyDown : function(component, event, helper) {
		var keyPress = event.which;
		// console.log('handle key down', keyPress);
		if (keyPress === 37) {
			// left
			helper.movePrev(component);
			helper.stopVideos(component);
		} else if (keyPress === 39) {
			// right
			helper.moveNext(component);
			helper.stopVideos(component);
		}

	},
	handleNextButton : function(component, event, helper) {
		helper.moveNext(component);
		helper.stopVideos(component);
		event.preventDefault();
	},
	handlePrevButton : function(component, event, helper) {
		helper.movePrev(component);
		helper.stopVideos(component);
		event.preventDefault();
	},
	handleToggleOverlay : function(component, event, helper) {
        component.set("v.showPanel", true);
		var modalOpen = component.get("v.modalOpen");
		var overlay = component.find('media-overlay');
		var modalBackground = component.find('modal-background');

		modalOpen = !modalOpen;
		component.set("v.modalOpen", modalOpen);
        component.set('v.offsetIndex', 0);
        component.set('v.offsetIndex', 0);
        $A.util.removeClass(overlay, 'slds-hide');
			$A.util.removeClass(modalBackground, 'slds-hide');
			window.setTimeout(
				 $A.getCallback(function() {
						 $A.util.addClass(overlay, 'slds-show');
						 $A.util.addClass(modalBackground, 'slds-show');
						 // Fous on theoverlay
						// document.querySelector('.product-media-gallery .jumpList a.selected').focus();

				 }), 5
		 );

		if (modalOpen) {
			$A.util.removeClass(overlay, 'slds-hide');
			$A.util.removeClass(modalBackground, 'slds-hide');
			window.setTimeout(
				 $A.getCallback(function() {
						 $A.util.addClass(overlay, 'slds-show');
						 $A.util.addClass(modalBackground, 'slds-show');
						 // Fous on theoverlay
						// document.querySelector('.product-media-gallery .jumpList a.selected').focus();

				 }), 5
		 );
		} else {
			$A.util.removeClass(overlay, 'slds-show');
			$A.util.removeClass(modalBackground, 'slds-show');

			window.setTimeout(
				 $A.getCallback(function() {
					 $A.util.addClass(overlay, 'slds-hide');
					 $A.util.addClass(modalBackground, 'slds-hide');
				 }), 700
		 );
		}
        
        if(component.get('v.galleryData').length===1){
            window.setTimeout(function(){
                    helper.slidesResetStart(component);
            }, 1);
        }
        
		event.preventDefault();
        
		helper.stopVideos(component);
        
	},

	handleGoTo: function(component, event, helper) {
		var nextIndex = event.currentTarget.dataset.index;
		helper.stopVideos(component);
		component.set('v.animating', true);
		// Reset order to Default 0 - 5
		// not adding the timeout will not add the class no-animate
		window.setTimeout(function(){
				helper.slidesResetStart(component);
		}, 1);

		helper.delayedMoveSlide(component, nextIndex, nextIndex, function(){
			helper.slidesResetOffset(component);
		});
		event.preventDefault();
	}

})