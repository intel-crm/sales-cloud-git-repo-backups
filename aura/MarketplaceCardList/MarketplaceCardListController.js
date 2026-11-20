({
	/*doInit : function(component, event, helper) {
       // console.log('resultattributes****= '+component.get('v.results'));
        
		window.setTimeout(
			 $A.getCallback(function() {
					if(component.isValid()) {
						$A.enqueueAction(component.get('c.handleMinContentHeight'));
				 	}
			 }), 200
 		);

	  window.addEventListener('resize', $A.getCallback(function(){
	      if(component.isValid()) {
					$A.enqueueAction(component.get('c.handleMinContentHeight'));
	      }
	  }));
		
		var debounceIndex = false;
		component.set('v.onImageLoaded', $A.getCallback(function(){
      if(component.isValid()) {
				window.clearTimeout(debounceIndex);
				debounceIndex = window.setTimeout($A.getCallback(function() {
					$A.enqueueAction(component.get('c.handleMinContentHeight'));
				}), 50);
      }
	  }));
        
	},
	handleOnRender: function(component, event, helper) {
		$A.enqueueAction(component.get('c.handleMinContentHeight'));
	},
                                                        
	handleDisplayTypeChange: function(component, event, helper) {
		window.setTimeout(
			 $A.getCallback(function() {
					 $A.enqueueAction(component.get('c.handleMinContentHeight'));
			 }), 200
	 );
	},
	handleResultsChange : function(component, event, helper) {
		var results = component.get('v.results');
		if(results && results.length){
			window.setTimeout(
				 $A.getCallback(function() {
						 $A.enqueueAction(component.get('c.handleMinContentHeight'));
				 }), 500
		 );
 		}

	},

	handleMinContentHeight: function(component) {
		var cards = component.find('card');

		var getHeight = function(elem, id){
			var itemWrap, newHeight, oldMinHeight;

			itemWrap = elem.getConcreteComponent().find(id);
			newHeight = 0;
			if (itemWrap){
					oldMinHeight =  itemWrap.getElement().style.minHeight;
					itemWrap.getElement().style.minHeight = '';
					newHeight = itemWrap.getElement().offsetHeight;
					itemWrap.getElement().style.minHeight = oldMinHeight;
			}
			return newHeight;
		}

		var heightList = cards.map(function(elem){ return getHeight(elem, 'itemWrap2'); });
		var minHeight = Math.max.apply(null, heightList);
	 	component.set("v.minHeight", minHeight);

  	var buttonHeightList =  cards.map(function(elem){ return getHeight(elem, 'buttonFooter'); });
	  var minButton = Math.max.apply(null, buttonHeightList);
		component.set("v.buttonFooterminHeight", minButton);

	},*/
	handleDisplayList: function(component, event, helper) {
		helper.dispatch(component, 'toggleDisplayType',
			'list'
		);
	},

	handleDisplayCard: function(component, event, helper) {
		helper.dispatch(component, 'toggleDisplayType',
			'card'
		);
	}


})