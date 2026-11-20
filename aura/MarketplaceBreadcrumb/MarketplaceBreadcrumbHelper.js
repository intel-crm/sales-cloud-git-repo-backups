({

	resetUrls : function(component, helper) {
		var data = component.get('v.breadcrumbData');
    var dataPromises = data.map(function(item) {
      return new Promise(function(resolve, reject) {
        // Function reworked to support multiple types MGDANIES 10-29
         if (item.page) {
			var type = item.type || 'comm__namedPage';
            var searchParams = '';
            if (item.searchParams) {
                searchParams = '?search=' + encodeURIComponent(JSON.stringify(item.searchParams));
            }
            var pageReference = {
                type: type
            };
            
            if (type === 'comm__namedPage') {
                pageReference.attributes = {
                    pageName: item.page
                }
            } else {
                pageReference.attributes = item.attributes;
            }
            
          var navService = component.find("navService");
          if (navService) {
            navService
              .generateUrl(pageReference)
              .then(function(url) {
                resolve(url ? url + searchParams : "#");
              })
              .catch(function(error) {
                resolve("#");
              });
          } else {
            resolve("#");
          }
        } else {
          resolve(item.url);
        }
      });
    });

    Promise.all(dataPromises)
      .then(
        $A.getCallback(function(urls) {
          var newData = data.map(function(item, idx) {
            return Object.assign({}, item, { url: urls[idx] });
          });
          component.set("v.bcData", newData);
        })
      )
      .catch(function(e) {
        // NOTE: There is some error showing up with the component.set() above
        // It is very unclear as to why, and doesn't seem to affect the value at all?
      });
  }
})