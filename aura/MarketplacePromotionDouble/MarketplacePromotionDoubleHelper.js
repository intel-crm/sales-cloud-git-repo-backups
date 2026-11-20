({

	resetHeight : function(component) {
		var height = 0, cards = [].concat(component.find('card'));
		cards.forEach(function(card) {
			card.getElement().style.height = '';
		});
		if (window.innerWidth >= 768) {
			cards.forEach(function(card) {
			   if (card.getElement().offsetHeight > height) height = card.getElement().offsetHeight;
			});
			cards.forEach(function(card) {
				card.getElement().style.height = height + 'px';
			});
		}
	},

  addScreenSizeChangeHandler : function(component, helper) {
    var onResize = $A.getCallback(function() {
      if(component.isValid()) {
        window.setTimeout($A.getCallback(function() {
          helper.resetHeight(component);
        }));
      } else {
        window.removeEventListener('resize', onResize);
      }
    });
	  window.addEventListener('resize', onResize);
  }

})