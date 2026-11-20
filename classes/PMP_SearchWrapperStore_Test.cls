@isTest private class PMP_SearchWrapperStore_Test extends PMP_SearchWrapperStore{
    
    @isTest static void allWrappers_Test() {
        Test.startTest();
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
        
        OffSpecWrapper ofspecwra = new OffSpecWrapper();
        ofspecwra.localSpecName = '';
        ofspecwra.localSpecValueName = '';
        ofspecwra.specificationId = '';
        ofspecwra.ancestorId = '';
        System.assert(ofspecwra != null);
        
        OffCatWrapper offcawra = new OffCatWrapper();
        offcawra.localName = '';
        offcawra.ancestorId = '';
        //offcawra.compareTo = 0;
        System.assert(offcawra != null);
        
        media mediaobj = new media();
        mediaobj.accountId = '';
        mediaobj.videoId = '';
        mediaobj.title = '';
        mediaobj.videoType = '';
        mediaobj.thumbnailUrl = '';
        mediaobj.imageUrl = '';
        mediaobj.videoThumbnailUrl = '';
        mediaobj.description = '';
        mediaobj.altText = '';
        mediaobj.placeholder1920px = '';
        mediaobj.placeholder246px = '';
        System.assert(mediaobj != null);
        
        contentAssetWrapper conaswra = new contentAssetWrapper();
        conaswra.type = '';
        conaswra.thumbnailUrl = '';
        conaswra.imageUrl = '';
        System.assert(conaswra != null);
        
        CategorySearchResponse catSearch = new CategorySearchResponse();
        catSearch.keyword = '';
        catSearch.allMarketplaceCount = 0;
        catSearch.allPartnerCount = 0;
        catSearch.allProductCount = 0;
        catSearch.partnerCategories = new List<Category>();
        catSearch.productCategories = new List<Category>();
        catSearch.filters = new List<Filter>();
        catSearch.selectedFilters= new Map<String, List<String>>();
        catSearch.langCode='';
        catSearch.searchType='';
        catSearch.category='';
        catSearch.tagListId='';
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
        sr.filters=new Map<String, List<String>>();
        sr.page=0;
        sr.sortType='';
        
        sr.specialty='';
        sr.langCode='';
        sr.contextualCat='';
        sr.tagListId='';
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
        att.title ='';
        att.sections = new List<sections>();
        att.displayInModal = true;
        att.displaySectionsInModal = true;
        att.modalButtonLabel ='';
        att.modalTitleLabel = '';
        System.assert(att != null);
        
        
        EditButton eb = new EditButton();
        eb.currentStep = 1;
        System.assert(eb != null);
        
        TypeGroup tg = new TypeGroup();
        tg.name ='';
        tg.isDistributor=true;
        tg.types = new List<Types>();
        System.assert(tg != null);
        
        Types typ = new Types();
        typ.id ='';
        typ.name ='';
        typ.englishName = '';
        typ.link ='';
        typ.ancestor ='';
        typ.tier ='';
        typ.filterId='';
        typ.secondTierCat =true;
        typ.searchParams =new SearchParams();
        typ.parentId = '';
        typ.ancestorId = '';
        typ.parentName = '';
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
        product.cardType='';
        product.partnerAttributes=new List<Attribute>();
        product.partnerId='';
        product.partnerName='';
        product.partnerRole='';
        product.partnerStatus='';
        product.name='';
        product.partnerByLine='';
        product.eyebrowTagline='';
        product.eyebrow=true;
        product.longDescription='';
        product.leadLangPreference='';
        product.autoOffId='';
        product.compareCategoryId='';
        product.categories= new List<String>();
        product.contactPartnerVisible =true;
        product.categoryL3 =new CategoryLevel();
        product.categoryL2 =new List<CategoryLevel>();
        product.categoryL3 =new CategoryLevel();
        product.categoryL1 =new  CategoryLevel();
        
        /*@AuraEnabled public String cardType { get; set; }
        @AuraEnabled public List<Attribute> partnerAttributes { get; set; }
        @AuraEnabled public String partnerId { get; set; }
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String partnerRole { get; set; }
        @AuraEnabled public String partnerStatus { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String partnerByLine { get; set; }
        @AuraEnabled public String eyebrowTagline {get;set;}
        @AuraEnabled public Boolean eyebrow {get;set;}
        @AuraEnabled public String longDescription { get; set; }*/
        System.assert(product != null);
        
        
        CategoryLevel cl = new CategoryLevel();
        cl.Id ='';
        cl.Name='';
        
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
        partner.byline ='';
        partner.eyebrow=true;
        partner.contactPartnerVisible=true;
        partner.benefitType='';
        partner.eyebrowTagline ='';
        
        partner.tierStatus ='';
        partner.longDescription ='';
        partner.partnerRole ='';
        partner.partnerId ='';
        partner.partnerName ='';
        partner.partnerByLine ='';
        partner.partnerStatus ='';
        partner.role ='';
         partner.status ='';
        partner.partnerSpecialties= new List<String>();
         partner.productCategories= new List<String>();
        partner.Bizorgtype ='';
         partner.URL ='';
        partner.specialties= new List<Specialty>();
        
       
       
        
        /* @AuraEnabled public String tierStatus { get; set; }
       // @AuraEnabled public String specialties { get; set; }
       // @AuraEnabled public List<Specialties> specialties { get; set; }
        @AuraEnabled public String longDescription { get; set; }
        @AuraEnabled public String partnerRole { get; set; }
        @AuraEnabled public String partnerId { get; set; }
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String partnerByLine { get; set; }
        @AuraEnabled public String partnerStatus { get; set; }
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public List<String> partnerSpecialties { get; set; }
        @AuraEnabled public List<String> productCategories { get; set; }
        //Added as part of 2.0 changes for disti card
        @AuraEnabled public String Bizorgtype { get; set; }
        @AuraEnabled public String URL { get; set; }
        @AuraEnabled public List<Specialty> specialties { get; set; }
            */
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
        searchResponse.resultsPerPage=0;
        searchResponse.totalResults=0;
        searchResponse.totalPages=0;
        searchResponse.results=new List<PMP_SearchPartnerController.Partner>();
        searchResponse.resultCounts= new Map<String, Integer>();
        searchResponse.learMoreLink='';
        searchResponse.selectedFilters=new Map<String, List<String>>();
        
        
        
        /* @AuraEnabled public List<PMP_SearchPartnerController.Partner> results {get; set;} //TBD to change type to cards
        @AuraEnabled public Map<String, Integer> resultCounts {get; set;}
        @AuraEnabled public Integer resultsPerPage {get; set;}
        @AuraEnabled public Integer totalResults {get; set;}
        @AuraEnabled public Integer totalPages {get; set;}
 @AuraEnabled public String learMoreLink { get; set; } //Added by Megha as part of Specialty learnMoreLink
        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }*/
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
        mob.page='';
        mob.searchParams= new SearchParams();
        /* @AuraEnabled public String page {get; set;}
        @AuraEnabled public SearchParams searchParams {get; set;}*/
        System.assert(mob != null);
        
        FeaturedProductTab featuredProductTab = new FeaturedProductTab();
        featuredProductTab.categoryId = '';
        featuredProductTab.label ='';
        featuredProductTab.searchParams =new SearchParams();
        featuredProductTab.products = new List<Product>();
        featuredProductTab.ctaTitle ='';
        featuredProductTab.featuredPdt =true;
        featuredProductTab.heading ='';
        featuredProductTab.ctaLabel ='';
        featuredProductTab.eventTitle ='';
        featuredProductTab.cards =new  List<Product>();
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
       // partnerDetail.manageOfferingAccess =true; 
        partnerDetail.isContactPartnerVisible =true; 
        partnerDetail.hasLeadGenAccess  =true;
        partnerDetail.isLeadGenLimited  =true;
        partnerDetail.leadSettings  =new LeadGenSettings();
        partnerDetail.mdaId =''; 
        partnerDetail.isIntelAdmin = true;
        partnerDetail.leadLangPreference = '';
        partnerDetail.partnerDescription  ='';
        partnerDetail.publishedStatus  ='';
        partnerDetail.partnerType  ='';
        partnerDetail.publishedDate  ='';
        partnerDetail.showMoreSection  =true;
        partnerDetail.showCompanyResourceAndArticle  =true;
        partnerDetail.showCompanyResourceAndArticleforEnhanced  =true;
        partnerDetail.isMarkettingSpecialist  =true;
        partnerDetail.isPartnerAdmin  =true;
        partnerDetail.showEnhancedPopup  =true;
        //partnerDetail.isOfferingEditor  =true;
        partnerDetail.isLdrOeEmployee  =true;
        partnerDetail.partnerShortDescription='';
        partnerDetail.isEventRelated=true;
        partnerDetail.website='';
        partnerDetail.specialties= new List<Specialties>();
        partnerDetail.tierStatus='';
        partnerDetail.isDistributor = true;
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
        promotion.searchParams=new searchParams();
        promotion.promotionName ='';
        promotion.eventScreenReader='';
        
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
        listing.isIcon=true;
        System.assert(listing != null);
        
        SearchParams searchParams = new SearchParams();
        searchParams.cat ='';
        searchParams.q  ='';
        searchParams.page ='';
        searchParams.type ='';
        searchParams.dir  ='';
        searchParams.field ='';
        searchParams.selectedFilters =new Map<String,List<String>>();
        searchParams.contextualCat =true;
        searchParams.specialty ='';
        searchParams.reg ='';
        searchParams.recordId ='';
        searchParams.objectApiName ='';
        searchParams.PartnerProgram ='';
        
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
       // userD.offeringURL  ='';
        userD.leadSource  ='';
        userD.sfdcCampaignID  ='';
        userD.leadConversionPoint  ='';
        userD.marketingTacticID  ='';
        userD.sourceID  ='';
        userD.partnerProgramSegment ='';
        userD.sessionId = '';
        userD.profession='';
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
        form.suppressEmail = true;
        form.partner= new PartnerWrapper();
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
        formData.partnerNames= new List<Options>();
        formData.partner= new PartnerWrapper();
        formData.isDistributor=true;
        formData.isPublishedCopyDraft=true;
        formData.isEnhanced = true;
        formData.webaddwrap =new Map<string,partnerWrapper>();
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
        opt.checked = false;
        opt.children =new List<Option>(); 
        opt.options  =new List<Option>();
        opt.isCategory = true;
        opt.isPartnerProgram = true;
        opt.checked=true;
        System.assert(opt != null);
        
        ArticleData ad = new ArticleData();
        ad.viewAllLabel  ='';
        ad.articleList =new List<Article>(); 
        System.assert(ad != null);
        
        Article at = new Article();
        at.title  ='';
        at.link  ='';
        at.publishedDate =''; 
        at.description  ='';
        at.createdDate  ='';
        at.createdAt =''; 
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
        bc.getURL = '';
        bc.target = '';
        bc.url = '';
        bc.searchParams = new SearchParams();
        bc.id = '';
        bc.text = '';
        bc.cancelEvent = true;
        bc.useCallback = true;
        bc.selected = true;
        bc.children= new List<BreadCrumb>();
        bc.data= new BreadCrumbData();
        bc.parentId='';
        System.assert(bc != null);
        
        Specialty sp = new Specialty();
        sp.title = '';
        sp.icon = '';
        sp.sfIcon = '';
        sp.svgIcon='';
        sp.iconImgUrl ='';
        
        AutoCompleteOptionForPartnerAndOffering aco=new AutoCompleteOptionForPartnerAndOffering();
        aco.partnerOptions= new List<AutoCompleteOption>();
       // aco.offeringOptions= new List<AutoCompleteOption>();
        System.assert(aco != null);
       
      
        SeoCat seocategory=new SeoCat();
        seocategory.Name='';
        seocategory.Id='';
        seocategory.categoryLevel=0;
        seocategory.url='';
        seocategory.objectApiName='';
         System.assert(seocategory != null);
       
       
        PartnerWrapper pw=new PartnerWrapper();
        pw.name='';
        pw.website='';
        pw.primaryStreet='';
        pw.secondaryStreet='';
        pw.city='';
        pw.country='';
        pw.state='';
        pw.postalCode='';
        pw.description='';
        System.assert(pw != null);
       
        
        TaxonomyRecord tr=new TaxonomyRecord();
        tr.id='';
        tr.parentId='';
        tr.label='';
        tr.englishLabel = '';
        tr.children=new List<String>();
        tr.description='';
        tr.svgIconUrl='';
        tr.viewAllLabel='';
        tr.taxonomy='';
        tr.featured=true;
        tr.prerelease = false;
        tr.searchResultsGroupings=new List<SearchResultsGrouping>();
        tr.defaultFilters=new Map<String, List<String>>();
        tr.prerelease=true;
        tr.learnMoreUrl='';
        tr.showCountryWarning=true;
        tr.isIntelEmployee = true;
        System.assert(tr != null);
       
        
        Taxonomy taxonomy= new Taxonomy();
        taxonomy.name='';
        taxonomy.apiName='';
        taxonomy.label='';
        taxonomy.englishLabel = '';
        taxonomy.viewAllLabel='';
        taxonomy.svgIconUrl='';
        taxonomy.filterDisplayType='';
        taxonomy.topLevelIds=new List<String>();
        taxonomy.records=new Map<String,TaxonomyRecord>();
        taxonomy.searchFiltersGroupings=new List<SearchFiltersGrouping>();
        taxonomy.description='';
        taxonomy.expandByDefault=true;
        System.assert(taxonomy != null);
       
        SearchFiltersGrouping sfg=new SearchFiltersGrouping();
        sfg.label='';
        sfg.englishLabel = '';
        sfg.filters= new List<String>();
        System.assert(sfg != null);
        
        SearchResultsGrouping srg=new SearchResultsGrouping();
        srg.name='';
        srg.heading='';
        srg.subheading='';
        System.assert(srg != null);
       
        BreadCrumbData bcd= new BreadCrumbData();
        bcd.type='';
        bcd.attributes= new BreadCrumbAttribute();
        System.assert(bcd != null);
        
        
        BreadCrumbAttribute bcAttr= new BreadCrumbAttribute();
        bcAttr.url='';
        bcAttr.pageName='';
        bcAttr.objectApiName='';
        bcAttr.actionName='';
        bcAttr.recordId='';
        System.assert(bcAttr != null);
        
        CampaignEvents camAttr = new CampaignEvents();
        camAttr.cardType = '';
        camAttr.campaignId ='';
        camAttr.partnerTotal = 0;
        camAttr.productTotal =0;
        camAttr.name ='';
        camAttr.description = '';  
        camAttr.externalUrl ='';
        camAttr.image = '';
        camAttr.title = '';
        camAttr.linkLabel ='';
        camAttr.linkUrl ='';
        camAttr.partnerCards = new List<PMP_SearchPartnerController.Partner>();     
        //camAttr.productCards =  new List<PMP_SearchProductController.Product>(); 
        camAttr.imageAlt='';
        camAttr.isInvalidEvent=true;
        System.assert(camAttr != null);
        
        TaxonomyParams Tp = new TaxonomyParams();
        Tp.langCode='';
        Tp.baseTaxonomy=true;
        System.assert(Tp != null);
        
        
        CardData cd =new CardData();
        cd.cardType='';
        cd.id='';
        cd.title='';
        cd.tagline='';
        cd.description='';
        cd.imageUrl='';
        cd.imageAlt='';
        cd.featured=true;
        cd.createdDate='';
        cd.externalUrl='';
         System.assert(cd != null);
        
        
        FilterStructure fs =new FilterStructure();
        fs.id ='';
        fs.filterName='';
        fs.label='';
        fs.children =new Set<String>();
        //fs.relatedOfferings =new Set<String>();
         System.assert(fs != null);
        
        
        
        
        /* OfferingResourceWrapper Orw=new  OfferingResourceWrapper();
           orw.id='';
        orw.title='';
        orw.description='';
        orw.url='';
        orw.resourceType='';
        orw.uploadId='';
        orw.fileType ='';
        orw.fileSize='';
        orw.downloadUrl='';
        orw.uploadName ='';
        System.assert(orw != null);
        
        OfferingResourceType ort=new OfferingResourceType();
        ort.label='';
        ort.value='';
        System.assert(ort!=null);*/
        
        /*StorefrontFeedItem sf= new StorefrontFeedItem();
        sf.cardData='';
        sf.filterStructure='';
        sf.filterData='';
        sf.totalItems=1;*/
        
        Specialties spec= new Specialties();
        spec.name='Test';
        spec.Image='Image';
        System.assert(spec!=null);
        
        FilterData filData = new FilterData();
        filData.id ='';
        filData.label ='';
        filData.children = new set<String>();
        filData.parent='';
        filData.count=0;
       // filData.relatedOfferings =new set<String>();
        System.assert(filData!=null);
       
        StorefrontFeedItem sf= new StorefrontFeedItem();
        sf.cardData=new List<CardData>();
        sf.filterStructure=new List<FilterStructure>();
        sf.filterData=new Map<Id,FilterData>();
        sf.totalItems=1;
        System.assert(sf!=null);
        
        
        /*StorefrontFeedItem sf= new StorefrontFeedItem();
        sf.cardData=new List<CardData>();
        sf.filterStructure=new List<FilterStructure>();
        sf.filterData=new Map<Id,FilterData>();
        sf.totalItems=1;
        System.assert(sf!=null);*/
		
        
        RefineFilterTaxonomy refineTaxonomy= new RefineFilterTaxonomy();
        refineTaxonomy.name='';
        refineTaxonomy.apiName='';
        refineTaxonomy.label='test';
        refineTaxonomy.englishLabel='';
        refineTaxonomy.pimId='';
        refineTaxonomy.records=new map<string,RefineFilterTaxonomyRecord>();
        
        System.assert(refineTaxonomy!=null);
        
        RefineFilterTaxonomyRecord refineTaxonomyRec= new RefineFilterTaxonomyRecord();
        refineTaxonomyRec.Id='';
        refineTaxonomyRec.parentId='';
        refineTaxonomyRec.label='';
        refineTaxonomyRec.englishLabel='';
        refineTaxonomyRec.objectname='';
        refineTaxonomyRec.filtertaxonomy='';
        System.assert(refineTaxonomyRec!=null);
        
        
        Test.stopTest();
        
    }
    
}