import checkValidPartner from '@salesforce/apex/PMP_SearchMarketplaceController.checkValidPartner';
import getPartnerDetails from '@salesforce/apex/PMP_MarketplaceNewPartnerDetail.getPartnerDetails';
import { handleError } from 'c/ipaErrorServiceMarketplace';
import errorPageURL from '@salesforce/label/c.PMP_Error_Page_URL';

import langLocale from '@salesforce/i18n/lang';

const languageCode = langLocale.replaceAll('-', '_');

/**
 * Get company information from backend
 *
 * @param {string} partnerId partner id
 * @returns {object} storefront data
 */
export default async (partnerId) => {
  let partner = {};
  let partnerData = {};
  const valid = await checkValidPartner({ partnerId });
  if (valid) {
    await getPartnerDetails({ partnerId, langCode: languageCode })
      .then((result) => {
        partner = result;
      }).catch((error) => {
        handleError(error, 'partnerInfo', 'console');
      });
    partnerData = {
      contactPartnerData: {
        name: partner.name,
        id: partnerId,
        autoPartnerId: partner.partnerDetails.autoPartnerId,
        leadLangPreference: partner.leadLangPreference,
        isLoggedIn: !partner.isGuest,
      },
      showContactPartner: partner.isContactPartnerVisible,
      categories: [],
      partnerAttributes: partner.partnerDetails.attributes,
      companyInfo: {
        description: partner.partnerDescription,
        descriptionShort: partner.partnerShortDescription,
        websiteLabel: partner.name,
        websiteUrl: partner.website,
      },
      name: partner.name,
      logoUrl: partner.partnerDetails.imageUrl,
      logoAlt: '',
      tagline: partner.tagline,
      partnerStatus: partner.tierStatus,
      specialties: partner.specialties,
      isDistributor: partner.isDistributor,
      companyResources: (partner.companyResources || []).map((resource, idx) => ({
        key: `company-resource-${idx}`,
        title: resource.title,
        url: resource.linkUrl,
        urlLabel: resource.linkUrl,
        resourceType: resource.type,
      })),
    };
  } else {
    window.location.href = errorPageURL;
  }
  return partnerData;
};