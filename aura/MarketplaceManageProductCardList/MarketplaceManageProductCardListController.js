({
    doInit : function(component, event, helper) {
        //component.set('v.loading', true);

        var mockCategories = {
            title: 'Help & Training Materials',
            //subtitle: 'See ways our partners are leveraging Intel technology - to benefit your business.',
            listing: [
                { label: 'How to Manage Leads', link: '/l2', imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Lorem ipsum dolor', link: '/l2', imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Lorem ipsum dolor', link: '/l2', imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Lorem ipsum dolor', link: '/l2', imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'},
                { label: 'Lorem ipsum dolor', link: '/l2', imgUrl: 'https://via.placeholder.com/50/0071C5/FFFFFF'}
            ],
            //CTA: 'View All Offerings',
            //CTAUrl: '#'
        }

        component.set('v.listing', mockCategories.listing);
        component.set('v.title', mockCategories.title);
        component.set('v.subtitle', mockCategories.subtitle);
        component.set('v.CTA', mockCategories.CTA);
        component.set('v.CTAUrl', mockCategories.CTAUrl);
    },
    handleClick : function(component, event, helper) {
        event.preventDefault();
        var currentIndex = event.currentTarget.dataset.index;

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get('v.CTAUrl')
        });
        urlEvent.fire();
    }
})