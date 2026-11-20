({
	setAttributes : function(component) {
    var findAccordionSections = function(cmp) {
			var body = cmp.get('v.body');

      return body ? body.reduce(function(list, c) {
        var accordionSections = [];
        if (!c.getName) {
          accordionSections = findAccordionSections(c);
        } else if (c.getName() == 'cMarketplaceAccordionSection') {
          accordionSections = [c];
        }
        return list.concat(accordionSections);
      }, []) : [];
    }

    var sections = findAccordionSections(component);

    sections.forEach(function(cmp) {
			if (!component.get('v.allowMultipleSectionsOpen') && component.get('v.activeSectionName')){
      	cmp.set('v.open', cmp.get('v.name') == component.get('v.activeSectionName'));
			}
    });

    sections.forEach(function(cmp) {
      cmp.set('v.ontoggle', function(name, isOpen) {
        component.set('v.activeSectionName', isOpen ? name : '');
        if (isOpen && !component.get('v.allowMultipleSectionsOpen')) {
          sections.forEach(function(c) {
            if (cmp != c) c.set('v.open', false);
          });
        }
      });
    });
	}
})