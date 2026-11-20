({
    doInit : function(component, event, helper) {
		// +++ mock data && mock server call
		var product = {
			type:'product',
			"title":"Activematrix BusinessWorks",
			"partner": {"name":"ADLINK","imageUrl":null,"id":"a3z0n0000003sHBAAY","description":null,"contactByForm":false,"contactByEmail":true,"attributes":null},
			"imageUrl":"https://via.placeholder.com/350x197/555555/FFFFFF?text=Product",
			"id":"a3s0n0000009sxqAAA",
			"description":"<p>VueForge comprises Altran’s all-industry, packaged end-to-end solutions in the fields of connectivity, embedded systems, safety and security, information technologies, Big Data (including Hadoop and Cassandra), analytics, and innovation management.</p>",
			"featured": false,
			"prerelease": false,
			"onlyVisibleToIntel": false,
			"prerelaseText": "This item will be available xx,2019",
			"attributes":[
				{
					"name":"Category",
					"displayOnly": 'mobile' //,mobile,desktop,''
				,"types":[{"name":"Software","id":null}]},
				{"name":"Category","types":[{"name":"Software","id":null,"searchParams":{
					//cat: 'categoryId',
					type: 'product'
				}}, {"name":"Solution","id":null,"searchParams":{
					//cat: 'categoryId',
					type: 'product'
				}}]},
				{"name":"Industry","types":[{"name":"Banking","id":null},{"name":"Automotive","id":null},{"name":"Communications","id":null}]},
				{"name":"Application","types":[{"name":"Application 1","id":null},{"name":"Application 2","id":null},{"name":"Application 3","id":null}]}
			]
		};
		var partner = {
				type: 'partner',
				id: '11111',
				contactByEmail: true,
				contactByForm: true,
				description: 'Partner Description Integer tempor vehicula egestaas. In metus vitae sem lacinia euismod vel sed nulla nNullam ac metus eleifend nibh dapibus dignissim',
				imageUrl: 'https://via.placeholder.com/350x197/555555/FFFFFF?text=Partner',
				name: 'Tibco',
				attributes: [
							{	name: 'Program Membership',
									types: [{
										id: 'ISA',
										name: 'IOT Solutions Alliance',
										link: '#intel Technology Provider'
									}
								]
							},
							{	name: 'Specialties',
							displayOnly: '', // desktop, mobile, blank
							types: [
							{
								id: '1',
								name: 'Cloud',
								link: '#Cloud'
							},
							{
								id: '2',
								name: 'IoT',
								link: '#IoT'
							},
							{
								id: '3',
								name: 'Education',
								link: '#Education'
							}
						]
					}
				]
			};

			//Different product card variation examples
			var product2 = Object.assign({}, product, { id:"a3s0n0000009sxqAAB", description: '<ul bullet-list’ class=‘specs><li>Processor 1, Processor 2<li>Storage<li>I/O Port<li>Dimension<li>Wireless</ul>'});
			var product3 = Object.assign({}, product, { onlyVisibleToIntel: true, featured: false, prerelease: true});
			var product4 = Object.assign({}, product, { featured: true, prerelease: false});
			var product5 = Object.assign({}, product, { onlyVisibleToIntel: true, featured: true, prerelease: true});
			var product6 = Object.assign({}, product, { onlyVisibleToIntel: false});
			var product7 = Object.assign({}, product, { id:"a3s0n0000009sxqAAC", description: '<ul bullet-list’ class=‘specs><li>Processor 1, Processor 2<li>Storage<li>I/O Port<li>Dimension<li>Wireless</ul>'});

			//Setting products for mock data
			var featuredProducts1 = [partner, product2, product, product4, product3, product5, product6, product7];
			var featuredProducts2 = [partner, product2, product5, product];

    	// +++ mock server call to get featured products
			window.setTimeout($A.getCallback(function() {
				component.set('v.featuredProductsTab1', featuredProducts1);
				component.set('v.featuredProductsTab2', featuredProducts2);
				//component.set('v.featuredProductsTab3', featuredProducts3);
			}), 2000);

    },
    handleDisplayList: function(component, event, helper) {
				component.set('v.listDisplayType', 'list');
      },
		handleDisplayCard: function(component, event, helper) {
				component.set('v.listDisplayType', 'card');
      },
})