({
    doInit : function(component, event, helper) {
        var displayType = component.get('v.displayType');
        helper.getPartnerPrograms(component);
        var partnerCategories = {
            //title: 'Intel Partner Directory',
            //subtitle: 'Discover and make valuable connections with Intel Partners and partner communities.',
            
            //CTA: 'View All Partners',
            //CTAUrl: '/search'
        }
        
        if (displayType == 'home' || displayType == 'partner' )
        {
            component.set('v.viewAllLabel', $A.get("$Label.c.PMP_L1_Search_Bar_View_All_Partners"));
            component.set('v.viewAllSearchParams', { type: 'partner' });
            
        } 
        
        

        //component.set('v.title', partnerCategories.title);
        component.set('v.title',$A.get("$Label.c.PMP_L2_Marquee_Partner_Heading"));
        component.set('v.subtitle',$A.get("$Label.c.PMP_Intel_MP_Partners_subtitle"));
        //component.set('v.subtitle', partnerCategories.subtitle);
        //component.set('v.CTA', partnerCategories.CTA);
        component.set('v.CTA', $A.get("$Label.c.PMP_Partner_Directory_View_All_Partners"));
        //component.set('v.CTAUrl', partnerCategories.CTAUrl);
            
    }
})

/*listing: [
                { 
                    label: 'Intel IOT Solutions Alliance',
                    page: 'search',
                    searchParams: { type: 'partner', cat: 'ISA'  },
                    imgUrl: 'https://intel--nppdevpmp--c.cs67.content.force.com/servlet/servlet.ImageServer?id=0150n000000EqY6&oid=00D0n000000D3l9&lastMod=1561439619000'
                },
                { 
                    label: 'Intel Cloud Insider Program',
                    page: 'search',
                    searchParams: { type: 'partner', cat: 'CSPx2'  },
                    imgUrl: 'https://intel--nppdevpmp--c.cs67.content.force.com/servlet/servlet.ImageServer?id=0150n000000EqYB&oid=00D0n000000D3l9&lastMod=1561351084000'
                },
                { 
                    label: 'Intel ODM-LOEM',
                    page: 'search',
                    searchParams: { type: 'partner', cat: 'ODM-LOEM' },
                    imgUrl: 'https://intel--nppdevpmp--c.cs67.content.force.com/servlet/servlet.ImageServer?id=0150n000000EqYQ&oid=00D0n000000D3l9&lastMod=1561351209000'
                },
            ],*/