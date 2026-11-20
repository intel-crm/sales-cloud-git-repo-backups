/* eslint-disable camelcase */
// import getOfferingDetail from '@salesforce/apex/PMP_OfferingDetailsController.getOfferingDetail';
// import getOfferingDetailWorkingCopy from '@salesforce/apex/PMP_OfferingDetailsController.getOfferingDetailProductDetails';
// import getMarqueeProductInformation from '@salesforce/apex/PMP_SearchMarqueeDetailController.getProductInformation';
// import industriesLabel from '@salesforce/label/c.Core_PMP_Industries';
// import availabilitypricingLabel from '@salesforce/label/c.PMP_Availability_and_Pricing';
// import applicationsLabel from '@salesforce/label/c.Core_PMP_Applications';
// import regionLabel from '@salesforce/label/c.Core_Regions';

// import langLocale from '@salesforce/i18n/lang'; //en-US where $A.get("$Locale.langLocale"); returns en_US

// import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// import PMP_Image from '@salesforce/label/c.PMP_Image';
// import PMP_Thumbnail_Image from '@salesforce/label/c.PMP_Thumbnail_Image';
// import PMP_Category from '@salesforce/label/c.PMP_Category';

// import notificationBannerExtractor from './_notificationBanner';
// import galleryImageExtractor from './_galleryImages';
// import categoriesExtractor from './_categories';
// import specificationsExtractor from './_specifications';
// import qualityMetricsExtractor from './_qualityMetrics';
// import partnerAttributesExtractor from './_partnerAttributes';
// // Placeholder Images
// const placeholder1x1 = `${CoreResource}/images/standard-placeholder-1x1.png`;

// /** backend data call for getOfferingDetails
//  *
//  * @param {string} offeringId id for offering
//  * @returns {Promise} promise with all the data for the offering detail page
//  */
export default async function getOfferingDetailsBackend({ offeringId, Preview }) {
  /*
  console.log('getOfferingDetailsBackend ~ Preview', Preview);
  if(!Preview) {
   Preview = false;
 }
 console.log('getOfferingDetailsBackend ~ Preview False', Preview);
  let langCode = langLocale;
  if(langLocale.includes('-')){
    langCode = langLocale.replaceAll('-','_');
  }
  let language = '';
  let query = window.location.search.substr(1);
//added by krishna for offering translations.
  if(query.includes('Lang=')){
    let item = query.split("Lang=");
    language = !item ? 'NA' : item[1]; 
    if(language && language.includes("&"))
    {
      let temp = language.split("&");
      language = !temp ? 'NA' : temp[0];
  
    }
  }
  else if(query.includes('Language=')){
    let item = query.split("Language=");
    language = !item ? 'NA' : item[1]; 
    if(language && language.includes("&"))
    {
      let temp = language.split("&");
      language = !temp ? 'NA' : temp[0];
  
    }
  }
  else{
    if(Preview) {
      langCode ='NA';
    }
    language = langCode;
  }
  let  urlString = window.location.href;
  let initialResponse;

  if(urlString.includes('?Lang=NA') || urlString.includes('?Lang=en_US') || urlString.includes('?Lang=zh_CN') || urlString.includes('?Lang=ja_JP')){
    initialResponse = await Promise.all([
      getMarqueeProductInformation({ offeringId, langCode }),
      getOfferingDetailWorkingCopy({
        offeringId,
        bEditOffering: false,
        bViewOffering: true,
        bCompareOffering: false,
        language,
        langCode,
        isPreview:Preview,
      }),
    ]);
  } else {
    initialResponse = await Promise.all([
      getMarqueeProductInformation({ offeringId, langCode }),
      getOfferingDetail({
        offeringId,
        bEditOffering: false,
        bViewOffering: true,
        bCompareOffering: false,
        language,
        langCode,
        isPreview:Preview,
      }),
    ]);
  }
  const responses = initialResponse;
  console.log('responses--->',responses);
  const marqueeResponse = responses[0] ? responses[0][0] : null;
  const response = JSON.parse(responses[1]).objectData;
  let cacheOutput = response.CaptureCacheTime;
  let isAdmin = response.isAdmin;
  const offering__c = response.OfferingDetail ? response.OfferingDetail[0] : null;
  console.log('the offering is:'+offering__c);
  const startDate = offering__c.PMP_Partner_Offering_Start_Dt__c; // storing from date in a variable
  console.log('the start date is:'+startDate);
  const today = (new Date()).toISOString().slice(0, 10);
  
  const extractedNotificationBanner = notificationBannerExtractor(offering__c, startDate);
  const extractedGalleryImages = (typeof(response.media) !=  "undefined") ? galleryImageExtractor(response.media):[]; //Added by Sreelatha
  const extractedCategories = (typeof(response.selectedCategories) !=  "undefined") ? categoriesExtractor(response.selectedCategories):[];
  const extractedSpecifications = (typeof(response.selectedSpecifications) !=  "undefined") ? specificationsExtractor(response.selectedSpecifications):[];
  
  const extractedQualityMetrics = (typeof(response.selectedSpecificationsMap) !=  "undefined") ? qualityMetricsExtractor(response.selectedSpecificationsMap):[];
  const extractedPartnerAttributes = (typeof(response.partnerDetail) !=  "undefined") ? partnerAttributesExtractor(response.partnerDetail.attributes):[];

  let descShort;

		if(offering__c.PMP_Partner_Offering_Dsc__c && offering__c.PMP_Partner_Offering_Dsc__c.length>250)
		{
		let doc = new DOMParser().parseFromString(offering__c.PMP_Partner_Offering_Dsc__c, 'text/html');
		let strippedDescription = doc.body.textContent;
		let length = strippedDescription.substring(0,250).lastIndexOf(" ");
		descShort = strippedDescription.substring(0,length) + '...';
		}

  // GATHER OFFERING DATA
  const offering = {
    showClearCacheButton : false, //(response.isAdmin)?true: false,
    disableCacheButton : cacheOutput?false:true,
    cacheDate : (response.isAdmin)?cacheOutput : '',
    showCloneButton : false,
    showDateChangeButton : false,
    contactPartnerModalData : false, 
    editButtonDisabled : false,
    showDisclaimer : false,
    showAllCompanyOfferingsLink : false,
    displayLanguage : '',
    isAnonymousUser: !!response.isAnonymousUser,
    isAdmin: !!response.isAdmin,
    internalAdmin: false, //!!response.isAdmin,
    isPublished: !!extractedNotificationBanner.isPublished,
    notificationBanners: [{
      message: extractedNotificationBanner.notificationBanner.message,
      iconType: extractedNotificationBanner.notificationBanner.type,
      theme: 'background',
    }] || [],
    showEventBanner: response.eventPartnerOffering,
    showEditButton: !!response.showEditButton,
    showContactPartner: !!response.showContactPartner,
    // Offering Info
    id: offering__c.Id,
    workingCopyId: response.WorkingCopyId,
    //title: offering__c.Name,
    title : (offering__c.PMP_Partner_Offering_Nm__c != null) ? offering__c.PMP_Partner_Offering_Nm__c : offering__c.Name,
    images: extractedGalleryImages,
    compareCategoryId: marqueeResponse ? marqueeResponse.compareCategoryId : '',
    publishedDate: new Date(offering__c.PMP_Offering_Status_Update_Dt__c),
    tagline: offering__c.PMP_Partner_Offering_Tag_Line_Txt__c,
    descriptionShort : descShort,
    descriptionLong: offering__c.PMP_Partner_Offering_Dsc__c,
    techSpecs: [{
      label: PMP_Category,
      attributesList: [{
        separator: ':',
        values: extractedCategories.productCategories.map((cat) => ({
          isLink: true,
          label: cat.Name,
          recordId: cat.PMP_Category_Id__c,
          objectPage: 'PMP_Category__c',
        })),
      }],
    }].concat(((typeof(response.selectedSpecificationsMap)!='undefined') ?response.selectedSpecificationsMap:[] || []).map((s) => ({
      label: s.masterCategory,
      attributesList: [{
        values: s.valueList.map((v) => ({
          label: v,
        })),
      }],
    }))),
    qualityMetricsLabel : response.qualityMetricsLabel ? response.qualityMetricsLabel : ' ',
    qualityMetrics: (response.QualityMetrics || []).map((m) => ({
      label: m.masterCategory,
      values: m.valueList.map((v) => ({
        label: v.split(' : ')[0],
        value: [v.split(' : ')[1]],
        showCheckmark: v.includes('Yes') ? true:false,
      }))
  })),
    intelTechnology: extractedSpecifications.includedIntelTechnologies.map((t) => ({
      image: t.specImageUrl || placeholder1x1,
      imageLink: t.specTitleUrl,
      values: [{
        isLink: !!t.specTitleUrl,
        class: 'text-bold',
        label: t.specTitle,
        externalUrl: t.specTitleUrl,
      }].concat((t.specValues || []).map((v) => ({
        isLink: !!v.productURL,
        label: v.description,
        externalUrl: v.productURL,
      }))),
    })),
    marketingInfo: response.marketingInfo,
    // Resources
    resources: ((typeof(response.offeringResources)!='undefined')?response.offeringResources:[] || []),
    // Partner Info
    partnerId: (typeof(offering__c.PMP_Company_Id__r)!='undefined') ? offering__c.PMP_Company_Id__r.Id:''|| '',
    partnerName:  (typeof(offering__c.PMP_Company_Id__r)!='undefined') ? offering__c.PMP_Company_Id__r.Name:'' ||'',
    partnerLogo: (typeof(response.partnerDetail) !=  "undefined") ? response.partnerDetail.imageUrl: '',
    partnerAutoId: (typeof(response.partnerDetail) !=  "undefined") ? response.partnerDetail.autoPartnerId: '',partnerAutoId: (typeof(response.partnerDetail) !=  "undefined") ? response.partnerDetail.autoPartnerId: '',
    // Partner Attributes
    partnerAttributes: extractedPartnerAttributes,
    // Company Resources
    companyResources: ((typeof(response.productCompanyResource) !=  "undefined")?response.productCompanyResource.companyResources:[] || []).map((r) => ({
      title: r.title,
      url: r.linkUrl,
      label: r.linkUrl,
    })),
    // Articles
    articles: ((typeof(response.articleCompanyResource) !=  "undefined" && response.articleCompanyResource.articleList !=  null )?response.articleCompanyResource.articleList:[] || []).map((a) => ({
      ...a,
    })),
  };

  if(Preview){
    offering.showClearCacheButton = false;//hide clear cache button in preview mode
    offering.internalAdmin = false;
  }
  // Additional Business Logic
  // Edit / Clone Buttons, Notification Banner, etc.
  if ( response.showEditButton)// && (offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Published' || offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired' )) 
  {
    
    offering.showCloneButton = true;
      if(offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired') {
        offering.showEditButton = false;
      }
      
  } else {
    offering.notificationBanners = [];
  } // User is logged in
    // Date Change Button
    
    if (offering.showEditButton && offering__c.PMP_Is_Notified_Ind__c) {
      
       offering.showDateChangeButton = true;
    }
    if(typeof(offering__c.PMP_Translated_Languages__c)=='undefined'){
      offering__c.PMP_Translated_Languages__c = [];
    }
    if(typeof(offering__c.PMP_Business_Segment_Nm__c)=='undefined'){
      offering__c.PMP_Business_Segment_Nm__c = [];
    }
    
    // Gireesh:US762788
    const isNotEnglish = (
      !(offering__c.PMP_Translated_Languages__c).includes('English')
      && (offering__c.PMP_Business_Segment_Nm__c).includes('IoT')
    );
      
    const isUnderReview = offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Admin Review';
    const isApprovedForFuture = (
      offering__c.PMP_Partner_Offering_Lifecycle_Status_Nm__c === 'Approved'
      && (new Date(startDate) > new Date(today))
    );

    if ((isNotEnglish && response.isAdmin) || (!response.isAdmin && (isUnderReview || isApprovedForFuture))) {
      offering.editButtonDisabled = true;
    }
  

  // Show Disclaimer
  if (response.isIntelEmployee && (offering__c.PMP_Partner_Offering_Visibility_Nm__c !== 'Public Content')) {
    offering.showDisclaimer = true;
  }

  // Show "All Company Offerings ->" Link
  if ((typeof(response.partnerDetail) !=  "undefined")?response.partnerDetail.benefitType : ''=== 'Solutions Marketplace Enhanced') {
    offering.showAllCompanyOfferingsLink = true;
  }

  // add contact partner modal data
  offering.contactPartnerModalData = {};
  if (response.showContactPartner) {
    offering.contactPartnerModalData = {
      name: offering.partnerName,
      id: offering.partnerId,
      autoPartnerId: offering.partnerAutoId,
      leadLangPreference: offering.leadLangPreference,
      title: offering.title,
      oid: offering__c.PMP_Offering_Id__c, 
      offRecId: offering__c.Id,
      isLoggedIn: !offering.isAnonymousUser, 
    };
  }


  // if langauge parameter is not present in url, we check for user locale in the apex controller and
  // send it as a parmeter. This is done as a part of change request.
  if (!language && response.userLocale && response.userLocale !== 'NA') {
    language = response.userLocale;

  // we set Language as NA on the offering name formula field so that we show base language
  // values when user clicks on offering name from list view
  } else if (language === 'NA') {
    language = undefined;
  }
  offering.displayLanguage = language;

  // eslint-disable-next-line no-console
  console.log('getOfferingDetailsBackend - compiled offering data', offering);
  

  return offering;
  */
}