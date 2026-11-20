({
	doInit : function(component, event, helper) {

		// +++ mock data && mock server call
		var product = {
			type:'product',
			"title":"VueForge™ Creating Value From Machine-Driven Big Data 1",
			"partner": {"name":"ADLINK","imageUrl":null,"id":"a3z0n0000003sHBAAY","description":null,"contactByForm":false,"contactByEmail":true,"attributes":null},
			"imageUrl":"https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Product",
			"id":"a3s0n0000009sxqAAA",
			"description":"<p>VueForge comprises Altran’s all-industry, packaged end-to-end solutions in the fields of connectivity, embedded systems, safety and security, information technologies, Big Data (including Hadoop and Cassandra), analytics, and innovation management.</p>",
			"attributes":[
				{ "name":"Category","types":[{"name":"Software – Operating System","id":null,"searchParams":{type: 'product'}}]},
				{"name":"Industry","types":[{"name":"Banking","id":null},{"name":"Automotive","id":null},{"name":"Communications","id":null}]}
			]
		};
		var product2 = Object.assign({}, product, { description: 'This is a much shorter description...',
			attributes:[
				{"name":"Category","types":[{"name":"Software – Application","id":null,"searchParams":{type: 'product'}}]},
				{"name":"Industry","types":[{"name":"Banking","id":null},{"name":"Automotive","id":null},{"name":"Communications","id":null}]},
				{"name":"Application","types":[{"name":"Application 1","id":null},{"name":"Application 2","id":null},{"name":"Application 3","id":null}]}
			]
		});
		var featuredProducts = [product, product, product2, product, product, product2];

    // +++ mock server call to get featured products
    window.setTimeout($A.getCallback(function() {
      component.set('v.featuredProducts', featuredProducts);

    }), 2000);
	},

})