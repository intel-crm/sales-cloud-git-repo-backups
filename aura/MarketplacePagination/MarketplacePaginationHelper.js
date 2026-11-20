({
	pageChange : function(component, page) {
		var totalPages = component.get('v.totalPages');
		var onPageChange = component.get('v.onPageChange');
		page = Number.isInteger(page) ? parseInt(page) : page;

		if (!Number.isInteger(page) || page < 1 || page > totalPages) page = 1;

		console.log('pageChange', page , !Number.isInteger(page),page < 1, page > totalPages , totalPages);

		if (typeof onPageChange === 'function') {
			onPageChange(page);
		}

	}
})