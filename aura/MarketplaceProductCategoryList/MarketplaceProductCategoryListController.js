({
    doInit : function(component, event, helper) {
        //component.set('v.loading', true);
		helper.getCategories(component);
        
        /*var mockCategories = {
            title: 'Product Categories', 
            subtitle: '',
            listing: [
                { label: 'Components', page: 'search',searchParams: {cat:'a3p0n0000009zBqAAI', type: 'product' }, imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Services', page: 'search',searchParams: {cat:'a3p0n0000009zCkAAI', type: 'product' }, imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Solutions', page: 'search', searchParams: {cat:'a3p0n0000009zCeAAI', type: 'product' }, imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Software', page: 'search', searchParams: { cat:'a3p0n0000009zD0AAI' , type: 'product' }, imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Systems', page: 'search',searchParams: { cat:'a3p0n0000009zDQAAY' , type: 'product' }, imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'}
            ],
            CTA: 'View All Products',
            CTAUrl: '/products'
        }*/
		//console.log('--------------'+component.get("v.listing"));
        //component.set('v.listing', mockCategories.listing);
         
        //component.set('v.title', 'Product Categories');
        component.set('v.title', $A.get("$Label.c.PMP_Intel_Partner_Products_By_Category"));
        //component.set('v.subtitle', '');
        component.set('v.subtitle', $A.get("$Label.c.PMP_Subheading"));
        //component.set('v.CTA', $A.get("$Label.c.PMP_View_All_Products"));
        // IPA2.0 + US TWC4497-1631
        // component.set('v.CTA', $A.get("$Label.c.PMP_View_All_Offerings"));
        
/*        
        if (component.get('v.displayType')=='Home'){
            component.set('v.CTAUrl', '/search');
            //component.set('v.CTAUrl', '/offerings');
        }
            
        else
            component.set('v.viewAllSearchParams', { type: 'product' });
*/      
// IPA2.0 + US TWC4497-1631
        // if (component.get('v.displayType')=='home'){
        //     component.set('v.CTAUrl', '/offerings');
        //     debugger;
		// 	//console.log('v.displayType = ',v.displayType);
		// 	//console.log('v.CTAUrl = ',v.CTAUrl);            
        // } else 
        // {
            component.set('v.viewAllSearchParams', { type: 'product' });
            //console.log('v.viewAllSearchParams = ',v.viewAllSearchParamse);
        // }
    },
        
})