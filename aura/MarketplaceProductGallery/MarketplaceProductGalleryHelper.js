({

	movePrev: function(component) {
		var animating = 	component.get('v.animating');
		if (!animating) {
			this.moveSlide(component, 'prev');
			this.slidesResetOffset(component);
		}
	},
	moveNext: function(component) {
		var animating = 	component.get('v.animating');
		var length = component.get('v.count');
		var currentIndex = 	parseFloat(component.get('v.currentIndex'));
		var newIndex;
		var _this = this;

		if (!animating) {
			// If there is only 2 items, the slides need to be switch so it moves right smoothly
			if (length < 3) {
				window.setTimeout(function(){
						_this.slidesPrepNext(component);
				}, 1);

				newIndex = currentIndex < length - 1 ? currentIndex + 1 : 0;
				this.delayedMoveSlide(component, newIndex, 1, function(){
					_this.slidesResetOffset(component);
				});

			} else {
				this.moveSlide(component, 'next');
				_this.slidesResetOffset(component);
			}
		}
	},

	stopVideos: function(component) {
		var videos = component.find('video');
		if (videos && videos.length) {
			videos.forEach(function(cmp) {
				cmp.getElement().pause();
			});
		}
	},

	// Resets slide in the order that the last goes before the current indexes
	// Pauses animation so that the visual doesn't get affected
	// 									 0 1 2 3 4 5
	// currentIndex == 0 [0,1,2,3,4,-1] 	currentIndex == 1 [-1,0,1,2,3,4]  	currentIndex == 2 [4,-1,0,1,2,3] 	currentIndex == 3 [3,4,-1,0,1,2] 	currentIndex == 4 [2,3,4,-1,0,1] 	currentIndex == 5 [1,2,3,4,-1,0]

	slidesResetOffset: function(component, timeout) {
		// Reset Slides next For infinitite display
		var currentIndex = 	parseFloat(component.get('v.currentIndex'));

		var offsetIndex = 	parseFloat(component.get('v.offsetIndex'));
		var carouselItems =  component.find('media-item');
		var length = component.get('v.count');

		var innerCarousel =  component.find('inner-carousel');
		var newOrder;
		var idxDif;
		var carouselItem;
		var mediaOverlay = component.find('media-overlay');

		var timeout = timeout ? timeout: 800;

		window.setTimeout(function(){
			// don't animate order/carousel shift
			$A.util.addClass(mediaOverlay, 'noanimate');
            if(carouselItems && carouselItems.length>1){
                offsetIndex = 1; // put back index to 1
                
            }else{
                offsetIndex = 0;
            }   
            component.set('v.offsetIndex', offsetIndex);
			// set initial margin left;
			innerCarousel.getElement().style.transition = 'none';
			innerCarousel.getElement().style.transform = 'translateX('+ (-100 * offsetIndex)+'%)';
			// new arrangement
            if(carouselItems && carouselItems.length>1){
                carouselItems.forEach(function(elem,idx) {
                    carouselItem = elem.getElement();
    
                    idxDif = idx - currentIndex;
    
                    if (idxDif == length -1) { //last should be -1
                        newOrder = -1;
                    } else if (idxDif >= -1) {
                        newOrder = idxDif;
                    } else if (idxDif < -1) {
                        newOrder = length + idxDif;
                    }
                    carouselItem.style.order = newOrder;
                });
            }
			// Delay needed otherwise the noanimate will be debounced
			window.setTimeout(function(){
				innerCarousel.getElement().style.transition = '';
				$A.util.removeClass(mediaOverlay, 'noanimate');
				component.set('v.animating', false);
			}, 20);


		}, timeout);

	},

	// Resets the slide in the index order, 0,1,2,3,4,5
	// Then we adjust the left so it goes to the next component or previous component
	slidesResetStart: function(component, index) {

		var currentIndex = component.get('v.currentIndex');
		var offsetIndex = 	parseFloat(component.get('v.offsetIndex'));
		var carouselItems =  component.find('media-item');
		var length = component.get('v.count');
		var innerCarousel =  component.find('inner-carousel');
		var order;
		var carouselItem;
		var mediaOverlay = component.find('media-overlay');

		// don't animate order/carousel shift
		$A.util.addClass(mediaOverlay, 'noanimate');


		// innerCarousel.getElement().style.transition = 'none';
		offsetIndex = currentIndex; // put back index towhatever the index is1
		component.set('v.offsetIndex', offsetIndex);
        if(carouselItems && carouselItems.length>1){
            carouselItems.forEach(function(elem,idx){
                carouselItem = elem.getElement();
                carouselItem.style.order = idx;
                // console.log(idx);
            });
        }else{
            carouselItem = carouselItems.getElement();
            carouselItem.style.order = 0;
        }    
		innerCarousel.getElement().style.transition = 'none';
		innerCarousel.getElement().style.transform = 'translateX('+ (-100 * offsetIndex)+'%)';

		// Delay needed otherwise the noanimate will be debounced
		window.setTimeout(function(){
			innerCarousel.getElement().style.transition = '';
			$A.util.removeClass(mediaOverlay, 'noanimate');
		}, 20);


	},
	// Helper used for next slides and there are only 2 slidesPrepNext
	// Put current slide as order = and next slide as order 1, then marginLeft = 0
	slidesPrepNext: function(component, index) {

		var currentIndex = component.get('v.currentIndex');

		var offsetIndex = 	parseFloat(component.get('v.offsetIndex'));
		var carouselItems =  component.find('media-item');
		var length = component.get('v.count');

		var innerCarousel =  component.find('inner-carousel');
		var order;
		var carouselItem;
		var mediaOverlay = component.find('media-overlay');

		// don't animate order/carousel shift
		$A.util.addClass(mediaOverlay, 'noanimate');

		offsetIndex = 0; // put back index towhatever the index is1
		component.set('v.offsetIndex', offsetIndex);
        if(carouselItems && carouselItems.length>1){
            carouselItems.forEach(function(elem,idx){
                carouselItem = elem.getElement();
                if (currentIndex == idx) {
                    carouselItem.style.order = 0;
                } else {
                    carouselItem.style.order = 1;
                }
            });
        }else{
            carouselItem = carouselItems.getElement();
            carouselItem.style.order = 0;
        }    
		innerCarousel.getElement().style.transition = 'none';
		innerCarousel.getElement().style.transform = 'translateX(0%)';
		//Timeout Needed since Lightning debounces the add class/remove class
		window.setTimeout(function(){
			innerCarousel.getElement().style.transition = '';
			$A.util.removeClass(mediaOverlay, 'noanimate');
		}, 20);
	},
	moveSlide: function(component, dir) {
		// Reset Slides next For infinitite display
		var currentIndex = 	parseFloat(component.get('v.currentIndex'));
		var offsetIndex = 	parseFloat(component.get('v.offsetIndex'));

		var innerCarousel =  component.find('inner-carousel');
		var length = component.get('v.count');
		var newIndex ;

 		component.set('v.animating', true);

		if (dir === 'next') {
			newIndex = currentIndex < length - 1 ? currentIndex + 1 : 0;
			offsetIndex = offsetIndex + 1;
		} else {
			newIndex = currentIndex <= 0 ? length - 1 : currentIndex - 1;
			offsetIndex = offsetIndex - 1;
		}
		// console.log('moveSlide=>' + dir, newIndex, 'offsetIndex['+offsetIndex+']');

		innerCarousel.getElement().style.transform = 'translateX('+ (-100 * offsetIndex)+'%)';

		component.set('v.offsetIndex', offsetIndex);
		component.set('v.currentIndex', parseInt(newIndex));

	},
	delayedMoveSlide: function(component, newIndex, newoffsetIndex, callBack) {
		// Reset Slides next For infinitite display
		var innerCarousel =  component.find('inner-carousel');
		var _this = this;

		window.setTimeout(function(){
			innerCarousel.getElement().style.transform = 'translateX('+ (-100 * newoffsetIndex)+'%)';
			component.set('v.offsetIndex', newoffsetIndex);
			component.set('v.currentIndex', parseInt(newIndex));
			if (typeof callBack == 'function') {
				callBack();
			}
		}, 40);
	}

})