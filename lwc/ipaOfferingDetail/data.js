// import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// /**
//  * Default Gallery Image
//  *
//  * @type {string}
//  * @private
//  */
// const defaultGalleryImage = `${CoreResource}/images/standard-placeholder-4x3.png`;

// /**
//  * Default Partner Logo
//  *
//  * @type {string}
//  * @private
//  */
// const defaultPartnerLogo = `${CoreResource}/images/standard-placeholder-16x9.png`;

// /** External Link is a generic structure used for:
//  * Resources (on Resources Tab)
//  * Company Resources
//  * Articles and Newspapers
//  *
//  * @typedef ExternalLink
//  * @property {string} title text for title
//  * @property {string} url url for article
//  * @property {string} label label for url
//  */

// /** Attribute Section
//  * Represents a group of attributes
//  * If a separator is given, all attributes are displayed inline, with a separator ie. 'One - Two'
//  * Attribute values consist of a label and optional link data
//  *
//  * @typedef AttributeSection
//  * @property {string} [separator] used to separate attributes (ie. '|', '-', ':')
//  * @property {string} label label for section (ie. Regional Coverage groupings like 'Americas')
//  * @property {Attribute[]} values attribute values (see Attribute type definition)
//  */

// /** Attribute
//  * This is the generic object for an "attribute"
//  * It can be simple text or a link to an object/record or an external url
//  *
//  * @typedef Attribute
//  * @property {string} label text label for attribute
//  * @property {string} [attributeClass] optional class for each attribute (to add padding or styles)
//  * @property {boolean} [isLink] if attribute is a link
//  * @property {string} [recordId] id for link if an object page
//  * @property {string} [objectPage] api name for link if an object page
//  * @property {string} [externalUrl] url for link if an external link
//  */

// /**
//  * @typedef NotificationBanner
//  * @property {string} message notification message
//  * @property {string} [theme] 'background' or 'none'
//  * @property {string} iconType 'submitted', 'update', 'review', 'published'
//  */

// /**
//  * @typedef TechSpec
//  * @property {string} label label for tech spec category (ie. 'Operating Systems')
//  * @property {AttributeSection[]} attributesList list of attribute sections incl. attribute values
//  */

// /**
//  * @typedef QualityMetric
//  * @property {string} label label for tech spec category (ie. 'Operating Systems')
//  * @property {AttributeSection[]} attributesList list of attribute sections incl. attribute values
//  * @property {boolean} showCheckmark use this for quality metric blue checkmark
//  */

// /**
//  * @typedef IntelTechnologyCard
//  * @property {string} image image url
//  * @property {string} [imageAlt] image alt text
//  * @property {string} [imageLink] if available use first url in list of values
//  * @property {Attribute[]} values the list of technologies, can be text or link
//  */

// /**
//  * @typedef MarketingInfoSection
//  * @property {string} headline headline for section (ie. "Industries")
//  * @property {string[]} items list of items for section (all text strings)
//  */

// /**
//  * @typedef PartnerAttribute
//  * @property {string} title text for attribute list (ie. Regional Coverage)
//  * @property {AttributeSection[]} sections sections for attribute list
//  */

// /**
//  * @typedef Resource
//  * @property {string} title title
//  * @property {string} [description] description
//  * @property {string} url url
//  * @property {string} [fileSize] fileSize
//  * @property {string} [fileType] filetype
//  * @property {string} resourceType resource type
//  * @property {string} [downloadUrl] downloadurl
//  */

// /** Data Structure for UI / Template
//  *
//  * @typedef OfferingDetailData
//  * @property {ExternalLink[]} articles list of company articles (links)
//  * @property {ExternalLink[]} companyResources list of company resources (links)
//  * @property {string} compareCategoryId id for "Add to Compare" data
//  * @property {*} contactPartnerModalData data for contact partner modal
//  * @property {string} descriptionLong long description
//  * @property {string} descriptionShort short description
//  * @property {boolean} hasShortDescription short description exists for "Show more" / "Show less"
//  * @property {string} [displayLanguage] needed for Clone Offering
//  * @property {string} id Offering ID
//  * @property {string[]} images product / offering images for gallery
//  * @property {IntelTechnologyCard[]} intelTechnology list of intel technology cards
//  * @property {boolean} isAnonymousUser status of user
//  * @property {boolean} isPublished published status for offering
//  * @property {MarketingInfoSection[]} marketingInfo marketing info sections
//  * @property {NotificationBanner[]} notificationBanners displays status message related to the offering in a status bar
//  * @property {PartnerAttribute[]} partnerAttributes partner attributes (Sidebar)
//  * @property {string} partnerId partner Id
//  * @property {string} partnerLogo image for partner logo
//  * @property {string} partnerName partner name
//  * @property {string} publishedDate date offering published
//  * @property {Resource[]} resources list of resources (tab view)
//  * @property {boolean} showAllCompanyOfferingsLink shows a link to "All Company Offerings ->" in the sidebar
//  * @property {boolean} showDisclaimer visibility for disclaimer to Intel employees
//  * @property {boolean} showEventBanner visibility for event banner component
//  * @property {boolean} showCloneButton visibility for clone button
//  * @property {boolean} showContactPartner visibility for Contact Partner button
//  * @property {boolean} showEditButton visibility for edit button
//  * @property {TechSpec[]} techSpecs technical specifications for offering
//  * @property {string} qualityMetricsLabel name
//  * @property {QualityMetric[]} qualityMetrics quality metrics
//  * @property {string} title title/Name of Offering
//  * @property {string} workingCopyId Offering ID (Working Copy)
//  */
// export const defaultData = {
//   notificationBanners: [],
//   /* CONTENT VISIBILITY */
//   isAnonymousUser: true,
//   isAdmin: false,
//   showEventBanner: false,
//   showEditButton: false,
//   showContactPartner: false,
//   /* Tab 1 - "Description" */
//   images: [defaultGalleryImage],
//   descriptionShort: '',
//   descriptionLong: '',
//   techSpecs: [],
//   qualityMetricsLabel: '',
//   qualityMetrics: [],
//   intelTechnology: [],
//   /* Tab 2 - "Offering Details" */
//   marketingInfo: [],
//   /* Tab 3 - "Resources" */
//   resources: [],
//   /* Partner Sidebar Info */
//   partnerLogo: defaultPartnerLogo,
//   partnerId: '',
//   partnerName: '',
//   partnerAttributes: [],
//   companyResources: [],
//   articles: [],
// };

// /** This function formats offering data for the Offering Detail page.
//  * It includes some error handling and some specific default values.
//  * <br><b>It also handles "Preview Mode" visibility</b>
//  *
//  * @param {OfferingDetailData} data raw data from data service
//  * @param {object} options options for formatting
//  * @param {boolean} options.isPreviewMode format data for "preview mode"
//  * @returns {OfferingDetailData} formatted data
//  */
// export function formatOfferingDetailData(data = {}, options = {}) {
//   const result = { ...defaultData, ...data };
//   result.hasShortDescription = result.descriptionShort && result.descriptionShort !== result.descriptionLong;

//   // if offering has no images, use default image
//   if (!result.images.length) {
//     result.images = defaultData.images;
//   }

//   // hide elements for "Preview Mode"
//   if (options.isPreviewMode) {
//     result.notificationBanners = [];
//     result.showEventBanner = false;
//     result.showCloneButton = false;
//     result.showEditButton = false;
//   }

//   return result;
// }