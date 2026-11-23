@isTest private class PMP_SearchWrapperStore_Test extends PMP_SearchWrapperStore{
    
    @isTest static void allWrappers_Test(){
        Category cat = new PMP_SearchWrapperStore.Category();
        cat.categoryDescription = '';
        cat.categoryId = '';
        cat.categoryName = '';
        cat.categoryType = '';
        cat.children = new List<Category>();
        cat.count = 0;
        cat.categoryCtaLink = '';
        cat.parentId = '';
        System.assert(cat != null);
        
        CategorySearchResponse catSearch = new CategorySearchResponse();
        catSearch.keyword = '';
        catSearch.allMarketplaceCount = 0;
        catSearch.allPartnerCount = 0;
        catSearch.allProductCount = 0;
        catSearch.partnerCategories = new List<Category>();
        catSearch.productCategories = new List<Category>();
        catSearch.filters = new List<Filter>();
        System.assert(catSearch != null);
        
        SearchRequest sr = new SearchRequest();
        sr.keyword = '';
        sr.category = '';
        sr.searchType ='';
        sr.sortField ='';
        sr.sortDirection ='';
        sr.selectedFilters = new Map<String, List<String>>();
        sr.currentPage =0;
        sr.pageSize =0;
        System.assert(sr != null);
        
        Attribute att = new Attribute();
        att.id ='';
        att.name ='';
        att.types = new List<Types>();
        att.typeGroupings = new List<TypeGroup>();
        att.textBlock ='';
        att.secondTierCat = true;
        att.isEditable = true;
        att.editButton = new EditButton();      
        att.search = new SearchParams();
        System.assert(att != null);
        
        
        EditButton eb = new EditButton();
        eb.currentStep = 1;
        System.assert(eb != null);
        
        TypeGroup tg = new TypeGroup();
        tg.name ='';
        tg.types = new List<Types>();
        System.assert(tg != null);
        
        Types typ = new Types();
        typ.id ='';
        typ.name ='';
        typ.link ='';
        typ.ancestor ='';
        typ.secondTierCat =true;
        typ.searchParams =new SearchParams();
        typ.parentId = '';
        typ.ancestorId = '';
        System.assert(typ != null);
        
        Product product = new Product();
        product.type ='';
        product.id ='';
        product.imageUrl ='';
        product.description ='';
        product.title ='';
        product.partner =new Partner();
        product.attributes = new List<Attribute>();
        product.featured =true;
        product.isContactPartnerVisible  =true;
        product.isGuest  =true;
        product.prerelease = true;
        product.prerelaseText = '';
        product.onlyVisibleToIntel = true;
        System.assert(product != null);
        
        Partner partner = new Partner();
        partner.type ='';
        partner.id ='';
        partner.imageUrl ='';
        partner.description ='';
        partner.name ='';
        partner.contactByEmail = true;
        partner.contactByForm = true;
        partner.attributes = new List<Attribute>();
        partner.isContactPartnerVisible = true;
        partner.leadLangPreference ='';
        partner.search =new SearchParams();
        partner.isGuest =true;
        partner.autoPartnerId = '';
        System.assert(partner != null);
        
        Tag tag = new Tag();
        tag.label ='';
        tag.count = 3;
        tag.value ='';
        tag.parent ='';
        tag.children = new List<Tag>();
        tag.pimId = '';
        System.assert(tag != null);
        
        Filter filter = new Filter();
        filter.type ='';
        filter.name ='';
        filter.label ='';
        filter.tags =new List<Tag>();
        filter.count =5;
        filter.showClearLink = FALSE;
        filter.autoexpand = FALSE;
        System.assert(filter != null);
        
        SearchResponse searchResponse=new SearchResponse();
        searchResponse.keyword ='';
        searchResponse.category ='';
        searchResponse.searchType ='';
        searchResponse.sortField ='';
        searchResponse.sortDirection ='';
        searchResponse.currentPage =2;
        searchResponse.pageSize =1;
        searchResponse.totalCount =1;
        searchResponse.productResults =new List<Product>();
        searchResponse.partnerResults =new List<Partner>();
        searchResponse.filters =new List<Filter>();
        searchResponse.suggestions =new List<String>();
        searchResponse.totalProductCount = 0;
        searchResponse.totalPartnerCount = 0;
        searchResponse.searchHeading = '';
        searchResponse.categoryDescription = '';
        System.assert(searchResponse != null);
        
        AutoCompleteOption atc = new AutoCompleteOption();
        
        atc.category = new Category();
        atc.keyword ='';
        atc.label ='';
        atc.searchType ='';
        atc.recordId =null;
        System.assert(atc != null);
        
        Mobile mob = new Mobile();
        mob.label ='';
        mob.link ='';
        mob.imgUrl ='';
        System.assert(mob != null);
        
        FeaturedProductTab featuredProductTab = new FeaturedProductTab();
        featuredProductTab.categoryId = '';
        featuredProductTab.label ='';
        featuredProductTab.searchParams =new SearchParams();
        featuredProductTab.products = new List<Product>();
        featuredProductTab.ctaTitle ='';
        featuredProductTab.featuredPdt =true;
        System.assert(featuredProductTab != null);
        
        PartnerDetail partnerDetail =  new PartnerDetail();     
        partnerDetail.id='';
        partnerDetail.name ='';
        partnerDetail.tagline ='';
        partnerDetail.introSection ='';
        partnerDetail.moreSection ='';
        partnerDetail.promotion =new List<Promotion>();
        partnerDetail.categories =new List<CategoryTab>();
        partnerDetail.companyResources = new List<PartnerResource>(); 
        partnerDetail.mobileList =new List<Mobile>();
        partnerDetail.partnerDetails = new Partner();
        partnerDetail.currentStatus  ='';
        partnerDetail.isUpdateRequired  =true;
        partnerDetail.statusUpdateDate  ='';
        partnerDetail.initialUpdateDate  ='';
        partnerDetail.isSamePartnerUser  =true;
        partnerDetail.hasAccess  =true;
        partnerDetail.isGuest  =true;
        partnerDetail.manageOfferingAccess =true; 
        partnerDetail.isContactPartnerVisible =true; 
        partnerDetail.hasLeadGenAccess  =true;
        partnerDetail.isLeadGenLimited  =true;
        partnerDetail.leadSettings  =new LeadGenSettings();
        partnerDetail.mdaId =''; 
        partnerDetail.isIntelAdmin = true;
        partnerDetail.leadLangPreference = '';
        System.assert(partnerDetail != null);
        
        CategoryTab categoryTab = new CategoryTab();
        categoryTab.label  ='';
        categoryTab.viewAllLabel =''; 
        categoryTab.viewAllLinkUrl  ='';
        categoryTab.iconUrl  ='';
        categoryTab.count  =2;
        categoryTab.entries =new List<Product>(); 
        categoryTab.searchParams  =new SearchParams();
        System.assert(categoryTab != null);
        
        PartnerResource partnerRes = new PartnerResource();
        partnerRes.title  ='';
        partnerRes.linkUrl  ='';
        partnerRes.type  ='';
        partnerRes.openInNewTab =true; 
        System.assert(partnerRes != null);
        
        Promotion promotion = new Promotion();
        promotion.imageUrl  ='';
        promotion.imagePosition  ='';
        promotion.title  ='';
        promotion.body  ='';
        promotion.ctaLink  ='';
        promotion.ctaLabel  ='';
        System.assert(promotion != null);
        
        Listing listing = new Listing();
        listing.label  ='';
        listing.imgUrl  ='';
        listing.description  ='';
        listing.descriptionLink  ='';
        listing.descriptionLinkText  ='';
        listing.descriptionLinkTarget  ='';
        listing.page  ='';
        listing.searchParams =new SearchParams();
        listing.searchType  =new SearchType();
        System.assert(listing != null);
        
        SearchParams searchParams = new SearchParams();
        searchParams.cat ='';
        searchParams.q  ='';
        searchParams.page ='';
        searchParams.type ='';
        searchParams.dir  ='';
        searchParams.field ='';
        searchParams.selectedFilters =new Map<String,List<String>>();
        System.assert(searchParams != null);
        
        SearchType searchType = new SearchType();
        searchType.type  ='';
        System.assert(searchType != null);
        
        UserDetails userD= new UserDetails();
        userD.firstName  ='';
        userD.lastName  ='';
        userD.jobTitle  ='';
        userD.companyName  ='';
        userD.country  ='';
        userD.state  ='';
        userD.phone  ='';
        userD.email   ='';
        userD.volume  =null;
        userD.description  ='';
        userD.deliveryDate  =null;
        userD.offeringURL  ='';
        userD.leadSource  ='';
        userD.sfdcCampaignID  ='';
        userD.leadConversionPoint  ='';
        userD.marketingTacticID  ='';
        userD.sourceID  ='';
        userD.partnerProgramSegment ='';
        userD.sessionId = '';
        System.assert(userD != null);
        
        
        FormDataSaveRequest form = new FormDataSaveRequest();
        form.descriptionData  =null;
        form.regionOptions  =null;
        form.regionsSelected  =null;
        form.applicationsSelected =null;
        form.industriesSelected =null;
        form.resources =null;
        form.status  ='';
        form.admin ='';   
        System.assert(form != null);
        
        FormData formData = new FormData();
        formData.isLocked =null; 
        formData.logoCheck  =null;
        formData.logo   =null;
        formData.workingCopyId  =null;
        formData.descriptionData =null; 
        formData.regionOptions  =null;
        formData.regionsSelected  =null;
        formData.resourceData  =null;
        formData.industryOptions  =null;
        formData.industriesSelected  =null;
        formData.applicationOptions  =null;
        formData.applicationsSelected  =null;
        formData.currentStatus  ='';
        formData.submittedBy  ='';
        formData.submittedOn  ='';
        formData.admin  ='';
        formData.adminList =null; 
        formData.statusList  =null;
        System.assert(formData != null);
        
        Resource resource = new Resource();
        resource.title  ='';
        resource.type  ='';
        resource.url  ='';
        System.assert(resource != null);
        
        ImageWrapper imageWrapper = new ImageWrapper();
        imageWrapper.id =''; 
        imageWrapper.url  ='';
        imageWrapper.title  ='';
        imageWrapper.size  =0;
        System.assert(imageWrapper != null);
        
        Logo logo = new Logo();
        logo.src  ='';
        logo.filename  ='';
        logo.filesize  ='';
        System.assert(logo != null);
        
        DescriptionData desd = new DescriptionData();
        desd.language =''; 
        desd.tagline  ='';
        desd.description  ='';
        desd.languageOptions =new List<Options>(); 
        desd.languageDisabled  =true;
        System.assert(desd != null);
        
        
        ResourceData rsd = new ResourceData();
        rsd.resourceTypes =new List<Options>(); 
        rsd.resources =new List<Resource>();
        System.assert(rsd != null);
        
        Options opts = new Options();
        opts.label =''; 
        opts.value  ='';
        opts.selected  =true;
        System.assert(opts != null);
        
        Option opt = new Option();
        opt.label =''; 
        opt.value  ='';
        opt.children =new List<Option>(); 
        opt.options  =new List<Option>();
        opt.isCategory = true;
        opt.isPartnerProgram = true;
        System.assert(opt != null);
        
        ArticleData ad = new ArticleData();
        ad.viewAllLabel  ='';
        ad.articleList =new List<Article>(); 
        System.assert(ad != null);
        
        Article at = new Article();
        at.title  ='';
        at.link  ='';
        at.publishedDate =''; 
        System.assert(at != null);
        
        
        LanguagePreference lp = new LanguagePreference();
        lp.label  ='';
        lp.value  ='';
        lp.selected  =true;
        System.assert(lp != null);
        
        LeadGenSettings ls = new LeadGenSettings();
        ls.enableLeadGeneration  =true;
        ls.limitToPartners  =true;
        ls.languagePreference =new List<Options>();  
        System.assert(ls != null); 
        
        MdaInfo md = new MdaInfo();
        md.mdaId  ='';
        md.businessSegment  ='';
        System.assert(md != null);
        
        BreadCrumb bc = new BreadCrumb();
        bc.label = '';
        bc.page = '';
        bc.searchParams = new SearchParams();
        System.assert(bc != null);
        
    }
    
}