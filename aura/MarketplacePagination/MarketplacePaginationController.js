({
     doInit : function(component, event, helper) {
    	console.log(component.get('v.rangeFirst')+'-'+ component.get('v.rangeLast') +'-'+ component.get('v.currentPage') 
                    +'-'+ component.get('v.totalPages') +'-'+ component.get('v.totalResults'));
		
  },
	handlePageInput : function(component, event, helper) {
    var page = parseInt(event.currentTarget.value);
		helper.pageChange(component, page);
  },

  handlePrevPage : function(component, event, helper) {
		console.log('handlePrevPage');

		var totalPages = component.get('v.totalPages');
		var currentPage = component.get('v.currentPage');
		var onPageChange = component.get('v.onPageChange');
		currentPage = currentPage > 1 ? currentPage - 1 : currentPage;

		if (typeof onPageChange === 'function') {
			onPageChange(currentPage);
		}
  },

  handleNextPage : function(component, event, helper) {

		var totalPages = component.get('v.totalPages');
		var currentPage = component.get('v.currentPage');
		var onPageChange = component.get('v.onPageChange');
		currentPage = currentPage < totalPages ? currentPage + 1 : currentPage;

		// console.log('handleNextPage', currentPage, onPageChange);

		if (typeof onPageChange === 'function') {
			onPageChange(currentPage);
		}
  },
	handleKeyDown: function(component, event, helper) {
    var keyPress = event.which;
		var page = parseInt(event.currentTarget.value);
    if (keyPress == 13) {
			helper.pageChange(component, page);
    }

  },
   
})