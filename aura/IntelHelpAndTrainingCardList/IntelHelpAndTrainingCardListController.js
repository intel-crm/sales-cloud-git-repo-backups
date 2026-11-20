({
    doInit : function(component, event, helper) {
        //component.set('v.loading', true);

        var mockCategories = {
            title: 'Help & Training For You',
            //subtitle: 'Discover and make valuable connections with Intel Partners and partner communities.',
            listing: [
                { label: 'Create a new offering', page: 'l2', imgUrl: 'https://via.placeholder.com/47/1e2e43/FFFFFF', description: 'Find out how to get started and how the process works', descriptionLinkText: 'Watch the Video', descriptionLink:'https://www.youtube.com/watch?v=5DsyfLvpr9Q&feature=youtu.be', descriptionLinkTarget: '_blank'},
                { label: 'Manage Your Offerings', page: 'l2', imgUrl: 'https://via.placeholder.com/47/1e2e43/FFFFFF', description: 'Know how to filter views and learn about the editing process for offerings you submit', descriptionLinkText: 'View PDF', descriptionLink:'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', descriptionLinkTarget: '_blank'},
                { label: 'Translation Help', page: 'l2', imgUrl: 'https://via.placeholder.com/47/1e2e43/FFFFFF', description: 'Understand the process to create language translations for your storefront', descriptionLinkText: 'Watch the Video', descriptionLink:'https://www.youtube.com/watch?v=5DsyfLvpr9Q&feature=youtu.be', descriptionLinkTarget: '_blank'},
                { label: 'Get Insights', page: 'l2', imgUrl: 'https://via.placeholder.com/47/1e2e43/FFFFFF', description: 'Learn about how you can use your dashboard to optimize your storefront', descriptionLinkText: 'Watch the Video', descriptionLink:'https://www.youtube.com/watch?v=5DsyfLvpr9Q&feature=youtu.be', descriptionLinkTarget: '_blank'},
                { label: 'Get and Manage Leads', page: 'l2', imgUrl: 'https://via.placeholder.com/47/1e2e43/FFFFFF', description: 'Best practices to optimize your storefront and how to take advantage of leads', descriptionLinkText: 'View PDF', descriptionLink:'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', descriptionLinkTarget: '_blank'}
            ],
            CTA: 'All marketplace help',
            CTAUrl: '/l2'
        }

        component.set('v.listing', mockCategories.listing);
        component.set('v.title', mockCategories.title);
        component.set('v.subtitle', mockCategories.subtitle);
        component.set('v.CTA', mockCategories.CTA);
        component.set('v.CTAUrl', mockCategories.CTAUrl);
    }
})