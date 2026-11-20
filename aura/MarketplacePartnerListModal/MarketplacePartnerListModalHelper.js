({
	groupTags : function(component, helper) {
		console.log('group tags');
		var tags = component.get('v.tags');
		if (tags.length){
			var tagGroups = [
                {
					id:'symbol',
					label: 'Ω',
					regex: /^[^a-z0-9].?/i, 
					tags:[],
					separator: '|',
				},
                {
				id:'num',
				label: '#',
				regex: /^[\d].?/i,
				tags:[]
                }]; //Added as part of code Merge -[9/20] previous code: no symbol tags(Line# 7-13) are present - Manjula
			var letters = 'abcdefghijklmnopqrstuvwxyz';
			var letter;
			// add letters
			for (var i = 0; i < letters.length; i++) {
  			letter = letters.charAt(i);
				tagGroups.push({
					id: letter,
					label: letter.toUpperCase(),
					regex: new RegExp('^['+letter+'].?', 'i'),
					tags: []
				})
			}
			tags.forEach(function(item){
				for (var i = 0, i_l = tagGroups.length; i < i_l; i++) {
						if (tagGroups[i].regex.test(item.label)){
							tagGroups[i].tags.push(item);
							break;
						}
				}
			});
			component.set('v.tagGrouping', tagGroups);
		}
	}
})